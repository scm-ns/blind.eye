//
//  outputCell.swift
//  blind.eye
//
//  Created by scm197 on 2/27/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit


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

