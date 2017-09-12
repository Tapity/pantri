//
//  InventoryVC+Fetches.swift
//  Pantri
//
//  Created by Mariah Olson on 3/7/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension GroceryListVC : NSFetchedResultsControllerDelegate {
    
    // fetch and display data
    func attemptFetch(){
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        // design design sorts
        let categorySort = NSSortDescriptor(key: "category.name", ascending: false)
        // design fetches
        let mainFetchPredicate = NSPredicate(format: "isOnAList == %@", NSNumber(booleanLiteral: true))
        
        // set sort & predicate for main fetch
        fetchRequest.sortDescriptors = [categorySort]
        fetchRequest.predicate = mainFetchPredicate
        
        // instantiate controller
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category.name", cacheName: nil)
        controller.delegate = self
        self.controller = controller
        
        // perform a fetch (could fail)
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print ("\(error)")
        }
    }
    
    func attemptFruitFetch() {
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        let stockedSort = NSSortDescriptor(key: "dateStocked", ascending: false)
        let fruitFetchPredicate = NSPredicate(format: "category.name == %@", "Fruit")
        
        // set up fruit fetch
        fetchRequest.sortDescriptors = [stockedSort]
        fetchRequest.predicate = fruitFetchPredicate
        // reset controller
        let control = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        control.delegate = self
        self.fruitController = control
        
        // perform a fetch (could fail)
        do {
            try fruitController.performFetch()
        } catch {
            let error = error as NSError
            print ("\(error)")
        }
    }
    
    func attemptMeatFetch() {
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        let stockedSort = NSSortDescriptor(key: "dateStocked", ascending: false)
        let meatFetchPredicate = NSPredicate(format: "category.name == %@", "Meat & Deli")
        
        // set up fruit fetch
        fetchRequest.sortDescriptors = [stockedSort]
        fetchRequest.predicate = meatFetchPredicate
        // reset controller
        let control = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        control.delegate = self
        self.meatController = control
        
        // perform a fetch (could fail)
        do {
            try meatController.performFetch()
        } catch {
            let error = error as NSError
            print ("\(error)")
        }
    }
    
    // listens for changes in tableview
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let tbv = tableViewOfController(myController: controller as! NSFetchedResultsController<Item>)
            tbv.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            let tbv = tableViewOfController(myController: controller as! NSFetchedResultsController<Item>)
            tbv.endUpdates()
    }
    
            // takes care of changes to sections
            func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
                let tbv = tableViewOfController(myController: controller as! NSFetchedResultsController<Item>)
                switch type {
                case.insert: tbv.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
                    break
                case.delete: tbv.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
                    break
                default:
                    break
                }
            }
            
            // takes care of changes to objects under controller's control
            func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
                let tbv = tableViewOfController(myController: controller as! NSFetchedResultsController<Item>)
                // DETERMINE TABLE BASED ON CONTROLLER
                switch(type){
                case.insert:
                    if let indexPath = newIndexPath {
                        tbv.insertRows(at: [indexPath], with: .fade)
                    }
                    break
                case.delete:
                    if let indexPath = indexPath {
                        tbv.deleteRows(at: [indexPath], with: .fade)
                    }
                    break
                case.update:
                    if let indexPath = newIndexPath {
                        let cell = tbv.cellForRow(at: indexPath)
                        if (cell == nil) {
                            print("error: cell was nil!?") // Check for random error: LOOK INTO
                        } else {
                            if (controller == self.controller){
                                configureCell(cell: cell as! GroceryListItemCell, indexPath: indexPath as NSIndexPath, control: controller as! NSFetchedResultsController<Item>)
                            } else if (controller == self.fruitController){
                                configureFruitCell(cell: cell as! FruitCell, indexPath: indexPath as NSIndexPath, control: controller as! NSFetchedResultsController<Item>)
                            } else {
                                configureMeatCell(cell: cell as! MeatCell, indexPath: indexPath as NSIndexPath, control: controller as! NSFetchedResultsController<Item>)
                            }
                        }
                    }
                    break
                case.move:
                    if let indexPath = indexPath {
                        tbv.deleteRows(at: [indexPath], with: .fade)
                    }
                    if let indexPath = newIndexPath {
                        tbv.insertRows(at: [indexPath], with: .fade)
                    }
                    break
                }
            }
    
    func tableViewOfController(myController: NSFetchedResultsController<Item>) -> UITableView {
        var tv : UITableView
        if (myController == self.controller){
            tv = self.tableView
        } else if (myController == self.fruitController){
            tv = self.fruitTableView
        } else {
            tv = self.meatTableView
        }
        return tv
    }
}

