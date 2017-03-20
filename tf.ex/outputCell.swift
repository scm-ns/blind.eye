//
//  outputCell.swift
//  blind.eye
//
//  Created by scm197 on 2/27/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit

/*
    This is a simple cell with a text label in its center
 
 */

class outputCellViewModel
{
    let labelStr : String?
    init(label : String?)
    {
        if let label = label
        {
            labelStr = label
        }
        else{
            labelStr = nil
        }
    }
}

class outputCell : UICollectionViewCell
{
    static let cell_identifier  = "output_cell"
    
    public var viewModel : outputCellViewModel?
    {
        didSet
        {
            self.label.text = viewModel?.labelStr
        }
    }
   
    private let label : UILabel =
    {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupRoundedCorners()
        setupViews()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   
    private func setupRoundedCorners()
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
    
    private func setupViews()
    {
        self.contentView.backgroundColor = UIColor.green
        self.contentView.addSubview(self.label)
        
        let viewMapping : [String : AnyObject] = ["v0" : self.label]
        var constrains: [NSLayoutConstraint] = []
        
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: [:], views: viewMapping))
        
        NSLayoutConstraint.activate(constrains)
    }
    
}

