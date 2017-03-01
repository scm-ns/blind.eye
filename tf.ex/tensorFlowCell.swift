//
//  tensorFlowCell.swift
//  blind.eye
//
//  Created by scm197 on 2/27/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit


// Holds a collection view inside it, which shows the results of the inception network running
class tensorFlowCell : UICollectionViewCell
{
    static public let cell_identifier = "tensorFlowCell"
    
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
}

class tensorFlowDataSource : NSObject , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
{
    // this has to be some sort of delegate that is implmented.
    /// I need to create a protocl which can handle the talking between the machien learning part and the data soruce part
    
    // architecture question : I need to make sure that I am implementing things properly.
    // I do not want to give access to the ml part to the view controller. I just need to make sure that
    // the collection view has be reloated when the prediction data source has completed functioning.
    // I need the timer to be part of the data source and not the view controller.
    // The best way to do this , is by using a reference ot the vc and called reload of it when the data has been laoded
    
    private let ds : PredictionDataSource

    // timer to call the prediction data source and force it to create a predictin
   
    private var timer : Timer?
    
    private let colView : UICollectionView
    
    init(collectionView : UICollectionView)
    {
       /// TO DO : The data source can be different based on the type of algorithm that is being run
       /// Each Alogorithm will have its own data source. 
       /// All the different types of data source will conform to a single protocol
       /// The Protocol should have a 
                        /// basic analyze completion handler.
                        /// Standard Data Source methods for predictions etc
        ds  = PredictionDataSource() // Load the data source
        ds.setup()
        colView = collectionView
        
        super.init()

        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(tensorFlowDataSource.analyze), userInfo: nil, repeats: true)
    }
   
    /// Single Section for each Cell
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1 ;
    }
   
    func analyze()
    {
        ds.analyze(com: {
            self.colView.reloadData()
            print("analyziz image")
        })
        
   }
   
    deinit
    {
        timer?.invalidate()
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
        
            let vm = outputCellViewModel(label: dict.object(forKey: "label") as? String)
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: outputCell.cell_identifier, for: indexPath) as! outputCell
            cell.viewModel = vm;
        
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 50, height: 50)
    }

}

