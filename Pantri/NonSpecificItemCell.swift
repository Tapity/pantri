
//
//  InventoryItemCell.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import CoreData

class NonSpecificItemCell: ItemCell {
    
    @IBOutlet weak var detail: UILabel!
    
    override func configureCell(item: Item) {
        super.configureCell(item: item)
        detail.text = item.notes
    }
        
}
