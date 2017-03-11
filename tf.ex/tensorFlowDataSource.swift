//
//  tensorFlowDataSource.swift
//  blind.eye
//
//  Created by scm197 on 3/10/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit

/*
        This class due to its conformance of the cameraDataSink and addition to the RootCoordinator, 
        will be passed in a pixelBuffer periodically by an interval selected by the RootCoordinator
 
    The function of this class is simply to work together with the predictionDataSource to obtain predictions
    for a given pixel Buffer and give it to the collection View controller when it asks for it

 */


class tensorFlowDataSource : NSObject , UICollectionViewDataSource , UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout , cameraDataSink
{
    // this has to be some sort of delegate that is implmented.
    /// I need to create a protocl which can handle the talking between the machien learning part and the data soruce part
    
    // architecture question : I need to make sure that I am implementing things properly.
    // I do not want to give access to the ml part to the view controller. I just need to make sure that
    // the collection view has be reloated when the prediction data source has completed functioning.
    // I need the timer to be part of the data source and not the view controller.
    // The best way to do this , is by using a reference ot the vc and called reload of it when the data has been laoded
    
    private let ds : PredictionDataSource
    private let colView : UICollectionView
 
    // cache for storing the view models and for selecting items.
    private var cache : [String : outputCellViewModel]
   
    init(collectionView : UICollectionView)
    {
       /// TO DO : The data source can be different based on the type of algorithm that is being run
       /// Each Alogorithm will have its own data source. 
       /// All the different types of data source will conform to a single protocol
       /// The Protocol should have a 
                        /// basic analyze completion handler.
                        /// Standard Data Source methods for predictions etc
        ds  = PredictionDataSource() // Load the data source
        colView = collectionView
        cache = [:]
        
        super.init()
    }
   
    /// Single Section for each Cell
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1 ;
    }
   
   
    /// Number of items are based on the number of classes that have been detected by the algorithm
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
         // if data ds has no classes
        if let cla = self.ds.classes
        {
            print("number of items detected \(cla.count)")
            return cla.count
        }
        else
        {
            return 0;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
            let dict : NSDictionary = (self.ds.classes[indexPath.row] as! NSDictionary)
        
            let keyStr = dict.object(forKey: "label") as? String
      
            var viewModel : outputCellViewModel
        
            if let key = keyStr
            {
                if let vm = cache[key]
                {
                        viewModel = vm
                }
                else
                {
                    let vm = outputCellViewModel(label: keyStr)
                    cache[key] = vm
                    viewModel = vm
                }
                
            }
            else
            {
                    viewModel = outputCellViewModel(label: nil)
            }
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: outputCell.cell_identifier, for: indexPath) as! outputCell
            cell.viewModel = viewModel
        
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 50, height: 50)
    }

    // MARK:- Delegate methods to handle touch

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true // select all the different cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: outputCell.cell_identifier, for: indexPath) as! outputCell
      
        // animate cell selection
        UIView.animate(withDuration: 0.5)
        {
            cell.backgroundColor = UIColor.cyan
        }
       
        // now speak the item
        if let str = cell.viewModel?.labelStr
        {
            
        }
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
    }

    func processPixelBuffer(pixelBuff: CVPixelBuffer)
    {
        DispatchQueue.global(qos: .background).async
        {
            self.ds.runCNN(onFrame: pixelBuff)
            DispatchQueue.main.async
            {
                    self.colView.reloadData()
                    print("analyziz image")
            }
            print("Layer 3 Sink : Propogation Complete")
        }
    }
    
    
}
