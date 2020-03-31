//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Дарья Станкевич on 3/31/20.
//  Copyright © 2020 Sergey Mikovoz. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
        
    }
}
