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
class InventoryItemCell: ItemCell {
    
    /// Marker showing if item is on grocery list
    @IBOutlet weak var onListMarker: UIView!
    
    override func configureCell(item: Item) {
        super.configureCell(item: item)
        if (!item.isOnAList){
            onListMarker.isHidden = true
        } else {
            onListMarker.isHidden = false
        }
    }
    
}
