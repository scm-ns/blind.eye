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
class faceDetectorCell : UICollectionViewCell , cellProtocol , cameraData
{
    static var cell_identifer : String = "faceDetectorCell"
    
    func pipePixelBuffer(pixelBuff: CVPixelBuffer) {
       
        // Pass it into a data source which will do the face recognition and get back the bounds for the face recognition
        
    }
}

class faceDetectorDataSource : NSObject
{
    fileprivate let ds : faceDetectorDataSource// Face detector details
    fileprivate let colView : UICollectionViewCell // used for registering the cells
    
   
    init(collectionView : UICollectionView)
    {
            ds = faceDetectorDataSource()
            colView = collectionView
            super.init()
        
    }
    
    
}

extension faceDetectorDataSource : UICollectionViewDelegateFlowLayout
{
    
    
}


extension faceDetectorDataSource : UICollectionViewDelegate
{
    
}

extension faceDetectorDataSource : UICollectionViewDataSource
{
  
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    
    
    
    
    
    
    
    
    
}




extension faceDetectorDataSource: cameraDataSink
{
 
    func processPixelBuffer(pixelBuff: CVPixelBuffer)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            //self.ds.runCNN(onFrame: pixelBuff) // Find the faces
            DispatchQueue.main.async
            {
                    self.colView.reloadData()
                    print("analyziz image")
            }
            print("Layer 6 Sink : Propogation Complete")
        }
    }
    
}


