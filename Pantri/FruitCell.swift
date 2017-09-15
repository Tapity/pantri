//
//  InventoryItemCell.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import CoreData

class FruitCell: UITableViewCell {
 
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var detail: UILabel!
    
    func configureCell(item: Item) {
        name.text = item.name
        detail.text = item.notes
        
        // cell style for stock
        switch item.amountLeft {
        case 0:
            destockCell()
        case 1:
            almostOutCell()
        case 2:
            stockCell()
        default:
            stockCell()
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
