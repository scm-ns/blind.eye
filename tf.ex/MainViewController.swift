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


class MainVC : UIViewController
{
 
    private let mainCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        // resize using autolayout
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.backgroundView?.backgroundColor = UIColor.white
        colView.backgroundColor = UIColor.red
        colView.register(tensorFlowCell.self, forCellWithReuseIdentifier: tensorFlowCell.cell_identifer)
        return colView
    }()
    
    private let ds = mainDataSource()
    // MARK -: Initialization
    init()
    {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.yellow
        print(self.view)
        
        self.mainCollectionView.dataSource = self.ds
        self.mainCollectionView.delegate = self.ds
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK -: Setup Views
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupView()
        print(self.view)
    }
   
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let duration = 0.5
        
        UIView.animate(withDuration: duration, animations:
        {
                self.mainCollectionView.alpha = 1
        },
        completion :
        {
            (val) in
                print("animation complete \(val)")
        })
        
    }
    
    func setupView()
    {
        // layout main collectoinview
        self.view.addSubview(self.mainCollectionView)
        
        let viewMapping = ["v0":self.mainCollectionView]
        var constraints : [NSLayoutConstraint] = []
        constraints.append(contentsOf:   NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: [:], views: viewMapping) )
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        NSLayoutConstraint.activate(constraints)
    }
    
}

// Holds the different sections, where each of the them will be a collection view
// Register cells
// the mainDataSource is just a container. It has ntohgint to load.
// It will just hold the different sections, correponding to the different types of sections
// with cells in them.
class mainDataSource: NSObject, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
{
    
    private let cellSource = cellRegistrar()
    override init() {
        super.init()
        cellSource.registerCell(cell:tensorFlowCell.self as! cellProtocol as! cellProtocol.Type )
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identifier,for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            return CGSize(width: (collectionView.bounds.width), height: 200)
    }
}
