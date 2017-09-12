//
//  UserDefaults+Conversion.swift
//  Pantri
//
//  Created by Mariah Olson on 3/12/17.
//  Copyright © 2017 Mariah Olson. All rights reserved.
//


import Foundation
import CloudKit

public extension UserDefaults {
    
    public var serverChangeToken: CKServerChangeToken? {
        get {
            guard let data = self.value(forKey: "ChangeToken") as? Data else {
                return nil
            }
            
            guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken else {
                return nil
            }
            return token
        }
        set {
            if let token = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: token)
                self.set(data, forKey: "ChangeToken")
            } else {
                self.removeObject(forKey: "ChangeToken")
            }
        }
    }
}
