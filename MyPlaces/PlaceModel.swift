//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Дарья Станкевич on 3/30/20.
//  Copyright © 2020 Sergey Mikovoz. All rights reserved.
//

import Foundation

struct Place {
    
    var name: String
    var location: String
    var type: String
    var image: String
    
    static let restaurantNames = ["Балкан", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai"]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Минск", type: "Ресторан", image: place))
        }
        
        return places
    }
}


