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

class RootViewController: UIViewController {

    private let cameraPreviewLayer : AVCaptureVideoPreviewLayer
    private var cameraPreviewView : UIView? = nil
    init(cameraImageLayer : AVCaptureVideoPreviewLayer)
    {
       self.cameraPreviewLayer = cameraImageLayer
        
       super.init(nibName: nil, bundle: nil)
    }
   
    // Add the camera video input layer to the view of the VC
    func setupCameraPreview()
    {
        DispatchQueue.main.async
        {
            self.cameraPreviewView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            self.cameraPreviewLayer.frame = self.cameraPreviewView!.bounds
            self.cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.cameraPreviewView!.layer.addSublayer(self.cameraPreviewLayer)
            self.view.addSubview(self.cameraPreviewView!)
        }
    }
   
    // add blue effect on top of the camera view
    func setupBlurAboveCameraPreview()
    {
        
        if !UIAccessibilityIsReduceTransparencyEnabled()
        {
            DispatchQueue.main.async
            {
               let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
               let blurView = UIVisualEffectView(effect: blurEffect)
               blurView.frame = self.view.bounds
               blurView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
                
               let button =  UIView(frame: CGRect(x: 10, y: 20, width: self.view.bounds.width - 20, height: 50))
               button.backgroundColor = UIColor.cyan
               blurView.contentView.addSubview(button)
               self.view.addSubview(blurView)
            }
           
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupCameraPreview()
        self.setupBlurAboveCameraPreview()
    }
   
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
