//
//  tensorFlowCell.swift
//  blind.eye
//
//  Created by scm197 on 2/27/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit
import AVFoundation

// Holds a collection view inside it, which shows the results of the inception network running
class tensorFlowCell : UICollectionViewCell , cellProtocol , cameraDataPipe
{
    static var cell_identifer: String = "tensorFlowCell"

    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        // resize using autolayout
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.backgroundView?.backgroundColor = UIColor.white
        colView.register(outputCell.self, forCellWithReuseIdentifier: outputCell.cell_identifier)
        return colView
    }()
  
    private var ds : tensorFlowDataSource?
    
    override init(frame: CGRect)
    {
       //speechSynth = AVSpeechSynthesizer()
        
       super.init(frame: frame)
        
       setupViews()
       ds = tensorFlowDataSource(collectionView: self.collectionView) // double retention cycle. 
       self.collectionView.dataSource = ds
       self.collectionView.delegate = ds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews()
    {
        self.contentView.backgroundColor = UIColor.purple
        self.addSubview(self.collectionView)
        
       // setup the collection view
        let viewMapping = ["v0":self.collectionView]
        
        var constraints : [NSLayoutConstraint] = []
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
       
        NSLayoutConstraint.activate(constraints)
    }
   
    func pipePixelBuffer(pixelBuff: CVPixelBuffer)
    {
        self.ds?.processPixelBuffer(pixelBuff: pixelBuff)
        print("Layer 3 Pipe : Propogation Complete")
    }
    
}



