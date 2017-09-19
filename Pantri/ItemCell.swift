//
//  InventoryItemCell.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import SwipeCellKit

/// Note: Must implement swipeTableViewCell delegate
/// Custom swipeable tableview cell
class ItemCell: SwipeTableViewCell {
    
    /// Item name
    @IBOutlet weak var name: UILabel!
    
    
    /* Configure cell appearance */
    func configureCell(item: Item) {
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
