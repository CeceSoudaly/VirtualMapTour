//
//  Location+CoreDataClass.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 10/28/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//
//
import Foundation
import CoreData


class Location: NSManagedObject {
    
    // Core data object attributes
    @NSManaged var title: String
    @NSManaged var subtitle: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
  //  @NSManaged var photos: [Photo]
    
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
            
            self.init(dictionary: ent, context: context)
            
            if let longitude = dictionary[Keys.Longitude]  as? Double
            {
                self.longitude = longitude
            }
            
            if let Latitude = dictionary[Keys.Latitude]  as? Double
            {
                //self.latitude = Latitude
            }
            
            if let Title = dictionary[Keys.Title]  as? String
            {
                //self.title =  Title
            }
            
            if let Subtitle = dictionary[Keys.Subtitle]  as? String
            {
               // self.subtitle =  Subtitle
            }
            
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    
}


