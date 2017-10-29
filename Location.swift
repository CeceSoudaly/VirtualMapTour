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
    
    // Init method to insert object in core data
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(dictionary:[String:AnyObject],context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Location", in: context) {
            let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)!
            
            self.init(entity: entity, insertInto: context)
            
            title = dictionary[Keys.Title] as! String
            subtitle = dictionary[Keys.Subtitle] as! String
            latitude = dictionary[Keys.Latitude] as! Double
            longitude = dictionary[Keys.Longitude] as! Double
            
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    
}


