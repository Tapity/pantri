//
//  InventoryVC+DataSource.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

/// Manages: functionality and appearance of tableviews
extension InventoryVC : UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    

    //# MARK: - Table View Implementation
    
    /// get cell for index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InventoryItemCell
        cell.delegate = self
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    /// configure cell at given index path
    func configureCell(cell: InventoryItemCell, indexPath: NSIndexPath){
        let item = controller.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
    }
    
    /// cell swipe functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else {
            // right swipe
            guard orientation == .left else { return nil }
            
            let addToListAction = SwipeAction(style: .default, title: "Add to Grocery List") { action, indexPath in
                let item = self.controller.object(at: indexPath as IndexPath)
                item.isOnAList = !item.isOnAList // NOT ALWAYS TRUE, OPPOSITE
                ad.saveContext()
            }
            addToListAction.backgroundColor = UIColor(red: 0, green: 0.8667, blue: 0.2745, alpha: 1.0) /* #00dd46 */
            return [addToListAction]
        }
        
        // left swipe
        let outOfStock = SwipeAction(style: .default, title: "") { action, index in
            self.updateStock(index: index, stock: 0)
            // delete one-off item
            let item = self.controller.object(at: index as IndexPath)
            if (!item.mustKeepOnHand) {
                context.delete(item)
            }
        }
        outOfStock.backgroundColor = .darkGray
        
        let almostOut = SwipeAction(style: .default, title: "") { action, index in
            self.updateStock(index: index, stock: 1)
        }
        almostOut.backgroundColor = .gray
        
        let restock = SwipeAction(style: .default, title: "") { action, index in
            self.updateStock(index: index, stock: 2)
        }
        restock.backgroundColor = UIColor(red: 0.9294, green: 0.9294, blue: 0.9294, alpha: 1.0) /* #ededed */
        
        return [outOfStock, almostOut, restock]
    }
    
    /// count tableview rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // get sections info from controller
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    /// count tableview sections
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    

    // set cell width
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    // perform segue upon row selection with item at selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if there are objects in controller, use object at index path as the sender
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InventoryItemCell
        if let objs = controller.fetchedObjects, objs.count > 0 {
            let item = objs[indexPath.row]
            performSegue(withIdentifier: "AddItemVC", sender: item)
        }
    }
    
    // make rows swipeable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    /// update stock info for cell at index path
    func updateStock(index: IndexPath, stock: int_fast16_t){
        // find object from controller
        let item = controller.object(at: index as IndexPath)
        if (stock == 2){
            item.dateStocked = NSDate()
        }
        item.amountLeft = stock
        // save to cloud
        cloud.updateItemInCloud(item: item, keysToChange: [Cloud.Attribute.AmountLeft, Cloud.Attribute.IsOnAList, Cloud.Attribute.DateStocked])
        ad.saveContext()
    }
}

/*
 // implement table view swiping (TEMP SOLUTION)
 func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
 let outOfStock = UITableViewRowAction(style: .normal, title: "") { action, index in
 self.updateStock(index: index, stock: 0)
 // delete one-off item
 let item = self.controller.object(at: index as IndexPath)
 if (!item.mustKeepOnHand) {
 context.delete(item)
 }
 }
 outOfStock.backgroundColor = .darkGray
 
 let almostOut = UITableViewRowAction(style: .normal, title: "") { action, index in
 self.updateStock(index: index, stock: 1)
 
 }
 almostOut.backgroundColor = .gray
 
 let restock = UITableViewRowAction(style: .normal, title: "") { action, index in
 self.updateStock(index: index, stock: 2)
 }
 restock.backgroundColor = UIColor(red: 0.9294, green: 0.9294, blue: 0.9294, alpha: 1.0) /* #ededed */
 
 let addToList = UITableViewRowAction(style: .normal, title: "") { action, index in
 let item = self.controller.object(at: index as IndexPath)
 item.isOnAList = !item.isOnAList // NOT ALWAYS TRUE, OPPOSITE
 ad.saveContext()
 }
 addToList.backgroundColor = UIColor(red: 0, green: 0.8667, blue: 0.2745, alpha: 1.0) /* #00dd46 */
 
 return [outOfStock, almostOut, restock, addToList]
 } */

/*
 // edit item
 func edit(item: Item){
 performSegue(withIdentifier: "AddItemVC", sender: item)
 }
 
 // set itemToEdit in next storyboard
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 if segue.identifier == "AddItemVC" {
 if let destination = segue.destination as? AddItemVC {
 destination.inNav = true
 if let item = sender as? Item {
 destination.itemToEdit = item
 }
 }
 }
 }*/
