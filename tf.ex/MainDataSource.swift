//
//  MainDataSource.swift
//  blind.eye
//
//  Created by scm197 on 3/20/17.
//  Copyright © 2017 scm197. All rights reserved.
//



// Holds the different sections, where each of the them will be a collection view
// Register cells
// the mainDataSource is just a container. It has ntohgint to load.
// It will just hold the different sections, correponding to the different types of sections
// with cells in them.
class mainDataSource: NSObject, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
{
    
    private let cellSource = cellRegistrar()
    private let colView : UICollectionView // TODO : Coupling between the data Source and VC. Break them out
    
    var cameraDataTranports: [cameraDataTransport] = [] // cameraDataPipe Protocol
    var soundDataTransports: [soundDataTransport] = [] // soundPipe Protocol
    
    init(colView : UICollectionView , soundDataCarrier : soundDataTransport)
    {
        self.colView = colView
        super.init()
        
        // remove this tight binding. 
        // Pass in as a parameter ? Then the Main VC will know about.
        // I want to suppress the knowldege of the cell types within the data source and not expose 
        // it to the VC
       
        // This will add the cell type to a cell source.
        // The cell source will register this cell with its indetifier according to the cellProtocol protocol
        cellSource.registerCell(cell:tensorFlowCell.self as cellProtocol.Type )
        cellSource.registerCell(cell: faceDetectorCell.self as cellProtocol.Type)


        
        cellSource.configColView(colView: colView)
        
        self.addSoundTransport(transport: soundDataCarrier)
    }
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1; 
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return cellSource.numberOfCellTypes();
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell_identifier = cellSource.itemAtIndex(index: indexPath.row).cell_identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identifier,for: indexPath)
        
        if let cell_cam = cell as?  cameraDataPipe
        {
            // pass on data
            self.addCameraTransport(transport: cell_cam )
        }
       
        if let cell_sound = cell as? soundDataPipe
        {
           cell_sound.addSoundTransport(transport: self as soundDataTransport)
        }
        
        return cell 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            return CGSize(width: (collectionView.bounds.width), height: 200)
    }
   
   
   
}

// This is slighty more complex than a pipe, as it does some distribution to different types of cells
// Do I keep an array of cells. How to handle this ?
// Do I keep view models for the cells which will be passed these items ?
// How to pass data to the cells ?

// Act as a pipe for tranmitting the camera buffer data
extension mainDataSource: cameraDataPipe
{
    func pipePixelBuffer(pixelBuff: CVPixelBuffer)
    {

        for  tranport in self.cameraDataTranports
        {
            if let sink = tranport as? cameraDataSink
            {
                sink.processPixelBuffer(pixelBuff: pixelBuff)
                print("Layer 4: Sink: CameraData Propogation Complete")
            }
            else if let pipe = tranport as? cameraDataPipe
            {
                pipe.pipePixelBuffer(pixelBuff: pixelBuff)
                print("Layer 4: Pipe: Camera Data Propogation Complete")
            }
            else
            {
                print("Layer 4 : Camera Data Propogation Failed")
            }
            
        }

    }
   
    func addCameraTransport(transport: cameraDataTransport)
    {
       self.cameraDataTranports.append(transport)
    }
}




extension mainDataSource : soundDataPipe
{
    func pipeSound(str : String)
    {
        for transport in self.soundDataTransports
        {
            if let sink = transport as? soundDataSink
            {
                sink.processSound(str: str)
                print("Layer 1 Sink : Sound Propogation Complete")
            }
            else if let pipe = transport as? soundDataPipe
            {
                pipe.pipeSound(str: str)
                print("Layer 1 Pipe : Sound Propogation Complete")
            }
            else
            {
                print("Layer 1 : Sound Propogation Failed")
            }
        }
    }
    
    func addSoundTransport(transport : soundDataTransport)
    {
        self.soundDataTransports.append(transport)
    }
}

