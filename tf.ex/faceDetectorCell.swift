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
 
 */
class faceDetectorCell : UICollectionViewCell , cellProtocol , cameraData
{
    static var cell_identifer : String = "faceDetectorCell"
    
    func pipePixelBuffer(pixelBuff: CVPixelBuffer) {
       
        // Pass it into a data source which will do the face recognition and get back the bounds for the face recognition
        
    }
}


class faceDetectorDataSource : 
