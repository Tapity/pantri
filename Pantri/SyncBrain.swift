//
//  SyncBrain.swift
//  Pantri
//
//  Created by Mariah Olson on 3/10/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class SyncBrain {
    
    // get database to save to
    private let myDatabase = CKContainer.default().privateCloudDatabase
    var coreDataItems : [Item] = []
    
    // list management
    var inventoryRecord : CKRecord?
    var inventoryCreated = false
    
    // create custome zone
    let myZone = CKRecordZone(zoneName: "myZone")
    
    // retrieve id
    var myZoneID : CKRecordZoneID {
        get {
            return myZone.zoneID
        }
    }
    
    init(){
        UserDefaults.standard.register(defaults: ["InventoryIsCreated" : false])
    }
    
    /// create inventory
    func getInventory() {
        // check if inventory is created
        if (UserDefaults.standard.bool(forKey: "InventoryIsCreated") == false){
            print("creating list NOW")
            // define record
            let record = CKRecord(recordType: "Inventory", zoneID: myZoneID)
            
            // set attributes
            record["name"] = "myInventory" as CKRecordValue
            
            // Save this record
            self.myDatabase.save(record, completionHandler: { (savedRecord, saveError) in
                if saveError != nil {
                    print("Error saving record: \(String(describing: saveError?.localizedDescription))")
                } else {
                    print("Private inventory successfully created!")
                    UserDefaults.standard.set(true, forKey: "InventoryIsCreated")
                    self.inventoryRecord = record
                }
            })
            inventoryCreated = true
        }
        
        // check if inventory record is stored
        if (inventoryRecord == nil){
            print("INVENTORY RECORD NIL")
            // query for inventory record
            let name = "myInventory"
            let query = CKQuery(recordType: "Inventory", predicate: NSPredicate(format: "name == %@", name))
            CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: myZoneID, completionHandler: { (records, error) in
                if error != nil {
                    print("Error querying records for list: \(String(describing: error?.localizedDescription))")
                } else {
                    /// CHANGE SYNTAX
                    if((records?.count)! > 0){
                        self.inventoryRecord = (records?[0])!
                        print("USING EXISTING PRIVATE LIST RECORD!!")
                        print("Current inventory list is: \(String(describing: self.inventoryRecord)))")
                }
                }
            })
        }
    }
    
    /// Update core data with all changes made in cloud
    func syncCoreDataToCloud() {
        var mustDelete = false
        coreDataItems = getCoreDataitems()
        
        // configure fetch based on previous fetch token
        let fetchChangedRecordsOptions = CKFetchRecordZoneChangesOptions()
        fetchChangedRecordsOptions.previousServerChangeToken = UserDefaults.standard.serverChangeToken
        let fetchChangedRecords = CKFetchRecordZoneChangesOperation(recordZoneIDs: [myZoneID], optionsByRecordZoneID: [myZoneID: fetchChangedRecordsOptions])
        
        // completion block
        fetchChangedRecords.fetchRecordZoneChangesCompletionBlock =
            { error in
                if let err = error {
                    print (err)
                }
        }
        
        // perform on each fetched record
        fetchChangedRecords.recordChangedBlock =
            { record in
                if (record.recordType == "Item"){
                    // look for matching item in array and update that item
                    let recordName = String(record.object(forKey: Cloud.Attribute.Name) as! NSString)
                    var updated = false
                    for CDItem in self.coreDataItems {
                        if CDItem.name == recordName {
                            self.updateItemFromRecord(item: CDItem, record: record, keysToChange: record.allKeys())
                            updated = true
                        }
                    }
                    if updated == false {
                        self.createItemFromRecord(record: record)
                    }
                }
        }
        
        // delete attempt
        fetchChangedRecords.recordWithIDWasDeletedBlock =
            { recordID, nameID in
                mustDelete = true
        }
        
        
        // perform when complete
        fetchChangedRecords.recordZoneFetchCompletionBlock =
            { recordZoneID, token, data, didComplete, error in
                
                if (mustDelete){
                // backhanded deletion
                self.removeDeletedRecords()
                }
                
                UserDefaults.standard.serverChangeToken = token
        }
        myDatabase.add(fetchChangedRecords)
        
    }// end of sync core data
    
    private func getCoreDataitems() -> [Item]{
        var coreDataitems = [Item]()
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        do {
            let result = try context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult> )
            coreDataitems = result as! [Item]
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        // will return nil if no items present
        return coreDataitems
    }
    
    /// deletes items with the same name and creates new item with value
    // tries to update, if item does not exist it creates new
    func updateItemInCloud(item: Item, keysToChange: [String]?){
        var keys = keysToChange
        if let itemName = item.name {
            // query for record with same name
            let query = CKQuery(recordType: Cloud.Entity.Item, predicate: NSPredicate(format: "name == %@", itemName))
            myDatabase.perform(query, inZoneWith: myZoneID, completionHandler: { (records, error) in
                if error != nil {
                    print("Error querying records for item: \(error?.localizedDescription)")
                } else {
                    print(records.debugDescription)
                    if let myRecords : [CKRecord] = records {
                        print("records found")
                        // find record
                        if let record = myRecords.first {
                            let id = record.recordID
                            if keysToChange == nil {
                                keys = record.allKeys()
                            }
                            self.updateRecordFromItem(item: item, record: record, id: id, keysToChange: keys!)
                        }
                    } else {
                        self.createItemInCloud(item: item)
                    }
                    self.saveZone()
                }
            })
        }
    }
    
    func updateRecordFromItem(item: Item, record: CKRecord, id: CKRecordID, keysToChange: [String]){
        // change based on passed keys array
        for key in keysToChange {
            switch key {
            // Amount left CAST as INT16
            case Cloud.Attribute.AmountLeft:
                let newAmount = item.amountLeft as CKRecordValue
                record.setObject(newAmount, forKey: key)
                break
            // Category
            case Cloud.Attribute.Category:
                let newCategory = item.category?.name as! CKRecordValue
                record.setObject(newCategory, forKey: key)
                break
            //  DateStocked
            case Cloud.Attribute.DateStocked:
                if let newDateStocked = item.dateStocked {
                    let date = newDateStocked as? CKRecordValue
                    record.setObject(date, forKey: key)
                }
                break
            //  IsOnAList
            case Cloud.Attribute.IsOnAList:
                var newListSetting: Int16 = 0
                if item.isOnAList {
                    newListSetting = 1
                }
                record.setObject(newListSetting as CKRecordValue?, forKey: key)
                break
            // mustKeepOnHand
            case Cloud.Attribute.MustKeepOnHand:
                var newListSetting: Int16 = 0
                if item.mustKeepOnHand {
                    newListSetting = 1
                }
                record.setObject(newListSetting as CKRecordValue?, forKey: key)
                break
            //  name
            case Cloud.Attribute.Name:
                if let name = item.name {
                    record.setObject(name as NSString, forKey: key)
                }
                break
            //  text
            case Cloud.Attribute.Notes:
                if let notes = item.notes {
                    record.setObject(notes as NSString, forKey: key)
                }
                break
            //  prefferedStore
            case Cloud.Attribute.PreferredStore:
                if let store = item.preferredStore {
                    record.setObject(store as NSString, forKey: key)
                }
                break
            //  priority
            case Cloud.Attribute.Priority:
                let newAmount = item.priority as CKRecordValue
                record.setObject(newAmount, forKey: key)
                break
            default: break
            }
        }
        let savingOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        myDatabase.add(savingOp)
        saveZone()
    }


    
    func createItemInCloud(item: Item){
        // define record
        let record = CKRecord(recordType: Cloud.Entity.Item, zoneID: self.myZoneID)
        
        // set attributes
        record[Cloud.Attribute.AmountLeft] = item.amountLeft as CKRecordValue?
        record[Cloud.Attribute.Category] = item.category?.name as? CKRecordValue
        record[Cloud.Attribute.DateStocked] = item.dateStocked as CKRecordValue?
        record[Cloud.Attribute.Priority] = item.priority as CKRecordValue
        
        var newListSetting: Int16 = 0
        if item.isOnAList {
            newListSetting = 1
        }
        record[Cloud.Attribute.IsOnAList] = newListSetting as CKRecordValue
        newListSetting = 0
        if item.mustKeepOnHand {
            newListSetting = 1
        }
        record[Cloud.Attribute.MustKeepOnHand] = newListSetting as CKRecordValue
        
        if let name = item.name {
            record.setObject(name as NSString, forKey: Cloud.Attribute.Name)
        }
        if let notes = item.notes {
            record.setObject(notes as NSString, forKey: Cloud.Attribute.Notes)
        }
        if let store = item.preferredStore {
            record.setObject(store as NSString, forKey: Cloud.Attribute.PreferredStore)
        }
        record.setParent(self.inventoryRecord!)
        
        // Save this record
        self.myDatabase.save(record, completionHandler: { (savedRecord, saveError) in
            if saveError != nil {
                print("Error saving record: \(saveError?.localizedDescription)")
            } else {
                self.saveZone()
            }
        })
        
    }
    
    // backhanded delete function until IDs implemented
    func removeDeletedRecords(){
        var name = ""
        let items = getCoreDataitems()
        for item in items {
            // query for record with same name
            name = item.name!
            let query = CKQuery(recordType: Cloud.Entity.Item, predicate: NSPredicate(format: "name == %@", name))
            myDatabase.perform(query, inZoneWith: myZoneID, completionHandler: { (records, error) in
                if error != nil {
                    print("Error querying records to check for deleted records: \(error?.localizedDescription)")
                } else {
                    if records?.count != 1 {
                        context.delete(item)
                        print("\(item.name) deleted from core data context")
                    }
                }
            })
        }
        ad.saveContext()
    }
    
    
    // deletes item
    func deleteItemInCloud(item: Item){
        if let itemName = item.name {
            // query for record with same name
            let query = CKQuery(recordType: Cloud.Entity.Item, predicate: NSPredicate(format: "name == %@", itemName))
            myDatabase.perform(query, inZoneWith: myZoneID, completionHandler: { (records, error) in
                if error != nil {
                    print("Error querying records for item: \(error?.localizedDescription)")
                } else {
                    if let myRecords = records {
                        // find record
                        for record in myRecords {
                            self.myDatabase.delete(withRecordID: record.recordID, completionHandler: {(records, error) in
                                if error != nil {
                                    print("Error deleting records.")
                                }
                            })
                        }
                    }
                }
                self.saveZone()
            })
        }
    }
    
    func updateItemFromRecord(item: Item, record: CKRecord, keysToChange: [String])
    {
        // change based on passed keys array
        for key in keysToChange {
            switch key {
            // Amount left CAST as INT16
            case Cloud.Attribute.AmountLeft:
                item.amountLeft = record[Cloud.Attribute.AmountLeft] as! Int16
                break
            // Category
            case Cloud.Attribute.Category:
                let cat = record[Cloud.Attribute.Category] as! NSString? //TODO: Update elsewhere
                item.category = Category.categoryWithName(name: cat as! String, context: context)
                break
            //  DateStocked
            case Cloud.Attribute.DateStocked:
                item.dateStocked = record[Cloud.Attribute.DateStocked] as! NSDate?
                break
            //  IsOnAList
            case Cloud.Attribute.IsOnAList:
                let listSetting = record[Cloud.Attribute.IsOnAList] as! Int16
                if listSetting == 1 {
                    item.isOnAList = true
                } else {
                    item.isOnAList = false
                }
                break
            // mustKeepOnHand
            case Cloud.Attribute.MustKeepOnHand:
                let listSetting = record[Cloud.Attribute.MustKeepOnHand] as! Int16
                if listSetting == 1 {
                    item.mustKeepOnHand = true
                } else {
                    item.mustKeepOnHand = false
                }
                break
            //  name
            case Cloud.Attribute.Name:
                item.name = (record[Cloud.Attribute.Name] as! NSString) as String
                break
            //  text
            case Cloud.Attribute.Notes:
                item.notes = (record[Cloud.Attribute.Notes] as! NSString) as String
                break
            //  prefferedStore
            case Cloud.Attribute.PreferredStore:
                item.preferredStore = (record[Cloud.Attribute.PreferredStore] as! NSString) as String
                break
            //  priority
            case Cloud.Attribute.Priority:
                item.priority = record[Cloud.Attribute.Priority] as! Int16
                break
            default: break
            }
        }
        saveZone()
        ad.saveContext()
    }
    
    func createItemFromRecord(record: CKRecord) {
        let item = Item(context: context)
        item.recordName = record.recordID.recordName
        item.amountLeft = record[Cloud.Attribute.AmountLeft] as! Int16
        let cat = record[Cloud.Attribute.Category] as! NSString
        item.category = Category.categoryWithName(name: cat as String, context: context)
        item.dateStocked = record[Cloud.Attribute.DateStocked] as! NSDate?
        var listSetting = record[Cloud.Attribute.IsOnAList] as! Int16
        if listSetting == 1 {
            item.isOnAList = true
        } else {
            item.isOnAList = false
        }
        listSetting = record[Cloud.Attribute.MustKeepOnHand] as! Int16
        if listSetting == 1 {
            item.mustKeepOnHand = true
        } else {
            item.mustKeepOnHand = false
        }
        item.name = (record[Cloud.Attribute.Name] as! NSString) as String
        // item.notes = (record[Cloud.Attribute.Notes] as! NSString) as String
        // if let pref = (record[Cloud.Attribute.PreferredStore] as! NSString) as String
        item.priority = record[Cloud.Attribute.Priority] as! Int16
        ad.saveContext()
    }
    
    func saveZone (){
        print("saveZone CALLED")
        // Save the zone in the private database
        myDatabase.save(myZone, completionHandler: ({returnRecord, error in
            if error != nil {
                // Zone creation failed
                print("Zone creation failed: \(error)")
            } else {
                // success
            }
        }))
    }
    
    
}// end of class




