//
//  Location+CoreDataProperties.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 9/8/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
//
//    @NSManaged public var latitude: Double
//    @NSManaged public var longitude: Double
//    @NSManaged public var subtitle: String?
//    @NSManaged public var title: String?
//    @NSManaged public var photo: Photo?
    
   
}

// MARK: Generated accessors for photo
extension Location {
    
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)
    
}

