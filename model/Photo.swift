//
//  Photo+CoreDataClass.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 8/28/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Photo: NSManagedObject {
    
    // Core data object attributes
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var imageUrl: String
    @NSManaged var downloadStatus: Bool
    @NSManaged var location: Location
    @NSManaged var pageNumber: NSNumber
    
    // Keys to convert dictionary into object
    struct Keys {
        static let Id = "id"
        static let Name = "title"
        static let ImageUrl = "url_m"
        static let DownloadStatus = "downloadStatus"
        static let PageNumber = "pageNumber"
    }
    
    
    convenience init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Notebook", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = dictionary[Keys.Id] as! String
            self.title = dictionary[Keys.Name] as! String
            self.imageUrl = dictionary[Keys.ImageUrl] as! String
            downloadStatus = false
            self.pageNumber = dictionary[Keys.PageNumber] as! NSNumber
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

//    // Init method to insert object in core data
//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        super.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
    
    // Init method that will convert photo dictionary into managed object and insert in core data
//    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
//        
//        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
//        
//        super.init(entity: entity,insertIntoManagedObjectContext: context)
//        
//        id = dictionary[Keys.Id] as! String
//        title = dictionary[Keys.Name] as! String
//        imageUrl = dictionary[Keys.ImageUrl] as! String
//        downloadStatus = false
//        pageNumber = dictionary[Keys.PageNumber] as! NSNumber
//    }
//    
//    // This method will first delete the underlying image file from documents directory when a photo object is removed from core data
//    override func prepareForDeletion() {
//        super.prepareForDeletion()
//        self.image = nil
//    }
//    
//    // Download image to documents directory and retrieve it using image identifier
//    var image: UIImage? {
//        get {
//            return FlickrClient.Caches.imageCache.imageWithIdentifier(id)
//        }
//        set {
//            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: id)
//        }
//    }
}
