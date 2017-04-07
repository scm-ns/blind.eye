//
//  faceDetector.swift
//  blind.eye
//
//  Created by scm197 on 4/7/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit
import CoreImage

/*
    Architecture :
            This class will be passed in an image. It should give back smaller images, representing the
            defferent faces in the input image. The location of the face in the image is not returned
 */

protocol imageProcessor
{
    
}



class faceDetector : NSObject
{
    let faceDectectionEngine : CIDetector! =
    {
        let context = CIContext()
        let dectectorOpt = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        return CIDetector(ofType: CIDetectorTypeFace, context: context, options: dectectorOpt)
    }()
    
    override init()
    {
        super.init()
    }
   
    
}

