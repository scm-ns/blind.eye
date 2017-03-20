//
//  MainView.swift
//  blind.eye
//
//  Created by scm197 on 11/19/16.
//  Copyright © 2016 scm197. All rights reserved.
//

// UI Description
// There is going to be a single view at the top . standard ui view.
//     view
//       | - collectionView
//               | -  subCell : view
//                       | - headerView - bell view
//                       | - collectionView
//                              |  - ItemCell :  UICollectionViewCell
//                                      | - Image
//                                      | - Label
//

import UIKit
import AVFoundation


class MainVC : UIViewController
{
 
    private let mainCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        // resize using autolayout
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.backgroundColor = UIColor.clear
        //colView.register(tensorFlowCell.self, forCellWithReuseIdentifier: tensorFlowCell.cell_identifer)
        return colView
    }()
    
    private var ds: mainDataSource! = nil
    
    var cameraDataTranports: [cameraDataTransport] = [] // cameraDataPipe Protocol
    var soundDataTransports: [soundDataTransport] = [] // soundPipe Protocol
    
    // MARK -: Initialization
    init()
    {
        super.init(nibName: nil, bundle: nil)
        print(self.view)
        self.view.backgroundColor = UIColor.clear
        
        self.ds = mainDataSource(colView: self.mainCollectionView ,soundDataCarrier: self as soundDataTransport)
        
        self.mainCollectionView.dataSource = self.ds
        self.mainCollectionView.delegate = self.ds
        
        self.addCameraTransport(transport: self.ds as cameraDataTransport)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK -: Setup Views
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupView()
        print(self.view)
    }
   
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let duration = 0.5
        
        UIView.animate(withDuration: duration, animations:
        {
                self.mainCollectionView.alpha = 1
        },
        completion :
        {
            (val) in
                print("animation complete \(val)")
        })
        
    }
    
    func setupView()
    {
        // layout main collectoinview
        self.view.addSubview(self.mainCollectionView)
        
        let viewMapping = ["v0":self.mainCollectionView]
        var constraints : [NSLayoutConstraint] = []
        constraints.append(contentsOf:   NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: [:], views: viewMapping) )
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        NSLayoutConstraint.activate(constraints)
    }
    
}


// Act as a pipe for tranmitting the camera buffer data
extension MainVC: cameraDataPipe
{
    func pipePixelBuffer(pixelBuff: CVPixelBuffer)
    {

        for  tranport in self.cameraDataTranports
        {
            if let sink = tranport as? cameraDataSink
            {
                sink.processPixelBuffer(pixelBuff: pixelBuff)
                print("Layer 3 : Sink: CameraData Propogation Complete")
            }
            else if let pipe = tranport as? cameraDataPipe
            {
                pipe.pipePixelBuffer(pixelBuff: pixelBuff)
                print("Layer 3 : Pipe: Camera Data Propogation Complete")
            }
            else
            {
                print("Layer 3 : Camera Data Propogation Failed")
            }
            
        }

    }
   
    func addCameraTransport(transport: cameraDataTransport)
    {
       self.cameraDataTranports.append(transport)
    }
}


extension MainVC : soundDataPipe
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

