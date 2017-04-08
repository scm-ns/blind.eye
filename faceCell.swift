//
//  faceCell.swift
//  blind.eye
//
//  Created by scm197 on 4/8/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit

class faceCellViewModel
{
    let faceImage : UIImage!
    init(faceImage : UIImage)
    {
        self.faceImage = faceImage
    }
}


class faceCell : UICollectionViewCell
{
    static let cell_identifier = "face_cell"
    
    public var viewModel : faceCellViewModel?
    {
        didSet
        {
            print("Set the image")
            self.imageView.image = viewModel?.faceImage ?? nil
        }
    }
    
    fileprivate let imageView : UIImageView =
    {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFit // TO DO : Find the best mode
        imageV.translatesAutoresizingMaskIntoConstraints = false
        return imageV
    }()
    
    
    override init(frame : CGRect)
    {
        super.init(frame: frame)
        self.setupRoundedCorners()
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    
}

extension faceCell
{
 
    fileprivate func setupRoundedCorners()
    {
        guard self.contentView.bounds.width == self.contentView.bounds.height else
        {
            print("Width and height must be equal for rounded corners")
            return
        }
        
        let view = self.contentView
         // border radius
        self.layer.cornerRadius = self.contentView.bounds.width / 2
        // Make the corner radius half of the width
        self.layer.masksToBounds = true
         
        // border
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 0.2;
        
        // drop shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
    
    fileprivate func setupViews()
    {
        self.contentView.backgroundColor = UIColor.green
        self.contentView.addSubview(self.imageView)
        
        let viewMapping : [String : AnyObject] = ["v0" : self.imageView]
        var constrains: [NSLayoutConstraint] = []
        
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        
        NSLayoutConstraint.activate(constrains)
    }
    
}


