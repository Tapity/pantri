//
//  AddItemVC.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit

class AddItemVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var priorityControl: UISegmentedControl!

    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var notesField: UITextField!
    
    @IBOutlet weak var currentStockControl: UISegmentedControl!
    
    @IBOutlet weak var keepStockedSwitch: UISwitch!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var priorityHeight: NSLayoutConstraint!
    
    
    
    var inNav = false // PROBABLY WONT USE
    var picker : CategoryPicker!
    var itemToEdit : Item?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text field delegates
        self.notesField.delegate = self
        self.nameField.delegate = self
        
        // create back button on nav bar
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        // put data in picker
        picker = CategoryPicker()
        categoryPicker.delegate = picker
        categoryPicker.dataSource = picker
        
        // set state of add button & hide priority setting
        nameField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        // check if there is data to load
        if itemToEdit != nil {
            loadItemData()
            nameField.isEnabled = false
        } else {
            // if there is not an old item, wait to enable save
            addButton.isEnabled = false
        }
        
        // check if we came from grocery list
        if (!inNav){
            keepStockedSwitch.setOn(true, animated: false)
        }
    }
    
    @IBAction func setKeepSlider(_ sender: Any) {
        if (keepStockedSwitch.isOn) {
            priorityHeight.constant = 28
            priorityControl.isHidden = false
        } else {
            priorityHeight.constant = 0
            priorityControl.isHidden = true
        }
    }
    
    // maintain save button state
    func editingChanged(_ textField: UITextField) {
        // if a space is first char, consider empty
        if nameField.text?.characters.count == 1 {
            if nameField.text?.characters.first == " " {
                nameField.text = ""
                return
            }
        }
        // check to see if text field stops being empty
        guard
            let field = nameField.text, !field.isEmpty
            else {
                addButton.isEnabled = false
                return
        }
        addButton.isEnabled = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var item: Item!
        let brandNewItem = (itemToEdit == nil)
        
        // check if we are editing old or creating new
        if brandNewItem {
            item = Item(context: context)
        } else {
            item = itemToEdit!
        }
        
        // set fields
        if let name = nameField.text {
            item.name = name
        }
        let categoryName = picker.categories[categoryPicker.selectedRow(inComponent: 0)]
        item.category = Category.categoryWithName(name: categoryName, context: context)

        if let notes = notesField.text {
            item.notes = notes
        }
        item.priority = Int16(priorityControl.selectedSegmentIndex)
        item.amountLeft = Int16(currentStockControl.selectedSegmentIndex)
        item.mustKeepOnHand = keepStockedSwitch.isOn
        
        if(!brandNewItem){
        cloud.updateItemInCloud(item: item, keysToChange: nil)
        } else {
        cloud.createItemInCloud(item: item)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        // delete item currently being edited
        if itemToEdit != nil {
            cloud.deleteItemInCloud(item: itemToEdit!)
            context.delete(itemToEdit!)
            ad.saveContext()
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Load data into fields if editing old item
    func loadItemData() {
        if let item = itemToEdit {
            
            // load each field with preset data
            nameField.text = item.name
            
            // category picker may cause errors
            if let category = item.category?.name {
                var index = 0
                repeat {
                    let t = picker.categories[index]
                    if t == category {
                        categoryPicker.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    index += 1
                } while (index < picker.categories.count)
            }
            priorityControl.selectedSegmentIndex = Int(item.priority)
            currentStockControl.selectedSegmentIndex = Int(item.amountLeft)
            notesField.text = item.notes
        }
    }
    

}
