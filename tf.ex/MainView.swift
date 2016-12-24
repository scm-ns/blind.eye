//
//  MainView.swift
//  tf.ex
//
//  Created by scm197 on 11/19/16.
//  Copyright © 2016 scm197. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainView: UICollectionViewController , SKTransactionDelegate
{

    var ds : PredictionDataSource? ;
    var analyzeImageTimer : Timer? ;
    var session: SKSession? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let SKSServerUrl = "nmsps://NMDPTRIAL_scm197_3_rutgers_edu20161119180532@sslsandbox-nmdp.nuancemobility.net:443";
        let SKSAppKey = "1f8818c1115fbb9d5f627c9bb84263d725ce4f78684f54a197eaa17e664abc86d2d447e33302819364fd2e1c4091f3655f43ddc7923168291c09a78253630826"
        
        session = SKSession(url: NSURL(string: SKSServerUrl) as URL!, appToken: SKSAppKey)
        
        
        speak(str: "Hello World");
        
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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

        let textToSpeak = str;
        
        // use this to specify a voice (language will be determined based on the voice)

        _ = session?.speak(textToSpeak, withVoice: "Samantha", options: nil, delegate: self)
     //   _ = session?.speakMarkup("<speak><prosody rate=\"50%\">\(textToSpeak)</prosody></speak>", withVoice: "Samantha", options: nil, delegate: self);
        
        
    }
    
    
}
