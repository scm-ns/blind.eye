//
//  CommonProtocols.swift
//  blind.eye
//
//  Created by scm197 on 3/20/17.
//  Copyright © 2017 scm197. All rights reserved.
//

/*
    Camera Image Source 
    What is the difference between a pipe and a sink
    A pipe is not the end point.
    It might do some transformations, but it passes it upwards.
 */
protocol cameraDataTransport // Does nothing. Allows abstraction between the two different types of
    // transfers
{
}

protocol cameraDataSink : cameraDataTransport
{
    func processPixelBuffer(pixelBuff : CVPixelBuffer)
}

protocol cameraDataPipe : cameraDataTransport
{
    func pipePixelBuffer(pixelBuff : CVPixelBuffer) // Move from using the pixel buffer into something less constraied. 
    func addCameraTransport(transport : cameraDataTransport)
    var cameraDataTranports : [cameraDataTransport] {get set}
}

protocol cameraDataSource : cameraDataTransport
{
    func propogateCameraData(pixelBuffer : CVPixelBuffer)
    func addCameraTransport(transport : cameraDataTransport)
    var cameraDataTranports : [cameraDataTransport] {get set}
}


/*
        delegate used to control whether the camera data is 
 
*/
protocol cameraDataPropogationControl
{
    func isRunning() -> Bool
    func stopPropogation()
    func restartPropogation() // restart and not start as default behaviour is automatic propogation
}

/*
    delegate used to configure the class which will control the propogation
*/
protocol cameraDataPropogationController
{
    func configurePropogationController(propCon : cameraDataPropogationControl)
}



/////////////////////////////////


// Sound propogation Architechture

/*
    Uses a system similar to camera data propogation.
    The data will be a string. This will be passed on from every object which was a camera sink as
    that is where the object is indentified, into a root node, which will handle the task of converting the
    text to sound. 
    Essentially, the data will travel from the nodes back to the root.
 
 */

protocol soundDataTransport
{
}

protocol soundDataSink : soundDataTransport
{
    func processSound(str : String)
}

protocol soundDataPipe : soundDataTransport
{
    var soundDataTransports: [soundDataTransport] {get set}
    func addSoundTransport(transport : soundDataTransport)
    func pipeSound(str : String)
}


protocol soundDataSource // extend the source to support multiple sinks/pipes
{
    var soundDataTransports: [soundDataTransport] {get set}
    func addSoundTransport(transport : soundDataTransport)
    func propogateSound(str : String)
}

