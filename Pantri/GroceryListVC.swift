//
//  SecondViewController.swift
//  Pantri
//
//  Created by Mariah Olson on 3/6/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import UIKit
import CoreData

class GroceryListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fruitTableView: UITableView!
    
    @IBOutlet weak var meatTableView: UITableView!
    
    @IBOutlet weak var fruitTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var meatTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var fruitCountLabel: UILabel!
    
    @IBOutlet weak var fruitHeader: UIView!
    
    @IBOutlet weak var meatCountLabel: UILabel!
    
    @IBOutlet weak var meatHeader: UIView!
    
    @IBOutlet weak var fruitHeaderHeight: NSLayoutConstraint!
    
    @IBOutlet weak var meatHeaderHeight: NSLayoutConstraint!
    
    // set variables for how many kinds of general foods we want to keep on hand
    let fruitStockMin = 3
    let meatStockMin = 4
    
    // initialize controllers
    var fruitController: NSFetchedResultsController<Item>!
    var meatController: NSFetchedResultsController<Item>!
    var controller: NSFetchedResultsController<Item>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fruitTableView.delegate = self
        fruitTableView.dataSource = self
        
        meatTableView.delegate = self
        meatTableView.dataSource = self
        
        // ATEMPT ONLY IF NECESSARY
        attemptFruitFetch()
        attemptMeatFetch()
        attemptFetch()
        
        updateCategoryCountLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateCategoryCountLabel()
        fruitHeader.layer.borderColor = UIColor(red: 0.5098, green: 0.8078, blue: 0.5529, alpha: 1.0).cgColor /* #2d512a */
        meatHeader.layer.borderColor = UIColor(red: 0.5098, green: 0.8078, blue: 0.5529, alpha: 1.0).cgColor
    }
    
    // fruit config
    @IBAction func fruitExtendPressed(_ sender: UIButton) {
        if (fruitTableViewHeight.constant == 0) {
            loadFruitView(doConstrain: false)
        } else {
            loadFruitView(doConstrain: true)
        }
    }
    
    @IBAction func meatExtendPressed(_ sender: UIButton) {
        if (meatTableViewHeight.constant == 0) {
            loadMeatView(doConstrain: false)
        } else {
            loadMeatView(doConstrain: true)
        }
    }
    
    func loadFruitView(doConstrain: Bool){
        if (doConstrain){
            fruitTableViewHeight.constant = 0
        } else {
        var numRows = fruitTableView.numberOfRows(inSection: 0)
        numRows = numRows * 50
        fruitTableViewHeight.constant = CGFloat(numRows)
        }
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func loadMeatView(doConstrain: Bool){
        if (doConstrain){
            fruitTableViewHeight.constant = 0
        } else {
        var numRows = meatTableView.numberOfRows(inSection: 0)
        numRows = numRows * 50
        meatTableViewHeight.constant = CGFloat(numRows)
        }
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateCategoryCountLabel(){
        let fruitCountRequest : NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
        let fruitCountPredicate = NSPredicate(format: "(category.name == %@) && (amountLeft = 2)", "Fruit")
    fruitCountRequest.predicate = fruitCountPredicate
        do {
    let labelCount = try context.count(for: fruitCountRequest)
            if (labelCount < fruitStockMin){
                fruitHeaderHeight.constant = 50
                fruitCountLabel.text = String(labelCount)
                fruitCountLabel.isHidden = false
            } else {
                // HIDE LABEL
                fruitCountLabel.isHidden = true
                fruitHeaderHeight.constant = 0
                self.loadFruitView(doConstrain: true)
                print("constraining header")
                UIView.animate(withDuration: 0) {
                    self.view.layoutIfNeeded()
                }
            }
        } catch {
            // error
        }
        
        let meatCountRequest : NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
        let meatCountPredicate = NSPredicate(format: "(category.name == %@) && (amountLeft = 2)", "Meat & Deli")
        meatCountRequest.predicate = meatCountPredicate
        do {
            let labelCount = try context.count(for: meatCountRequest)
            if (labelCount < meatStockMin){
                meatHeaderHeight.constant = 50
                meatCountLabel.text = String(labelCount)
                meatCountLabel.isHidden = false
            } else {
                // HIDE LABEL
                meatCountLabel.isHidden = true
                self.loadMeatView(doConstrain: true)
                meatHeaderHeight.constant = 0
                UIView.animate(withDuration: 0) {
                    self.view.layoutIfNeeded()
                }
            }
        } catch {
            // error
        }
    }
}

