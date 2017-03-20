//
//  tensorFlowCell.swift
//  blind.eye
//
//  Created by scm197 on 2/27/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit
import AVFoundation

// Holds a collection view inside it, which shows the results of the inception network running
class tensorFlowCell : UICollectionViewCell , cellProtocol
{
    static var cell_identifer: String = "tensorFlowCell"
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        // resize using autolayout
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.backgroundColor = UIColor.clear
        colView.register(outputCell.self, forCellWithReuseIdentifier: outputCell.cell_identifier)
        return colView
    }()
  
    fileprivate var ds : tensorFlowDataSource!
   
    fileprivate var soundTransport : soundDataTransport? = nil
    
    var cameraDataTranports: [cameraDataTransport] = [] // cameraDataPipe Protocol
   
    override init(frame: CGRect)
    {
       super.init(frame: frame)
        
       setupViews()
       ds = tensorFlowDataSource(collectionView: self.collectionView , soundDataCarrier: self as soundDataPipe) // double retention cycle.
      
       addCameraTransport(transport: self.ds as cameraDataTransport)
        
       self.collectionView.dataSource = ds
       self.collectionView.delegate = ds
    }
   
    func setTransport(transport : soundDataTransport)
    {
        self.soundTransport = transport
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews()
    {
        self.addBorder()
        self.addSubview(self.collectionView)
        
       // setup the collection view
        let viewMapping = ["v0":self.collectionView]
        
        var constraints : [NSLayoutConstraint] = []
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
       
        NSLayoutConstraint.activate(constraints)
    }
  
    private func addBorder()
    {
        let view = self.contentView
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
        
        
    }
   
}

// Act as a pipe for tranmitting the camera buffer data
extension tensorFlowCell : cameraDataPipe
{
    func pipePixelBuffer(pixelBuff: CVPixelBuffer)
    {

        for  tranport in self.cameraDataTranports
        {
            if let sink = tranport as? cameraDataSink
            {
                sink.processPixelBuffer(pixelBuff: pixelBuff)
                print("Layer 5 Sink: CameraData Propogation Complete")
            }
            else if let pipe = tranport as? cameraDataPipe
            {
                pipe.pipePixelBuffer(pixelBuff: pixelBuff)
                print("Layer 5 Pipe: Camera Data Propogation Complete")
            }
            else
            {
                print("Layer 5 : Camera Data Propogation Failed")
            }
            
        }

    }
   
    func addCameraTransport(transport: cameraDataTransport)
    {
       self.cameraDataTranports.append(transport)
    }
}


extension tensorFlowCell : soundDataPipe
{
    func pipeSound(str : String)
    {
        guard let transport = self.soundTransport else
        {
           return
        }
       
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
