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
        delegate used to control whether the camera data is  being propogated
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
protocol cameraDataPropogationControlConfigurator
{
    func configurePropogationController(propCon : cameraDataPropogationControl)
}

// Delegate and setup for controlling the text 2 speech feature
protocol soundControl
{
    func stopSound()
    func allowSound()
}

protocol  soundControlConfigurator
{
    func configureSoundController(soundCon : soundControl)
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


/*
open class baseColViewCell : UICollectionViewCell
{
    open var isCancelled: Bool { get }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 */



public protocol cellProtocol
{
    static var cell_identifier : String { get }
}


/*
 
    cell provider : The naming is not good enough. 
    This is supposed to register the collection view with the differetn types fo cells. 
 
    So a data source should implement the protocol and the collection view should be registerd ? 
 
 */
class  cellRegistrar
{
    private var cells : [cellProtocol.Type]
    
    init()
    {
        cells = []
    }
   
    func registerCell(cell : cellProtocol.Type)
    {
        cells.append(cell)
    }
    
    func configColView(colView : UICollectionView)
    {
        cells.map
        {
            (cell) in
            colView.register(cell.self as! UICollectionViewCell.Type, forCellWithReuseIdentifier: cell.cell_identifier)
            
        }
    }

    func numberOfCellTypes() -> Int
    {
       return cells.count
    }
   
    // TODO: scm197 make extraction safer
    func itemAtIndex(index : Int) -> cellProtocol.Type
    {
        return cells[index]
    }
    
}
