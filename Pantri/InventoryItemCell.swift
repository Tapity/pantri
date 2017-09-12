//
//  InventoryItemCell.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol InventoryItemCellDelegate {
    func toggleCell(cell: InventoryItemCell, indexPath: NSIndexPath)
}

/// Note: Must implement swipeTableViewCell delegate

class InventoryItemCell: SwipeTableViewCell {
    
    var expandCellDelegate: InventoryItemCellDelegate?
    var cellIndexPath : NSIndexPath?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detailsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var onListMarker: UIView!
    
    var cellItem : Item?
    var cellHeight : CGFloat = 0
    let expandedHeight: CGFloat = 200
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCell()
    }
    
    func configureCell(){
        // #TODO: Implement
    }
    
    func setIndexPath(indexPath: NSIndexPath){
        cellIndexPath = indexPath
    }
    
    func configureCell(item: Item) {
        cellItem = item
        name.text = item.name
        switch item.amountLeft {
        case 0:
            destockCell()
        case 1:
            almostOutCell()
        case 2:
            stockCell()
        default:
            stockCell() // TODO: COULD CAUSE ERRORS
        }
        if (!item.isOnAList){
            onListMarker.isHidden = true
        } else {
            onListMarker.isHidden = false
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        if cellItem != nil {
            // implement
            print(name)
        }
    }
    
    // expand/close details
    func cellTapped(){
        // #TODO: figure out how to get row
        expandCellDelegate?.toggleCell(cell: self, indexPath: cellIndexPath!)
        if (self.detailsViewHeight.constant == expandedHeight){
            self.detailsViewHeight.constant = 0
            cellHeight = 50
        } else {
            self.detailsViewHeight.constant = expandedHeight
            cellHeight = 250
        }
        if let myItem = cellItem {
            self.configureCell(item: myItem)
        }
    }
    
    // determine appearance of cell based on stock
    func destockCell(){
        backgroundColor = .gray
    }
    
    func almostOutCell(){
        backgroundColor = .lightGray
    }
    
    func stockCell(){
        backgroundColor = .white
    }
}
