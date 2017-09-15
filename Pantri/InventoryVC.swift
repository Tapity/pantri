//
//  FirstViewController.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import MBProgressHUD

/// Manages: sharing controller and non-tableview UI elements
class InventoryVC: UIViewController, UICloudSharingControllerDelegate {

    /// table of inventory items
    @IBOutlet weak var tableView: UITableView!
    /// sort control for inventory items
    @IBOutlet weak var sortControl: UISegmentedControl!
    
    var controller: NSFetchedResultsController<Item>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloud.saveZone()
        cloud.getInventory()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        cloud.syncCoreDataToCloud()
        attemptFetch()
    }
    
    //# Mark: - Inventory UI elements
    
    // manage changes to sort control
    @IBAction func sortControlTapped(_ sender: UISegmentedControl) {
        attemptFetch()
        tableView.reloadData()
    }
    
    /// sync button (temporary solution)
    @IBAction func syncButtonPressed(_ sender: Any) {
        showLoadingHUD()
        cloud.syncCoreDataToCloud()
        attemptFetch()
        hideLoadingHUD()
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: tableView, animated: true)
        hud.label.text = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hide(for: tableView, animated: true)
    }
    
    //# MARK: - Sharing controller
    
    // share button
    @IBAction func shareButtonPressed(_ sender: Any) {
        let share = CKShare(rootRecord: cloud.inventoryRecord!)
        share[CKShareTitleKey] = "myInventory" as CKRecordValue?
        share[CKShareTypeKey] = "Inventory" as CKRecordValue?
        let sharingController = UICloudSharingController(preparationHandler: {(UICloudSharingController, handler:
            @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            let modifyOp = CKModifyRecordsOperation(recordsToSave:
                [cloud.inventoryRecord!, share], recordIDsToDelete: nil)
            modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
                error) in
                handler(share, CKContainer.default(), error)
            }
            
            CKContainer.default().privateCloudDatabase.add(modifyOp)
        })
        sharingController.availablePermissions = [.allowReadWrite,
                                                  .allowPrivate]
        sharingController.delegate = self
        self.present(sharingController, animated:true, completion:nil)
    }
    
    // boiler plate code for share
    func cloudSharingController(_ controller: UICloudSharingController, failedToSaveShareWithError error: Error) {
        // Failed to save, handle the error better than I did :-)
        // Also, this method is required!
        print(error)
        print("FAILED TO SAVE")
    }
    
    func itemTitle(for: UICloudSharingController) -> String? {
        // Set the title here, this method is required!
        // returning nil or failing to implement delegate methods
        return "My Inventory"
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("cloudSharingControllerDidSaveShare")
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("cloudSharingControllerDidStopSharing")
    }
    
}

