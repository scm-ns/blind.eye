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


class GradientView : UIView // to handle auto resizing of graident
{
    private let gradient = CAGradientLayer()
    
    init(colors : [UIColor] = [UIColor.red , UIColor.yellow]) {
        super.init(frame: CGRect.zero)
        gradient.colors = colors
        gradient.startPoint =  CGPoint(x: 0, y: 0)
        gradient.endPoint =  CGPoint(x: 1, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
    }
   
}


class bounceView : UIView
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
      
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4, options: .curveEaseInOut, animations:
        {
                self.transform = CGAffineTransform.identity
        }, completion: nil)
        
       
        super.touchesBegan(touches, with: event)
    }
}


class belliv : UIImageView
{

    init()
    {
        super.init(image: UIImage(named: "bell"))
        self.contentMode = .scaleAspectFit
        self.backgroundColor = UIColor.darkGray
      
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.green.cgColor
      
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 4.0
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}


class specialView : UIView
{
    var bellArr :[belliv]  = []
    override init(frame: CGRect) {
       super.init(frame: frame)
       
        bellArr.append(belliv())
        bellArr.append(belliv())
        bellArr.append(belliv())
        bellArr.append(belliv())

        self.addSubview(bellArr[0])
        self.addSubview(bellArr[1])
        self.addSubview(bellArr[2])
        self.addSubview(bellArr[2])
        
        bellArr[1].alpha = 0
        bellArr[2].alpha = 0
        bellArr[3].alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4, options: .curveEaseInOut, animations:
            {
                self.bellArr[1].alpha = 1
                self.bellArr[2].alpha = 1
                self.bellArr[3].alpha = 1
                
                self.bellArr[1].transform = CGAffineTransform(scaleX: self.frame.width, y: 0)
                self.bellArr[2].transform = CGAffineTransform(scaleX: 0, y: self.frame.width)
                self.bellArr[3].transform = CGAffineTransform(scaleX: self.frame.width, y: self.frame.width)

        }, completion: nil)
        
        
        super.touchesBegan(touches, with: event)
    }
    
}


class MainVC : UIViewController
{
    
    private let headerView : UIView = {
        let view  = bounceView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.blue
        
           // GradientView()
        return view
    }()
 
    private let bellView : UIView = {
        let iv = belliv()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    private let mainCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        // resize using autolayout
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.backgroundView?.backgroundColor = UIColor.white
        colView.backgroundColor = UIColor.red
        colView.register(tensorFlowCell.self, forCellWithReuseIdentifier: tensorFlowCell.cell_identifier)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        print(self.view)
        hideViewsForAnimation()
    }
   
    func hideViewsForAnimation()
    {
        self.mainCollectionView.alpha = 0
        self.headerView.alpha = 0
        self.bellView.alpha = 0
    }
   
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let duration = 0.5
        
        UIView.animate(withDuration: duration, animations:
        {
           self.headerView.alpha = 1
        },
        completion:
        {
           _ in
            UIView.animate(withDuration: duration, animations:
            {
                    self.mainCollectionView.alpha = 1
            },
            completion :
            {
                _ in
                UIView.animate(withDuration: duration, animations:
                {
                       self.bellView.alpha = 1
                },
                completion:
                {
                    _ in
                    print("animation complete")
                })
            })
            
        })
    }
    
    func setupView()
    {
        // layout main collectoinview
        self.view.addSubview(self.mainCollectionView)
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.bellView)
        
        
        let viewMapping = ["v0":self.mainCollectionView , "v1" : self.headerView , "v2" : self.bellView]
        var constraints : [NSLayoutConstraint] = []
      
        //  line up the bell and header
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v1]-[v2(==v1)]-|", options: [.alignAllCenterY ], metrics: [:], views: viewMapping))
        
        constraints.append(contentsOf:   NSLayoutConstraint.constraints(withVisualFormat: "V:|-==20-[v1(>=50)]", options: [], metrics: [:], views: viewMapping) )
        
        constraints.append(NSLayoutConstraint(item: self.bellView , attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.headerView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0))
       
        
        constraints.append(contentsOf:   NSLayoutConstraint.constraints(withVisualFormat: "V:[v1]-[v0]-==20-|", options: [], metrics: [:], views: viewMapping) )
      
        // make header height 0.2 of the mainCollectionView
       constraints.append(NSLayoutConstraint(item: self.headerView, attribute: NSLayoutAttribute.height , relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: self.mainCollectionView, attribute: NSLayoutAttribute.height, multiplier: 0.20, constant: 0))
        
       constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
      
        
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
}

// Holds the different sections, where each of the them will be a collection view
// Register cells
// the mainDataSource is just a container. It has ntohgint to load. 
// It will just hold the different sections, correponding to the different types of sections
// with cells in them. 
class mainDataSource: NSObject, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1; 
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tensorFlowCell.cell_identifier, for: indexPath)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            return CGSize(width: (collectionView.bounds.width), height: 200)
    }
}

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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: outputCell.cell_identifier, for: indexPath)
            
            return cell
    }   

   
}

class outputCellViewModel
{
    let labelStr : String
    init(label : String)
    {
        labelStr = label
    }
}

class outputCell : UICollectionViewCell
{
    static let cell_identifier  = "ouput_cell"
    
    private var viewModel : outputCellViewModel?
    {
        didSet
        {
            self.label.text = viewModel?.labelStr
        }
    }
   
    private let label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.yellow
        label.backgroundColor = UIColor.blue
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   
    private func setupViews()
    {
        self.contentView.backgroundColor = UIColor.purple
        self.contentView.addSubview(self.label)
        
        let viewMapping : [String : AnyObject] = ["v0" : self.label]
        var constrains: [NSLayoutConstraint] = []
        
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        
        NSLayoutConstraint.activate(constrains)
    }
    
}


/*
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
*/
