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
 
    What will be the different UI Elements
    A red Button at the top
 
 
 */

class RootViewController: UIViewController {

    private let cameraPreviewLayer : AVCaptureVideoPreviewLayer
    private var cameraPreviewView : UIView? = nil
    private lazy var blurOverLay : UIVisualEffectView =
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        return blurView
    }()
    private lazy var mainVC: MainVC = MainVC()
    
    
    init(cameraImageLayer : AVCaptureVideoPreviewLayer)
    {
       self.cameraPreviewLayer = cameraImageLayer
        
       super.init(nibName: nil, bundle: nil)
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
                
               let button =  UIView(frame: CGRect(x: 10, y: 20, width: self.view.bounds.width - 20, height: 50))
               button.backgroundColor = UIColor.cyan
               self.blurOverLay.contentView.addSubview(button)
        }
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // set up the preview and blur
        self.setupCameraPreview()
        self.setupBlurAboveCameraPreview()
        self.setupMainVC()
        
        
        self.view.addSubview(self.blurOverLay)
    }
   
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
