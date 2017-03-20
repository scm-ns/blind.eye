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




final class RootCoordinator : NSObject , cameraDataSource
{
    // MARK- Private Variables
    private let captureSession : AVCaptureSession
    private let videoCaptureInput : AVCaptureDeviceInput? = nil
    private let cameraSetupAndProcessQeueu : DispatchQueue
    private let cameraPreivewLayer : AVCaptureVideoPreviewLayer
    private var captureSetupResult : CameraSetupResult
    private let rootVC : UIViewController
    private let window : UIWindow
    
    fileprivate var cameraDataPropogationTimer : Timer? = nil // needed in the extension
    fileprivate var propogationController : Bool = false
    var cameraDataTranports : [cameraDataTransport] = []
    
    init(window : UIWindow)
    {
       
        // Setup Camera
        self.captureSession = AVCaptureSession()
        self.cameraSetupAndProcessQeueu = DispatchQueue(label: "com.camera_setup_process_queue.serial") // by default serial queue
        self.cameraPreivewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.captureSetupResult = .authorized
        
        // setup VC
        self.rootVC = RootViewController(cameraImageLayer: self.cameraPreivewLayer )
        self.window = window
        
        super.init()
        
        if let controller = self.rootVC as? cameraDataPropogationController
        {
           controller.configurePropogationController(propCon: self)
        }
        
        if let cam_transport = self.rootVC as? cameraDataTransport
        {
           self.addCameraTransport(transport: cam_transport)
        }
      
        if let sound_transport = self.rootVC as? soundDataPipe
        {
            sound_transport.addSoundTransport(transport: self as soundDataSink)
        }
        

        self.setupPropogationTimer()
       
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
    
    
    /*
        pre :
        post : 
        state change : 
        decs : 
            This function is never called directly, but by the timer which is set to fire repeatedly. 
            This controls where the data obatined from camera by acting as a delegate for AVCaptureSession, 
            is propogated. 
            We do not want to analyze each frame from the camera. This toogles a bool which allows propogation
            in the did output sample buffer.
    */
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
    func propogateCameraData(pixelBuffer : CVPixelBuffer)
    {
        for  tranport in self.cameraDataTranports
        {
            if let sink = tranport as? cameraDataSink
            {
                sink.processPixelBuffer(pixelBuff: pixelBuffer)
                print("Layer 1 Source-Sink: CameraData Propogation Complete")
            }
            else if let pipe = tranport as? cameraDataPipe
            {
                pipe.pipePixelBuffer(pixelBuff: pixelBuffer)
                print("Layer 1 Source-Pipe: Camera Data Propogation Complete")
            }
            else
            {
                print("Layer 1 : Camera Data Propogation Failed")
            }
            
        }
    }
   
    // Root Coordinator can know about the different classes that it holds. I just need to ensure dependency inversion
    // that is the lower classes should not have to know about the upper classes
    func addCameraTransport(transport : cameraDataTransport)
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
    
    
    func setupPropogationTimer()
    {
        // Both the creation and invalidation of the timer will happen in the main thread.
        // This will meet the requirement that NSTimer has of being created and removed from same thread
        DispatchQueue.main.async
        {
            // set up timer which will propogate the data along the chain
            self.cameraDataPropogationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(RootCoordinator.shouldPropogate), userInfo: nil, repeats: true)
        }
    }
   
    func tearDownPropogationTimer()
    {
        guard let timer = self.cameraDataPropogationTimer else
        {
           return
        }
        
        DispatchQueue.main.async
        {
                timer.invalidate()
        }
    }
    
    
    /*
        Configures the AVCapture session with a few setting like which camera to use. Which format
        Also sets up a seperate queue for doing the processing
    */
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
    
}

/*
    desc :
        By default a timer is setup on init and the data is propogated when ever the timer fires.
 
    This protocol conformance allows the caller to decide whether to stop the propogation or restart it
 
 */
extension RootCoordinator : cameraDataPropogationControl
{
    func stopPropogation()
    {
       if (self.cameraDataPropogationTimer?.isValid)!
       {
            self.tearDownPropogationTimer()
       }
       self.cameraDataPropogationTimer = nil
    }
    
    func restartPropogation()
    {
        guard self.cameraDataPropogationTimer == nil , self.cameraDataPropogationTimer?.isValid == nil else // only recreate the timer if previously removed or invalid
        {
           return
        }
        self.setupPropogationTimer()
    }
  
    func isRunning() -> Bool
    {
        if let timer = self.cameraDataPropogationTimer
        {
            return timer.isValid
        }
        else
        {
            return false
        }
    }
    
}


extension RootCoordinator : AVCaptureVideoDataOutputSampleBufferDelegate
{
     /*
            The AVCaptureSession calls this method with each new frame.
            And we process the frame by passing it to all the pipes and sinks connected to this source
            
            But since we do not want to overload the system. We do not process every frame, but only 
            process a frame when self.propogationController bool is true. This variable change to true state
            happens when a repeating timer fires.
     
    */
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
            if(self.propogationController)
            {
                let pixelBuf : CVPixelBuffer? =  CMSampleBufferGetImageBuffer(sampleBuffer)
                if let buf = pixelBuf
                {
                    DispatchQueue.global(qos: .userInitiated).async
                    {
                        self.propogateCameraData(pixelBuffer:buf); // May be the prpogation should be done in a different thread?
                        self.propogationController = false
                    }
                    print("get valid camera buffer : \(sampleBuffer != nil)")
                }
            }
    }
}

extension RootCoordinator : soundDataSink
{
    func processSound(str : String)
    {
       print(" SOUND DATA AVALIBALE : \(str)")
    }
}

