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


// We do not need a video data output. We only need the prediction.
/**
    Also the prediction does not have to be done on every image.
    It can be done every 0.5 ms.
    I should update the datasource so that, every 0.5ms the current frame is used to do the 
    predictoin and this is displayed in the collectoin view
 */
@interface PredictionDataSource : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    // To manage the camera interface
    dispatch_queue_t videoProcessingQueue;
    AVCaptureSession * session;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t processImageQueue;
    dispatch_group_t processImageGroup;
    
    // To store the data variables
    NSMutableDictionary *oldPredictionValues;
    NSMutableArray *labelLayers;

    
    bool analyzeCurrentFrame; ; // this should be false , and is set to be true only when the data needs to be analyzed
}

-(void)setup ; // Call set up before doing anything else

/*
    async function. Will return immediately, but the work will be done in the background and on completion the
    completion block will be called on the main thread. Only do UI task in the blcok
 
 */
-(void)analyzeWithCom: (void(^)(void))block ; 
// Holds the sorted classes , which we will be showing in the collection view
@property (nonatomic) NSArray * classes;


@end
