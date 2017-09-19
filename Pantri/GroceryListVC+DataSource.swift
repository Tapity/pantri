//
//  InventoryVC+DataSource.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import CoreData

extension GroceryListVC: UITableViewDelegate, UITableViewDataSource {
    
    
    //# MARK: - Table View Implementation
    
    // set up table view by returning appropriate cells for index paths
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // CONTROLLER BASED ON TABLEVIEW
        let cntrl = controllerOfTableView(tableView: tableView)
        if (tableView == self.tableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GroceryListItemCell
            configureCell(cell: cell , indexPath: indexPath as NSIndexPath, control: cntrl)
            return cell
        } else if (tableView == self.fruitTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "fruitCell", for: indexPath) as! NonSpecificItemCell
            configureNSICell(cell: cell , indexPath: indexPath as NSIndexPath, control: cntrl)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "meatCell", for: indexPath) as! NonSpecificItemCell
            configureNSICell(cell: cell , indexPath: indexPath as NSIndexPath, control: cntrl)
            return cell
        }
    }
    
    // configure cell
    func configureCell(cell: GroceryListItemCell, indexPath: NSIndexPath, control: NSFetchedResultsController<Item>){
        let item = control.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
    }
    
    // configure non specific item cell
    func configureNSICell(cell: NonSpecificItemCell, indexPath: NSIndexPath, control: NSFetchedResultsController<Item>){
        let item = control.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
    }

    // count rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // CONTROLLER BASED ON TABLEVIEW
        let cntrl = controllerOfTableView(tableView: tableView)
        // get sections info from controller
        if let sections = cntrl.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    // count sections
    func numberOfSections(in tableView: UITableView) -> Int {
        let cntrl = controllerOfTableView(tableView: tableView)
        if let sections = cntrl.sections {
            return sections.count
        }
        return 1
    }
    
    // set cell width
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // set section header width
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 20
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = controller.sections?[section]
        return section?.name
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView == self.tableView {
            view.tintColor = UIColor(red: 1, green: 0.4824, blue: 0, alpha: 1.0) /* #ff7b00 */
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.white
            header.textLabel?.text = controller.sections?[section].name        }
    }

    // make rows swipeable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // implement table view swiping
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let cntrl = controllerOfTableView(tableView: tableView)
        
        // main list case: special behavior for added to grocery
        if (tableView == self.tableView){
        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            self.updateGroceryList(index: index, wasPurchased: false, control: cntrl)
        }
        remove.backgroundColor = .gray
        
        let purchased = UITableViewRowAction(style: .normal, title: "Purchased") { action, index in
            self.updateGroceryList(index: index, wasPurchased: true, control: cntrl)
        }
        purchased.backgroundColor = .green
        
        return [remove, purchased]
        }
        
        // generic item table case: behavior like inventory
        else {
            let outOfStock = UITableViewRowAction(style: .normal, title: "") { action, index in
                self.updateStock(index: index, stock: 0, controller: cntrl)
                // delete one-off item
                let item = cntrl.object(at: index as IndexPath)
                if (!item.mustKeepOnHand) {
                    context.delete(item)
                }
                ad.saveContext()
            }
            outOfStock.backgroundColor = .darkGray
            
            let almostOut = UITableViewRowAction(style: .normal, title: "") { action, index in
                self.updateStock(index: index, stock: 1, controller: cntrl)
                
            }
            almostOut.backgroundColor = .gray
            
            let restock = UITableViewRowAction(style: .normal, title: "") { action, index in
                self.updateStock(index: index, stock: 2, controller: cntrl)
            }
            restock.backgroundColor = UIColor(red: 0.9294, green: 0.9294, blue: 0.9294, alpha: 1.0) /* #ededed */
            
            let addToList = UITableViewRowAction(style: .normal, title: "") { action, index in
                let item = cntrl.object(at: index as IndexPath)
                item.isOnAList = !item.isOnAList // NOT ALWAYS TRUE, OPPOSITE
                ad.saveContext()
            }
            addToList.backgroundColor = UIColor(red: 0, green: 0.8667, blue: 0.2745, alpha: 1.0) /* #00dd46 */
            
            return [outOfStock, almostOut, restock, addToList]
        }
    }
    
    // update stock info for cell at index path
    func updateStock(index: IndexPath, stock: int_fast16_t, controller: NSFetchedResultsController<Item>){
        let item = controller.object(at: index as IndexPath)
        if (stock == 2){
            item.dateStocked = NSDate()
        }
        item.amountLeft = stock
        updateCategoryCountLabel()
        ad.saveContext()
    }
    
    // update grocery list info for cell at index path
    func updateGroceryList(index: IndexPath, wasPurchased: Bool, control: NSFetchedResultsController<Item>){
        let item = control.object(at: index as IndexPath)
        if (wasPurchased){
            item.amountLeft = 2
        }
        item.isOnAList = false
        updateCategoryCountLabel()
        ad.saveContext()
    }
    
    // determine associated controller given a table view
    func controllerOfTableView(tableView: UITableView) -> NSFetchedResultsController<Item> {
        var cntrl : NSFetchedResultsController<Item>
        if (tableView == self.tableView){
            cntrl = self.controller
        } else if (tableView == self.fruitTableView){
            cntrl = self.fruitController
        } else {
            cntrl = self.meatController
        }
        return cntrl
    }
}
