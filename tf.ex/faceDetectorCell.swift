//
//  faceDetectorCell.swift
//  blind.eye
//
//  Created by scm197 on 3/18/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit
import CoreImage


/*
    This class takes in the camera data in the form of the pixel buffer and does 
    face recognition of the pixel buffer
 
    How to share the pixel buffer between multiple consumers ?
 
    It is GPU data, but I am locking it and keeping it in the CPU.
    But since I am not writing to it, I should be able to use it from multiple threads.
 
    Relation between the cell and the data source. 
    Only the cell will know of the data source. 
    So the cell will act as pipe and will be passed in data which will be given to the data source
 
 */
class faceDetectorCell : UICollectionViewCell , cellProtocol 
{
    static var cell_identifier : String = "faceDetectorCell"
    fileprivate let ds : faceDetectorDataSource// Face detector details
   
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let colView = UICollectionView(frame: CGRect.zero , collectionViewLayout: layout)
        colView.translatesAutoresizingMaskIntoConstraints = false
        
        return colView
    }()
    
    var cameraDataTranports: [cameraDataTransport] = [] // cameraDataPipe Protocol
  
    override init(frame: CGRect)
    {
        ds = faceDetectorDataSource(collectionView : collectionView)
        
        
        super.init(frame: frame);
        
        self.collectionView.dataSource = ds
        self.collectionView.delegate = ds
        
        // add the data source to the data pipeline
        self.addCameraTransport(transport: ds)
    }
    
   
    required init?(coder aDecoder : NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
   
}

extension faceDetectorCell : cameraDataPipe
{
    
    func pipePixelBuffer(pixelBuff: CVPixelBuffer)
    {
        // Pass it into a data source which will do the face recognition and get back the bounds for the face recognition
        // Do I really need another seperation. Yes, More modularity. This data source is acting both as a piping
        // system and also as a data soruce for collection view. // I can break it down even more
        
        // TODO : Tech Debt : This fucntion is repeated everywhere. Implement it in the protocol iteself as a mixin ? // default extension
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
