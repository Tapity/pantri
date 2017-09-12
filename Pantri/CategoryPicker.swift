//
//  CategoryPicker.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit

class CategoryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    // define categories
    var categories = ["Dairy", "Meat & Deli", "Vegetables", "Fruit", "Baking", "Drinks", "Snacks", "Household Goods", "Canned Goods", "Pastas & Cereals", "Breads & Pastries"]
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // nothing needed?
    }

}
