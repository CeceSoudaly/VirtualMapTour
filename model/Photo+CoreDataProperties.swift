//
//  Photo+CoreDataProperties.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 8/27/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var album: NSData?
    @NSManaged public var id: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var name: String?
    @NSManaged public var state: Int64
    @NSManaged public var location: Location?

}
