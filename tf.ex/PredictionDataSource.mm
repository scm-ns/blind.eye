//
//  PredictionDataSource.m
//  tf.ex
//
//  Created by scm197 on 11/19/16.
//  Copyright © 2016 scm197. All rights reserved.
//

#import "PredictionDataSource.h"

							


#include "tensorflow_utils.h"


#include <sys/time.h>

#import <memory>
#include "tensorflow/core/public/session.h"
#include "tensorflow/core/util/memmapped_file_system.h"


//#include "tensorflow_utils.h"

// Copy of google's code
// If you have your own model, modify this to the file name, and make sure
// you've added the file to your app resources too.
static NSString* model_file_name = @"tensorflow_inception_graph";
static NSString* model_file_type = @"pb";
// This controls whether we'll be loading a plain GraphDef proto, or a
// file created by the convert_graphdef_memmapped_format utility that wraps a
// GraphDef and parameter file that can be mapped into memory from file to
// reduce overall memory usage.
const bool model_uses_memory_mapping = false;
// If you have your own model, point this to the labels file.
static NSString* labels_file_name = @"imagenet_comp_graph_label_strings";
static NSString* labels_file_type = @"txt";
// These dimensions need to match those the model was trained with.
const int wanted_input_width = 224;
const int wanted_input_height = 224;
const int wanted_input_channels = 3;
const float input_mean = 117.0f;
const float input_std = 1.0f;
const std::string input_layer_name = "input";
const std::string output_layer_name = "softmax1";


@interface PredictionDataSource(internalMethods)
-(void)setupAVCapture;
-(void)tearDownAVCapture;


@end

@implementation PredictionDataSource

// tensorflow input
std::unique_ptr<tensorflow::Session> tf_session;
std::unique_ptr<tensorflow::MemmappedEnv> tf_memmapped_env;
std::vector<std::string> labels;

-(void) analyzeWithCom:(void (^)(void))block
{
    // Now analyze the image in front of us
    analyzeCurrentFrame = true;
    NSLog(@"Entering block");
    dispatch_group_enter(processImageGroup);
    dispatch_group_notify(processImageGroup ,
                          dispatch_get_main_queue(),
                          ^{
                              block(); // in the block , access the array from the data source
                          });
    
}

-(void)setupAVCapture
{
    NSError *error = nil;
    
    session = [AVCaptureSession new];
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPhone)
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    else
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *device =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput =
    [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    assert(error == nil);
    
    if ([session canAddInput:deviceInput]) [session addInput:deviceInput];
    
    
    // will ibm need the still image ? See if the video buffer can be converted into jpeg
    stillImageOutput = [AVCaptureStillImageOutput new];
    if ([session canAddOutput:stillImageOutput])
        [session addOutput:stillImageOutput];
    
    videoDataOutput = [AVCaptureVideoDataOutput new]; // Cap the video from the session
    
    NSDictionary *rgbOutputSettings = [NSDictionary //
                                       dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                       forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [videoDataOutput setVideoSettings:rgbOutputSettings]; // May be does the required convertions
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    processImageQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
 
    // set up buffering
    [videoDataOutput setSampleBufferDelegate:self queue:processImageQueue]; // The video data is put into a buffer and the class accepts them
    
    if ([session canAddOutput:videoDataOutput]) [session addOutput:videoDataOutput];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    
    [session startRunning];// shoul sessoin be released ? 
    
   
    
    if(error)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:@"Failed with error %d",
                                                 (int)[error code]]
                                  message:[error localizedDescription]
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil];
        
        [alertView show];
    }
     

}

// Setup Buffer
/*
    We do not want each image that is output from the video to be analyzed. 
    We only want to do this , when a timer goes off and the data source is said to analyze the scene
 */

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // the buffering is done within the image process queue
    // so now enter the group

    if(analyzeCurrentFrame)
    {

        analyzeCurrentFrame = false;
    
    

    
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); // get the image from the buffer
        //[self ibmPOSTRequestWithImage: pixelBuffer];

        

        [self runCNNOnFrame:pixelBuffer]; // run the cnn created from the graph
        
        
       
      
        
        // covert to ciimage then to jpeg , send to ibm watson ..
        // How to handle the threading here ? .. Create two seperate ques or dispatch into high priority ones
        
        
    }

}



// Runs Dp on the machine
- (void)runCNNOnFrame:(CVPixelBufferRef)pixelBuffer
{
    assert(pixelBuffer != NULL);
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    
    int doReverseChannels;
    // RGB format or BRG format
    if (kCVPixelFormatType_32ARGB == sourcePixelFormat)
    {
        doReverseChannels = 1;
    } else if (kCVPixelFormatType_32BGRA == sourcePixelFormat)
    {
        doReverseChannels = 0;
    } else
    {
        assert(false);  // Unknown source format
    }
    
    const int sourceRowBytes = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int fullHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0); // move the data to the cpu. else it will be in the gpu and we cannot do the requried opeations on it
    unsigned char *sourceBaseAddr = (unsigned char *)(CVPixelBufferGetBaseAddress(pixelBuffer)); // get base address of the pixel buffer
    
    int image_height;
    unsigned char *sourceStartAddr;
    if (fullHeight <= image_width) // some sort of scaling of the image occurs .
    {
        image_height = fullHeight; // what is the scaling based on ?
        sourceStartAddr = sourceBaseAddr;
    }
    else
    {
        image_height = image_width;
        const int marginY = ((fullHeight - image_width) / 2);
        sourceStartAddr = (sourceBaseAddr + (marginY * sourceRowBytes));
    }
    const int image_channels = 4;
    
    assert(image_channels >= wanted_input_channels);
    //  create a tensor of a particular size
    tensorflow::Tensor image_tensor(tensorflow::DT_FLOAT, tensorflow::TensorShape({1, wanted_input_height, wanted_input_width, wanted_input_channels}));
    
    auto image_tensor_mapped = image_tensor.tensor<float, 4>();
    
    tensorflow::uint8 *input = sourceStartAddr; // input image
    float *out = image_tensor_mapped.data();
    for (int y = 0; y < wanted_input_height; ++y)
    {
        float *out_row = out + (y * wanted_input_width * wanted_input_channels);
        for (int x = 0; x < wanted_input_width; ++x)
        {
            const int in_x = (y * image_width) / wanted_input_width;
            const int in_y = (x * image_height) / wanted_input_height;
            tensorflow::uint8 *in_pixel = input + (in_y * image_width * image_channels) + (in_x * image_channels); /// get at each pixel
            float *out_pixel = out_row + (x * wanted_input_channels);
            for (int c = 0; c < wanted_input_channels; ++c)
            {
                out_pixel[c] = (in_pixel[c] - input_mean) / input_std;
            }
        }
    }
    
    if (tf_session.get())
    {
        std::vector<tensorflow::Tensor> outputs;
        tensorflow::Status run_status = tf_session->Run({{input_layer_name, image_tensor}}, {output_layer_name}, {}, &outputs);
        
        if (!run_status.ok())
        {
            LOG(ERROR) << "Running model failed:" << run_status;
        }
        else
        {
            tensorflow::Tensor *output = &outputs[0];
            auto predictions = output->flat<float>();
            
            NSMutableDictionary *newValues = [NSMutableDictionary dictionary];
            
            for (int index = 0; index < predictions.size(); index += 1)
            {
                const float predictionValue = predictions(index);
                if (predictionValue > 0.05f)
                {
                    std::string label = labels[index % predictions.size()];
                    NSString *labelObject =
                    [NSString stringWithCString:label.c_str() encoding:NSASCIIStringEncoding];
                  //  [NSString stringWithCString:label.c_str()];
                    NSNumber *valueObject = [NSNumber numberWithFloat:predictionValue];
                    [newValues setObject:valueObject forKey:labelObject];
                }
            }
    
            // Getting the predictions will also be done in the processImageQueue
            [self setPredictionValues:newValues];
         
        }
    }
}


/*
 Obtain the prediction from the cnn and update the items with some decay ?
 
 */
- (void)setPredictionValues:(NSDictionary *)newValues
{
    const float decayValue = 0.50f;
    const float updateValue = 0.25f;
    const float minimumThreshold = 0.01f;
    
    NSMutableDictionary *decayedPredictionValues = [[NSMutableDictionary alloc] init];
    for (NSString *label in oldPredictionValues) // go through the old predictions
    {
        NSNumber *oldPredictionValueObject = [oldPredictionValues objectForKey:label];
        const float oldPredictionValue = [oldPredictionValueObject floatValue];
        const float decayedPredictionValue = (oldPredictionValue * decayValue); // calculate the predicted value by multipying with a decay value
        
        if (decayedPredictionValue > minimumThreshold) // if above threshould we add it to the current prediction
        {
            NSNumber *decayedPredictionValueObject = [NSNumber numberWithFloat:decayedPredictionValue];
            [decayedPredictionValues setObject:decayedPredictionValueObject forKey:label];
        }
    }

    oldPredictionValues = decayedPredictionValues;
    
    for (NSString *label in newValues)
    {
        NSNumber *newPredictionValueObject = [newValues objectForKey:label];
        NSNumber *oldPredictionValueObject = [oldPredictionValues objectForKey:label];
        if (!oldPredictionValueObject)
        {
            oldPredictionValueObject = [NSNumber numberWithFloat:0.0f];
        }
        
        const float newPredictionValue = [newPredictionValueObject floatValue];
        const float oldPredictionValue = [oldPredictionValueObject floatValue];
        const float updatedPredictionValue = (oldPredictionValue + (newPredictionValue * updateValue)); // combine the old and new pred values
        
        NSNumber *updatedPredictionValueObject = [NSNumber numberWithFloat:updatedPredictionValue];
        [oldPredictionValues setObject:updatedPredictionValueObject forKey:label];
    }
    // now the old pred val has both the pred and the new labels. With their probabilities adjusted properly
    
    NSArray *candidateLabels = [NSMutableArray array];
    for (NSString *label in oldPredictionValues)
    {
        NSNumber *oldPredictionValueObject = [oldPredictionValues objectForKey:label];
        const float oldPredictionValue = [oldPredictionValueObject floatValue];
        if (oldPredictionValue > 0.05f) // Check if the prediction is actually probable.
        {
            NSDictionary *entry = @
            {
                @"label" : label,
                @"value" : oldPredictionValueObject
            };
            candidateLabels = [candidateLabels arrayByAddingObject:entry];
        }
    }
    // Sort the labels in descending order
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO];
    NSArray *sortedLabels = [candidateLabels sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    // the sortedLabels are the results that we will show in the collection view .. So Now the group has stopped
    self.classes = sortedLabels;
    
    
    // the processing done in the process image is completed, hence we leave the group
        NSLog(@"Leave block");
    dispatch_group_leave(processImageGroup);
}



- (void)setup
{
    // Form the group
    processImageGroup =  dispatch_group_create();
    
    labelLayers = [[NSMutableArray alloc] init];
    oldPredictionValues = [[NSMutableDictionary alloc] init];
    
    
    
    
    tensorflow::Status load_status;
    if (model_uses_memory_mapping)
    {
        load_status = LoadMemoryMappedModel(
                                            model_file_name, model_file_type, &tf_session, &tf_memmapped_env);
    }
    else
    {
        load_status = LoadModel(model_file_name, model_file_type, &tf_session);
    }
    
    if (!load_status.ok()) {
        LOG(FATAL) << "Couldn't load model: " << load_status;
    }
    
    tensorflow::Status labels_status =
    LoadLabels(labels_file_name, labels_file_type, &labels);
    if (!labels_status.ok()) {
        LOG(FATAL) << "Couldn't load labels: " << labels_status;
    }
    [self setupAVCapture];
}

// Init loads the graphs and then sets up the avcapture
-(id)init
{
    if ( self = [super init] )
    {
        [self setup];
    }
    return self;
}



-(void)ibmPOSTRequestWithImage:(CVPixelBufferRef)img
{
    // convert CIimage to png
    CVPixelBufferLockBaseAddress(img, 0);
    UIImage * uiImg = [[UIImage alloc] initWithCIImage:[CIImage imageWithCVPixelBuffer:img]];
    CVPixelBufferUnlockBaseAddress(img, 0);
    NSData * png = UIImageJPEGRepresentation(uiImg , 1 );
 
    NSError *error;
    NSString * apiKey = @"159c911f68849fe107dbe8bf1e965980e750645d";
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sessionUrl = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURL *url = [NSURL URLWithString:@"https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"api_key", apiKey ,
                             @"image_file", png,
                             nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [sessionUrl dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSLog(@"%@" ,data);
        NSLog(@"%@" ,error);
       
    }];
    
    [postDataTask resume];
    
    
    
}




@end
