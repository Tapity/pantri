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

extension InventoryVC : UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, InventoryItemCellDelegate {
    

    //# MARK: - Table View Implementation
    
    // return cell for index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InventoryItemCell
        cell.delegate = self
        cell.expandCellDelegate = self
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InventoryItemCell
        //return cell
    }
    
    // configure cell for index path
    func configureCell(cell: InventoryItemCell, indexPath: NSIndexPath){
        let item = controller.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
        cell.setIndexPath(indexPath: indexPath)
    }
    
    func toggleCell(cell: InventoryItemCell, indexPath: NSIndexPath) {
        // #TODO: Implement
        // perhaps set variable stating that this row should have
        // heightForRow at have a different result
        
    }
    
    // cell swipe functionality
    // TODO: Fix commenting and function
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else {
            // left swipe
            guard orientation == .left else { return nil }
            
            let addToListAction = SwipeAction(style: .destructive, title: "Add to Grocery List") { action, indexPath in
                let item = self.controller.object(at: indexPath as IndexPath)
                item.isOnAList = !item.isOnAList // NOT ALWAYS TRUE, OPPOSITE
                ad.saveContext()
            }
            addToListAction.backgroundColor = .green
            return [addToListAction]
        }
        
        // right swipe
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        let otherAction = SwipeAction(style: .destructive, title: "Other") { action, indexPath in
            // handle action by updating model with deletion
        }
        
        // customize the action appearance
        otherAction.backgroundColor = .green
        
        return [deleteAction, otherAction]
        
        guard orientation == .left else { return nil }
        
        let addToListAction = SwipeAction(style: .default, title: "AddToList") { action, indexPath in
            // handle action by updating model with deletion
        }
        
        addToListAction.backgroundColor = .white
        return [addToListAction]
    }
    
    // count rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // get sections info from controller
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    // count sections
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InventoryItemCell
        cell.cellTapped()
        /*
        if let objs = controller.fetchedObjects, objs.count > 0 {
            let item = objs[indexPath.row]
            performSegue(withIdentifier: "AddItemVC", sender: item)
        }*/
    }
    
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
    }
    
    // make rows swipeable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // implement table view swiping (TEMP SOLUTION)
    /*
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
    }*/
    
    // update stock info for cell at index path
    func updateStock(index: IndexPath, stock: int_fast16_t){
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
