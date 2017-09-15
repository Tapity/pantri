//
//  InventoryVC+Fetches.swift
//  Pantri
//
//  Created by Mariah Olson on 3/7/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import Foundation
import CoreData

extension InventoryVC : NSFetchedResultsControllerDelegate {
    
    /// Fetches and displays data
    func attemptFetch(){
        
        // create a fetch request for an item
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // design fetch and add to sort descriptor array
        let dateSort = NSSortDescriptor(key: "dateStocked", ascending: false)
        let stockedSort = NSSortDescriptor(key: "amountLeft", ascending: true)
        let prioritySort = NSSortDescriptor(key: "priority", ascending: true)
        let categorySort = NSSortDescriptor(key: "category", ascending: true)
        // determine sort
        switch sortControl.selectedSegmentIndex {
        case 0:
            fetchRequest.sortDescriptors = [dateSort]
        case 1:
            fetchRequest.sortDescriptors = [stockedSort, prioritySort, dateSort]
        case 2:
            fetchRequest.sortDescriptors = [categorySort]
        default:
            fetchRequest.sortDescriptors = [dateSort]
        }
        
        // instantiate controller
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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
    
    /// Listens for changes in tableview
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /// Takes care of changes to objects under controller's control
    // TODO: update update
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type){
            
        case.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case.update:
            if let indexPath = newIndexPath {
                //let cell = tableView.cellForRow(at: indexPath) as! InventoryItemCell
                //configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
}
