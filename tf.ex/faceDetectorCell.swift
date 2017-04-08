//
//  faceDetectorCell.swift
//  blind.eye
//
//  Created by scm197 on 3/18/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit
import CoreImage


/*
    This class takes in the camera data in the form of the pixel buffer and does 
    face recognition of the pixel buffer
 
    How to share the pixel buffer between multiple consumers ?
 
    It is GPU data, but I am locking it and keeping it in the CPU.
    But since I am not writing to it, I should be able to use it from multiple threads.
 
    Relation between the cell and the data source. 
    Only the cell will know of the data source. 
    So the cell will act as pipe and will be passed in data which will be given to the data source
 
 */
class faceDetectorCell : UICollectionViewCell , cellProtocol 
{
    static var cell_identifer : String = "faceDetectorCell"
    fileprivate let ds : faceDetectorDataSource// Face detector details
   
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let colView = UICollectionView(frame: CGRect.zero , collectionViewLayout: layout)
        colView.translatesAutoresizinbMaskIntoContrsints = false
        
        return colView
    }
    
    var cameraDataTranports: [cameraDataTransport] = [] // cameraDataPipe Protocol
  
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        ds = faceDetectorDataSource(collectionView : collectionView)
        
        self.collectionView.dataSource = ds
        self.collectionView.delegate = ds
    }
    
   
    required init?(coder aDecoder : NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
   
}

extension faceDetectorCell : cameraDataPipe
{
    
    func pipePixelBuffer(pixelBuff: CVPixelBuffer)
    {
        // Pass it into a data source which will do the face recognition and get back the bounds for the face recognition
        // Do I really need another seperation. Yes, More modularity. This data source is acting both as a piping
        // system and also as a data soruce for collection view. // I can break it down even more
        
    }
    
    func addCameraTransport(transport: cameraDataTransport)
    {
       self.cameraDataTranports.append(transport)
    }
    
}


class faceDetectorDataSource : NSObject
{
    fileprivate let colView : UICollectionViewCell // used for registering the cells
    
    fileprivate let faceDS : faceDectector // DS = Data Source
    
    init(collectionView : UICollectionView)
    {
            colView = collectionView
            faceDS = faceDectector()
            super.init()
        
    }
    
    
}

extension faceDetectorDataSource : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
           return CGSize(width: 50, height: 50)
    }
}


extension faceDetectorDataSource : UICollectionViewDelegate
{
    
}

extension faceDetectorDataSource : UICollectionViewDataSource
{
  
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // This should return 0 , until, the pixelBuff has been proceed and the faces decteced
        // The detected faces will be stored in an array for now.
        return faceDS.faces.count;
        
    }
    
    func collectionView(_ collectionView: UICollectionView , cellForItemAt indexPath : IndexPath) -> UICollectionViewCell
    {
        // Each cell should be a cell with a face on it.
        // TO DO :
        
        // create a simple cell which will just show the face. Adding the circular style to the cell
        let image = faceDS.faces[indexPath.row]
        let vm : faceCellViewModel = faceCellViewModel(image)
       
        let cell = collectionView.dequeReusableCell(withReuseIdentifier: faceCell.cell_identifer, for: indexPath) as! faceCell
        cell.viewModel = vm // set the view model, which will set the face image
       
        return cell
    }
    
    
}


extension faceDetectorDataSource: cameraDataSink
{
 
    func processPixelBuffer(pixelBuff: CVPixelBuffer)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            self.faceDS.processImage(CIImage(pixelBuffer:pixelBuff))
            DispatchQueue.main.async
            {
                    self.colView.reloadData()
                    print("analyziz image")
            }
            print("Layer 6 Sink : Propogation Complete")
        }
    }
    
}




