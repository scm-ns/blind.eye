//
//  RootCoordinator.swift
//  blind.eye
//
//  Created by scm197 on 3/9/17.
//  Copyright © 2017 scm197. All rights reserved.
//

// This class will be in charge : 
    // 1 getting camera input and feeding it into different sinks
    // 2 showing the different types ov View Controller
    // 3 UI Element to show that Camera is still recording
    // 4 Left Top Options menu


/*
    How to pass the data up ?
        Pipe system.
            Coordinator -> MainVC -> ColView -> One of the cell
 
            Is there a better system. There might be but this is a pretty interesting system.
 
 */


enum CameraSetupResult
{
    case notDetermined
    case authorized
    case denied
}


/*
    Camera Image Source 
    What is the difference between a pipe and a sink
    A pipe is not the end point.
    It might do some transformations, but it passes it upwards.
 */

protocol cameraDataTransport // Does nothing. Allows abstraction between the two different types of
    // transfers
{
}

protocol cameraDataSink : cameraDataTransport
{
    func processPixelBuffer(pixelBuff : CVPixelBuffer)
}

protocol cameraDataPipe : cameraDataTransport
{
    func pipePixelBuffer(pixelBuff : CVPixelBuffer)
}

final class RootCoordinator : NSObject ,AVCaptureVideoDataOutputSampleBufferDelegate
{
    // MARK- Private Variables
    private let captureSession : AVCaptureSession
    private let videoCaptureInput : AVCaptureDeviceInput? = nil
    private let cameraSetupAndProcessQeueu : DispatchQueue
    private let cameraPreivewLayer : AVCaptureVideoPreviewLayer
    private var captureSetupResult : CameraSetupResult
    private let rootVC : UIViewController
    private let window : UIWindow
    
    private var cameraDataPropogationTimer : Timer? = nil
    private var propogationController : Bool = false
    private var cameraDataTranports : [cameraDataTransport] = []
    
    init(window : UIWindow)
    {
       
        // Setup Camera
        self.captureSession = AVCaptureSession()
        self.cameraSetupAndProcessQeueu = DispatchQueue(label: "com.camera_setup_process_queue.serial") // by default serial queue
        self.cameraPreivewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.captureSetupResult = .authorized
        
        // setup VC
        self.rootVC = RootViewController(cameraImageLayer: self.cameraPreivewLayer)
        self.window = window
        
        super.init()
       
        self.addTransport(transport: self.rootVC as! cameraDataTransport )
        
        // set up timer which will propogate the data along the chain
        self.cameraDataPropogationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(RootCoordinator.shouldPropogate), userInfo: nil, repeats: true)
       
        // ask for user autorization before using the camera
        switch(AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo))
        {
            case .authorized:
                break;
            case .notDetermined:
                self.cameraSetupAndProcessQeueu.suspend()
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler:
                {
                    (result :Bool) in
                    if(!result)
                    {
                       self.captureSetupResult = .notDetermined
                    }
                    self.cameraSetupAndProcessQeueu.resume()
                })
            default :
                self.captureSetupResult = .denied
        }
        print("camera Auth \(self.captureSetupResult == .authorized)")
        
        // is the init done in the main thread.
        // any advantage in moving to another thread ?
        self.cameraSetupAndProcessQeueu.async {
            self.configureCamera()
        }
        
    }
    
    
    func configureCamera()
    {
        if !(self.captureSetupResult == .authorized)
        {
           print("Not Authorization to Capture Result")
        }
        
        self.captureSession.beginConfiguration()
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
       
        // set up the device for capture
        let videoDevice : AVCaptureDevice? = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo);
       
        if let videoDevice = videoDevice
        {
            // set up the input for capture 
            let videoInput = try? AVCaptureDeviceInput(device: videoDevice) // nil if error
            if let videoInput = videoInput
            {
                if self.captureSession.canAddInput(videoInput)
                {
                   self.captureSession.addInput(videoInput)
                }    
            }
            
            
        }
        else
        {
           self.captureSetupResult = .denied
        }
       
        
        // set up the out for the session
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : kCMPixelFormat_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: self.cameraSetupAndProcessQeueu)
        
       
        if self.captureSession.canAddOutput(videoOutput)
        {
            self.captureSession.addOutput(videoOutput)
        }
       
        videoOutput.connection(withMediaType: AVMediaTypeVideo)
        self.captureSession.commitConfiguration()
   
        self.captureSession.startRunning()
        
        self.cameraDataPropogationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.shouldPropogate), userInfo: nil, repeats: true)
    }
  
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
            if(self.propogationController)
            {
                let pixelBuf : CVPixelBuffer? =  CMSampleBufferGetImageBuffer(sampleBuffer)
                if let buf = pixelBuf
                {
                    DispatchQueue.global(qos: .userInitiated).async
                    {
                        self.propogate(pixelBuffer:buf); // May be the prpogation should be done in a different thread?
                        self.propogationController = false
                    }
                    print("get valid camera buffer : \(sampleBuffer != nil)")
                }
            }
    }
    
    func shouldPropogate()
    {
        if(self.captureSession.isRunning) // propogate only if camera capturing
        {
            self.propogationController = true
        }
    }
    /*
        The input is fed from the camera output and is passed into various sinks,
        where the processing of the data is done.
     */
    func propogate(pixelBuffer : CVPixelBuffer)
    {
        for  tranport in self.cameraDataTranports
        {
            if let sink = tranport as? cameraDataSink
            {
                sink.processPixelBuffer(pixelBuff: pixelBuffer)
                print("Layer 1 Sink: Propogation Complete")
            }
            else if let pipe = tranport as? cameraDataPipe
            {
                pipe.pipePixelBuffer(pixelBuff: pixelBuffer)
                print("Layer 1 Pipe: Propogation Complete")
            }
            else
            {
                print("Layer 1 : Propogation Failed")
            }
            
        }
    }
   
    // Root Coordinator can know about the different classes that it holds. I just need to ensure dependency inversion
    // that is the lower classes should not have to know about the upper classes
    func addTransport(transport : cameraDataTransport)
    {
       self.cameraDataTranports.append(transport)
    }
   
    // This is the initial starting point of the app. From the App Delegate the program moves here
    // The Root View setup is done here.
    func execute()
    {
        self.window.rootViewController = self.rootVC
        self.window.makeKeyAndVisible()
        print("app launched")
    }
    
}





