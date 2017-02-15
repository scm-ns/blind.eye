//
//  MainView.swift
//  blind.eye
//
//  Created by scm197 on 11/19/16.
//  Copyright © 2016 scm197. All rights reserved.
//

// UI Description
// There is going to be a single view at the top . standard ui view.
//     view
//       | - collectionView
//               | -  subCell : view
//                       | - headerView - bell view
//                       | - collectionView
//                              |  - ItemCell :  UICollectionViewCell
//                                      | - Image
//                                      | - Label
//


import UIKit
import AVFoundation



class MainView: UICollectionViewController , UICollectionViewDelegateFlowLayout
{

    var analyzeImageTimer : Timer!
    var dataSource : MainDataSource!

    private let reuseIdentifier = "Cell"

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        analyzeImageTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(MainView.analyze), userInfo: nil, repeats: true)
        // Set up the timer , which will call the data source every 500 ms to load the images again 
       
        dataSource = MainDataSource();
        dataSource.register(collecionView: self.collectionView!)
        
        
        self.collectionView!.backgroundColor = UIColor.white
        
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
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
        
  
      
    
        
        return cell
    }

    
   
    
}

/// Will decide the order in which the results of differenet algorithms wrapped in seperate data souce is displayed
class MainDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , UICollectionViewDelegate
{
    private let cell_identifier = "nested_cell"
   
    func register(collecionView: UICollectionView)
    {
        collecionView.register(SubCellView.self, forCellWithReuseIdentifier: cell_identifier)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    /// Determines the number of different algorithms that will be run
    /// Keep an array of data source objects refering to the different algorithms and they will be used in the init process of the different
    /// cells.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
   
    /// Creates the different Cells prepresenting the different algorithms
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identifier, for: indexPath)
       
        let dict = self.ds?.classes[indexPath.row] as! NSDictionary
        self.speak(str: dict["label"]! as! String)
        return cell;
        
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

/// This cell will be placed in collection view for the home page
/// Multiple Cells of the this type will represent different kinds of items.
class SubCellView : UICollectionViewCell
{
    private var sub_collec_view : UICollectionView!
    private var ds : SubCellDataSource!
    
    
    override init(frame: CGRect)
    {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        sub_collec_view = UICollectionView(frame: .zero, collectionViewLayout: layout);
       
        ds = SubCellDataSource()
       
        super.init(frame: frame)
        
        sub_collec_view.backgroundColor = UIColor.purple;
        sub_collec_view.translatesAutoresizingMaskIntoConstraints = false;
        
        sub_collec_view.dataSource = ds
        sub_collec_view.delegate = ds
    }
   
    func setupViews()
    {
        self.backgroundColor = UIColor.green
        self.addSubview(sub_collec_view)
       
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : sub_collec_view]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : sub_collec_view]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Provides information about the number of cells to be placed in sub cell view
class SubCellDataSource : NSObject , UICollectionViewDataSource , UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout
{
    private var cellIdentifier = "cell_1"
    private var ds : PredictionDataSource?
  
    override init()
    {
       /// TO DO : The data source can be different based on the type of algorithm that is being run
       /// Each Alogorithm will have its own data source. 
       /// All the different types of data source will conform to a single protocol
       /// The Protocol should have a 
                        /// basic analyze completion handler.
                        /// Standard Data Source methods for predictions etc
            ds  = PredictionDataSource() // Load the data source
            super.init()
    }
    
    /// Helper func which registers the collection view with the requried cells
    /// The cell identifier can be make private to the date source
    func register(collectionView: UICollectionView)
    {
            collectionView.register( ItemCell.self , forCellWithReuseIdentifier: cellIdentifier)
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
        if let cla = self.ds?.classes
        {
            return cla.count
        }
        else
        {
            return 0;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            return cell
    }
    
}


/// Cell displayed in the nested collection view. Represents a single detected object
class ItemCell : UICollectionViewCell
{
    override init(frame: CGRect)
    {
            super.init(frame: frame)
            setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews()
    {
        self.backgroundColor = UIColor.purple
    }
}
