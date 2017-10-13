//
//  FlickrCoreDataManager.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 9/3/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import CoreData

/* Flicker client extension to fetch photos object for associated location object */

extension FlickrClient {
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().context
    }
 
    
    //Wrapper method to download new Flickr photo collection based on next Page number
    
    func fetchPhotosForNewAlbumAndSaveToDataContext(location:Location, nextPageNumber:Int, errorHandler: @escaping (_ error: NSError?) -> Void) -> URLSessionDataTask {
        return prefetchPhotosForLocationAndSaveToDataContext(location: location, nextPageNumber: nextPageNumber, errorHandler: errorHandler)
    }
    
    // Pre-fetch Flickt photo collection
    
    func prefetchPhotosForLocationAndSaveToDataContext(location:Location , nextPageNumber:Int? = nil, errorHandler: @escaping (_ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Set the page number
        var newPageNumber = nextPageNumber == nil ? 1 : nextPageNumber!
        
        // Create the task
        let task =  FlickrClient.sharedInstance().getFlickrImagesByLatLon(latitude: location.latitude, longitude: location.longitude, nextPageNumber: newPageNumber) {
            
            photosDict, error in
            
            // Handle error using Closure
            if let errorMessage = error {
                
                errorHandler(errorMessage)
                
            } else {
                
                if let photosArrayDictionary = photosDict as [[String : AnyObject]]? {
                    
                    print("Total number of photos are : \(photosArrayDictionary.count)")
                    
                    //Parse the array of PhotosArrayDictionary
                    var photos = photosArrayDictionary.map() {
                        (dictionary: [String:AnyObject]) -> Photo in
                        var newDictionary = dictionary
                        newDictionary["pageNumber"] = newPageNumber as AnyObject
                        
                        let photoToBeAdded = Photo(dictionary: newDictionary, context: self.sharedContext)
                        photoToBeAdded.location = location
                        return photoToBeAdded
                    }
                }
                
            }
        }
        
//        dispatch_async(dispatch_get_main_queue()) {
//            FlickrCoreDataManager.saveContext()
//        }
        return task
    }
}
