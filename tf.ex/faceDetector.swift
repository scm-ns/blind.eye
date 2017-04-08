//
//  faceDetector.swift
//  blind.eye
//
//  Created by scm197 on 4/7/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit
import CoreImage
import CoreGraphics
import ImageIO

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
    
    // for now, transfer the data using an array of UIImage which will be shown on a cell

    let faceDectectionEngine : CIDetector! =
    {
        let context = CIContext()
        let dectectorOpt = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        return CIDetector(ofType: CIDetectorTypeFace, context: context, options: dectectorOpt)
    }()
   
    public var faces : [UIImage] = [] // Store directly as UIImage, so that the processing is done here.

    override init()
    {
        super.init()
    }
    
}

extension faceDetector
{
    public func processImage(ciImage : CIImage) // synchronous call, block till images are found
    {
        
        // Convert the given the CIImage into CGImage, as cropping the faces from the image requires a CGImage
        let ciContext = CIContext() // context is reqired from the conversion from CIImage to CGImage
        let cgImageRef = ciContext.createCGImage(ciImage  , from : ciImage.extent)
        
        guard let cgImageRef_ = cgImageRef else
        {
            print("Failed in image conversion")
            return
        }
        
        // Get the face bounds for the faces in the image
        let detectorOpt = [CIDetectorImageOrientation : ciImage.properties[kCGImagePropertyOrientation as String]];
        let features = faceDectectionEngine.features(in: ciImage, options: detectorOpt)
       
        // TODO : Is there a more efficient way to do this ?
        
        for feature in features
        {
            // get the bounds of the face
            let faceRect = feature.bounds // will the bounds be enough. Don't they describe face within its own coordinate system
        
            // get the subimage of the large image corresponding to the face
            let faceCGImageRef =  cgImageRef_.cropping(to: faceRect)
            guard let faceCGImageRef_ = faceCGImageRef else
            {
               continue
            }
            
            faces.append(UIImage(cgImage: faceCGImageRef_))
            // No need to realease ref in Swift(only) as now managed by ARC
            
        }
        
    }
    
    //internal func
}




