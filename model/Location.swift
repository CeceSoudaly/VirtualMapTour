//
//  Location+CoreDataClass.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 9/8/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import CoreData


public class Location: NSManagedObject {
    
    // Core data object attributes
    @NSManaged var title: String
    @NSManaged var subtitle: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
    
    // Keys to convert dictionary into object
    struct Keys {
        static let Title = "title"
        static let Subtitle = "subtitle"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    convenience init(dictionary:[String:AnyObject],context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Location", in: context) {
            self.init(entity: ent, insertInto: context)
            
            print("Keys.Latitude === >",dictionary[Keys.Latitude])
            if let longitude = dictionary[Keys.Latitude]  as? Double
            {
                self.longitude = longitude
            }
           
            if let Latitude = dictionary[Keys.Latitude]  as? Double
            {
                self.longitude = Latitude
            }
            
            if let Latitude = dictionary[Keys.Latitude]  as? Double
            {
                self.longitude = Latitude
            }
            
            if let Title = dictionary[Keys.Title]  as? String
            {
                self.title =  Title
            }
            
            if let Subtitle = dictionary[Keys.Subtitle]  as? String
            {
                self.subtitle =  Subtitle
            }
            
            
            
            
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }


}
