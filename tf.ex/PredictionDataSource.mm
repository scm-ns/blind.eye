//
//  PredictionDataSource.m
//  tf.ex
//
//  Created by scm197 on 11/19/16. Nope : Based on GOOG code from tensorflow
//

#import "PredictionDataSource.h"

// Based on Google's Code

#include <sys/time.h>
#import <memory>

// tensorflow dependencies
#include "tensorflow_utils.h"
#include "tensorflow/core/public/session.h"
#include "tensorflow/core/util/memmapped_file_system.h"


// Model details
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
@end

@implementation PredictionDataSource

// tensorflow input
std::unique_ptr<tensorflow::Session> tf_session;
std::unique_ptr<tensorflow::MemmappedEnv> tf_memmapped_env;
std::vector<std::string> labels;

// Init loads the graphs and then sets up the avcapture
-(id)init
{
    if ( self = [super init] )
    {
        [self setup];
      
        NSLog(@"init prediction data source ");
        
        _classes = nil;
        oldPredictionValues = nil;
    }
    return self;
}

// Loads the file and setups varaibles
-(void)setup
{
    
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
    if (!labels_status.ok())
    {
        LOG(FATAL) << "Couldn't load labels: " << labels_status;
    }
    
}

/*
    When I work on the pixelBuffer I cannot access it from other threads ?
        Or is the concept something else. I can access it from other threads but only on the CPU side. 
        The buffer is located on the GPU side.
 
 */
// Runs Dp on the machine
- (void)runCNNOnFrame:(CVPixelBufferRef)pixelBuffer // We are acting directly on the buffer. Is there a better way here. 
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
    
    const int sourceRowBytes = (int)CVPixelBufferGetBytesPerRow(pixelBuffer); // martixRowSize
    const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer); // matrixNumCols
    const int fullHeight = (int)CVPixelBufferGetHeight(pixelBuffer); // matrixNumRows
    
    // move the data to the cpu. else it will be in the gpu and we cannot do the requried opeations on it
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
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
    
}

@end
