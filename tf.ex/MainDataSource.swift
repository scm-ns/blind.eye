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
    
    init(colView : UICollectionView)
    {
        self.colView = colView
        super.init()
        cellSource.registerCell(cell:tensorFlowCell.self as cellProtocol.Type )
        cellSource.configColView(colView: colView)
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
        let cell_identifier = cellSource.itemAtIndex(index: indexPath.row).cell_identifer
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identifier,for: indexPath)  as! cameraDataPipe
      
        // pass on data
        self.addCameraTransport(transport: cell)

        return cell as! UICollectionViewCell
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





