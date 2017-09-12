//
//  Category+CoreDataProperties.swift
//  Pantri
//
//  Created by Mariah Olson on 3/8/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category");
    }

    @NSManaged public var name: String?
    @NSManaged public var item: NSSet?

}

// MARK: Generated accessors for item
extension Category {

}
