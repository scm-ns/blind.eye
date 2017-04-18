//
//  RootViewController.swift
//  blind.eye
//
//  Created by scm197 on 3/10/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit

/*
    This class will be tightly coupled to the RootCoodinator for now
            // TODO : Use protocols to uncouple
 
    Will have a capure in progress button at the top
    Will be more like a container view controller.
        >> Good way to present and unpresetn view controllers ?? 
 
 */

/*
    Will have different UI Elements :
        A red Button at the top to control whether to propogate the data or not
        May be an UILabel at the botton which tells about the current state that the app is in.
        Whether recording or not recording
 
        A complex UI element from the buttom to show information and give proper attribution
 */

/*
    Pipe Architecture :
        This class acts as a pipe which will transmit camera data to other objects
*/

class RootViewController: UIViewController
{

    private let cameraPreviewLayer : AVCaptureVideoPreviewLayer
    private var cameraPreviewView : UIView? = nil
    fileprivate let mainVC: MainVC = MainVC()
    private var propogationControllerButton: UIButton? = nil // image propogation
    
    // Button to control the state of whether we speak out the identified items
    private var speechControlButton : UIButton? = nil
   
    private lazy var blurOverLay : UIVisualEffectView =
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        return blurView
    }()
   
    /*
        The feeding of data through the pipe is controlled by this 
        delegate.
        Gives us a option to control the flow through ( start and stop ) and query the state (isRunning)
    */
    fileprivate var propogationControl : cameraDataPropogationControl? // used by extension
    fileprivate var soundControl : soundControl?
    
    
    var cameraDataTranports: [cameraDataTransport] = [] // cameraDataPipe Protocol
    var soundDataTransports: [soundDataTransport] = [] // soundPipe Protocol
    
    init(cameraImageLayer : AVCaptureVideoPreviewLayer )
    {
       self.cameraPreviewLayer = cameraImageLayer
       super.init(nibName: nil, bundle: nil)
    }

   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // set up the preview and blur
        self.setupCameraPreview()
        self.setupBlurAboveCameraPreview()
        self.setupMainVC()
       
        self.addCameraTransport(transport: self.mainVC as cameraDataTransport)
       
        self.mainVC.addSoundTransport(transport: self as soundDataTransport)
        
        
        self.view.addSubview(self.blurOverLay)
    }
   
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Add the camera video input layer to the view of the VC
    func setupCameraPreview()
    {
            self.cameraPreviewView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            self.cameraPreviewLayer.frame = self.cameraPreviewView!.bounds
            self.cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.cameraPreviewView!.layer.addSublayer(self.cameraPreviewLayer)
            self.view.addSubview(self.cameraPreviewView!)
    }
   
    // add blue effect on top of the camera view
    func setupBlurAboveCameraPreview()
    {
        if !UIAccessibilityIsReduceTransparencyEnabled()
        {
               // TO DO : The blur effect is too over powering.
               // After core implementation try to improve this
               self.blurOverLay.frame = self.view.bounds
            
                // add the propogation control button
               self.blurOverLay.contentView.addSubview(createPropogationControlButton())
            
                // add the text to voice control button
               self.blurOverLay.contentView.addSubview(createVoiceControlButton())
        }
    }

   
    func createVoiceControlButton() -> UIButton
    {
        self.speechControlButton = UIButton(frame: CGRect(x: (self.view.bounds.width * 2.0/3) - 20 , y: 30, width: 40, height: 40))
            // on highlight / selected we move from speaker -> mute
        self.speechControlButton?.setImage(UIImage(named : "speaker"), for: .normal)
        self.speechControlButton?.setImage(UIImage(named : "mute"), for: .selected)
        
        self.speechControlButton?.addTarget(self, action: #selector(self.toogleSpeechToText), for: .touchUpInside)
        
        return self.speechControlButton! 
    }
    
    
 
    /*
        pre : funtion added as target to speaker control button
        post : toogle the feature of saying the items recognized
        state change : toogle speech 2 text feature
        decs :  not called directly
 
    */
    func toogleSpeechToText()
    {
        
    }
   
    
    
    /*
        pre : the blueOverLay should be setup. In current setup it means call after setupBlurAboveCameraPreview
        post : setups the button so that it can now control the propagtion of data through the pipe
        state change : the button is setup. Propogation control is now possible
        decs :
    */
    func createPropogationControlButton() ->  UIButton
    {
            //TO DO : 
            // Add animations to the button so that button goes from being a red circle to a red square
        
           // Add button to control propogation
           self.propogationControllerButton = UIButton(frame:CGRect(x: self.view.bounds.width/3 - 20 , y: 30, width: 40, height: 40))
        
           self.propogationControllerButton?.backgroundColor = UIColor.red
           self.propogationControllerButton?.layer.cornerRadius = 20 // corner half of button width and height
        
           self.propogationControllerButton?.addTarget(self, action: #selector(self.tooglePropogation), for: .touchUpInside)
       
           return self.propogationControllerButton!
    }
    
     
   
    /*
        pre : The propogationControlButton has to be setup and this should be added as a target to control flow
        post : Now the user can stop the propogation of data is they want.
        state change : sends stop signal to propogationControl , so that no more camera data is fed
        desc :
                Never called directly, but called when the button control propogate, changes state
    */
    func tooglePropogation()
    {
       guard let propogationControl = self.propogationControl else // if the propogationControl is now avalible do nothing
       {
            return
       }
        // switch prop on/off based on current state
       if (propogationControl.isRunning())
       {
           self.propogationControllerButton?.backgroundColor = UIColor.black
           propogationControl.stopPropogation()
       }
       else
       {
            self.propogationControllerButton?.backgroundColor = UIColor.red
            propogationControl.restartPropogation()
       }
    }
    
    func createButtonArrowButton()
    {
       
    }
  
    
    
    func setupMainVC()
    {
        // Add Contraints
        // layout
        let view = mainVC.view!
        view.translatesAutoresizingMaskIntoConstraints = false
    
        // Add corner radium to view
        
        // border radius
        view.layer.cornerRadius = 30.0
        // border
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.5;
        
        // drop shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 3.0
        view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        // add on top of the blur
        self.blurOverLay.contentView.addSubview(view)
        
        let viewMapping = ["v0":view]
        var constraints : [NSLayoutConstraint] = []
        constraints.append(contentsOf:   NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[v0]-20-|", options: [], metrics: [:], views: viewMapping) )
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        NSLayoutConstraint.activate(constraints)
        
    }
   
}

// Act as a pipe for tranmitting the camera buffer data
extension RootViewController : cameraDataPipe
{
    func pipePixelBuffer(pixelBuff: CVPixelBuffer)
    {

        for  tranport in self.cameraDataTranports
        {
            if let sink = tranport as? cameraDataSink
            {
                sink.processPixelBuffer(pixelBuff: pixelBuff)
                print("Layer 2 Sink: CameraData Propogation Complete")
            }
            else if let pipe = tranport as? cameraDataPipe
            {
                pipe.pipePixelBuffer(pixelBuff: pixelBuff)
                print("Layer 2 Pipe: Camera Data Propogation Complete")
            }
            else
            {
                print("Layer 2 : Camera Data Propogation Failed")
            }
            
        }

    }
   
    func addCameraTransport(transport: cameraDataTransport)
    {
       self.cameraDataTranports.append(transport)
    }
}



extension RootViewController : soundDataPipe
{
    func pipeSound(str : String)
    {
        for transport in self.soundDataTransports
        {
            if let sink = transport as? soundDataSink
            {
                sink.processSound(str: str)
                print("Layer 1 Sink : Sound Propogation Complete")
            }
            else if let pipe = transport as? soundDataPipe
            {
                pipe.pipeSound(str: str)
                print("Layer 1 Pipe : Sound Propogation Complete")
            }
            else
            {
                print("Layer 1 : Sound Propogation Failed")
            }
        }
    }
    
    func addSoundTransport(transport : soundDataTransport)
    {
        self.soundDataTransports.append(transport)
    }
}

// get access to delegate, through which the text 2 speech system can be controlled
extension RootViewController : soundController
{
    func configureSoundController(soundCon: soundControl)
    {
        self.soundControl = soundCon
    }
}


// get access to delegate, through which the propogation of data can be controller
extension RootViewController : cameraDataPropogationController
{
    func configurePropogationController(propCon : cameraDataPropogationControl)
    {
        self.propogationControl = propCon
    }
}

 

