//
//  MainView.swift
//  tf.ex
//
//  Created by scm197 on 11/19/16.
//  Copyright © 2016 scm197. All rights reserved.
//

import UIKit
import AVFoundation

class MainView: UICollectionViewController
{

    var ds : PredictionDataSource? 
    var analyzeImageTimer : Timer?
    
    let synth = AVSpeechSynthesizer()

    private let reuseIdentifier = "Cell"

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        ds  = PredictionDataSource.init() // Load the data source 

        analyzeImageTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(MainView.analyze), userInfo: nil, repeats: true)
        // Set up the timer , which will call the data source every 500 ms to load the images again 
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.backgroundColor = UIColor.white
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    func analyze() // call ever 500 ms
    {
        ds?.analyze(com: { 
            self.collectionView?.reloadData()
        })
    }
    
   // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        // if data ds has no classes
        if let cla = self.ds?.classes
        {
            return cla.count
        }
        else
        {
            return 0;
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        cell.backgroundColor = UIColor.red
        
        let dict = self.ds?.classes[indexPath.row] as! NSDictionary
  
        self.speak(str: dict["label"]! as! String)
      
    
        
        print( dict["label"]! )
        return cell
    }

    
    func speak(str : String)
    {

        // Create utterance object with text and pass it to the synthesizer
        let utterance = AVSpeechUtterance(string: str)
        
        // Set rate and language
        utterance.rate = 0.3
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synth.speak(utterance)
        
    }
    
    
}
