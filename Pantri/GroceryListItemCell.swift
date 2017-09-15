//
//  InventoryItemCell.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import CoreData

class GroceryListItemCell: UITableViewCell {
 
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var detail: UILabel!
    
    func configureCell(item: Item) {
        name.text = item.name
        detail.text = item.notes
    }
}
