//
//  common.swift
//  blind.eye
//
//  Created by scm197 on 3/1/17.
//  Copyright © 2017 scm197. All rights reserved.
//

import UIKit

/*
open class baseColViewCell : UICollectionViewCell
{
    open var isCancelled: Bool { get }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 */



/*
 
    cell provider : The naming is not good enough. 
    This is supposed to register the collection view with the differetn types fo cells. 
 
    So a data source should implement the protocol and the collection view should be registerd ? 
 
 */

public protocol cellProtocol
{
    static var cell_identifer : String { get }
}

class  cellRegistrar
{
    private var cells : [cellProtocol.Type]
    
    init()
    {
        cells = []
    }
   
    func registerCell(cell : cellProtocol.Type)
    {
        cells.append(cell)
    }
    
    func configColView(colView : UICollectionView)
    {
        cells.map
        {
            (cell) in
            colView.register(cell.self as! UICollectionViewCell.Type, forCellWithReuseIdentifier: cell.cell_identifer)
            
        }
    }

    func numberOfCellTypes() -> Int
    {
       return cells.count
    }
   
    // TODO: scm197 make extraction safer
    func itemAtIndex(index : Int) -> cellProtocol.Type
    {
        return cells[index]
    }
    
}

