//
//  faceDetectorDataSource.swift
//  blind.eye
//
//  Created by scm197 on 4/8/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit

/*
    Basic idea of the cell is that it will pass the pixel data to the faceDetector,
    which will process and find the faces and return is back as an array. 
 
    Then after this array has been set after the proceess of the image has been done, 
    the collectionView will be reloaded.
    When this colView will call is delegate methods I will pass the faces back to the col view,
    wrapped in a col view cell
    
 
 
 */


class faceDetectorDataSource : NSObject
{
    fileprivate let colView : UICollectionView // used for registering the cells
    
    fileprivate let faceDS : faceDetector // DS = Data Source
    
    init(collectionView : UICollectionView)
    {
        colView = collectionView
        faceDS = faceDetector()
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
        let vm : faceCellViewModel = faceCellViewModel(faceImage: image)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: faceCell.cell_identifier, for: indexPath) as! faceCell
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
                self.faceDS.processImage(ciImage: CIImage(cvPixelBuffer: pixelBuff))
                DispatchQueue.main.async
                {
                        self.colView.reloadData()
                        print("analyziz image")
                }
                print("Layer 6 Sink : Propogation Complete")
        }
    }
    
}




