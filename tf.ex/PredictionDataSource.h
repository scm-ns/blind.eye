//
//  PredictionDataSource.h
//  tf.ex
//
//  Created by scm197 on 11/19/16.
//  Copyright © 2016 scm197. All rights reserved.
//
#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*
    TO DO : 
            The neural network has to be trained on relevant data.
            But this has to be done on the aws server
 
 */



/*
 
    How to architect for efficinecy and clean code ?
 
 
    imageProcessorProtocol              Starts off the different pipelines, where diffirent types
        (Data Source)                   of objects are recognize    
                                        The classes which conform to this would be the different data sources 
        ^                               feeding different UI Elements
         |
 
    video source                        Interfaces with the apple system and obtains the
                                        frames that are seen by the camera
         ^                              The frames are then send to different imageProcessorProtocol 
                                        conforming classes which starts off the different pipelines
                                        where different objects are recognized.
                    
                                        
 
     Speed of processing controled        classes conforming to the
     by a variable at the end of          pro
     pipeline where the outputs
     are displayed
 
 
 */



// We do not need a video data output. We only need the prediction.
/**
    Also the prediction does not have to be done on every image.
    It can be done every 0.5 ms./ or any other arbitary time period
    I should update the datasource so that, every 0.5ms the current frame is used to do the 
    predictoin and this is displayed in the collectoin view
 */
@interface PredictionDataSource : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    
    // To store the data variables
    NSMutableDictionary *oldPredictionValues;
    NSMutableArray *labelLayers;
    
    bool analyzeCurrentFrame; ; // this should be false , and is set to be true only when the data needs to be analyzed
}

// Do the processing part .. This is a synchronze call. Takes some time to
// process the image and store the name of the object in the NSArray classes
- (void)runCNNOnFrame:(CVPixelBufferRef)pixelBuffer;

// Holds the sorted classes , which we will be showing in the collection view
// TO DO : IS NsArray thread safe ? How to make this more thread safe ?
//          May be this is not really required as I will access this array only after the
//          runCNNOnFrame function has been done
@property (nonatomic) NSArray * classes;


@end
