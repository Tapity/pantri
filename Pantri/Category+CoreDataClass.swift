//
//  Category+CoreDataClass.swift
//  Pantri
//
//  Created by Mariah Olson on 3/8/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject {
    
    // create category/find old category
    class func categoryWithName(name: String, context: NSManagedObjectContext) -> Category? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.predicate = NSPredicate(format: "name = %@", name)
        if let myCategory = (try? context.fetch(request))?.first as? Category {
            return myCategory
        } else if let myCategory = NSEntityDescription.insertNewObject(forEntityName: "Category", into: context) as? Category {
            myCategory.name = name
            return myCategory
        }
        return nil
    }

}
