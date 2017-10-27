//
//  ImageCache.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 10/26/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache<AnyObject, AnyObject>()
    
    //MARK:- Retrieving Images
    
    func imageWithIdentifier(identifier:String?) -> UIImage? {
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier: identifier!)
        var data: NSData?
        
        // Memory Cache
        if let image = inMemoryCache.object(forKey: path as AnyObject) as? UIImage {
            return image
        }
        
        //if not in Memory cache, then in Hard drive
        if let data = NSData(contentsOfFile: path) {
            let thisImage = UIImage(data: data as Data)
            return UIImage(data: data as Data)
        }
        return nil
        
    }
    
    //MARK: Saving Images
    func storeImage(image:UIImage?, withIdentifier identifier:String) {
        
        do {
            let path = pathForIdentifier(identifier: identifier)
            
            //If the image is nil, remove images from cache and hard disk
            if image == nil {
                inMemoryCache.removeObject(forKey: path as AnyObject)
                 try FileManager.default.removeItem(atPath: path)
                return
            }
            
            //Otherwise keep image in memory
            inMemoryCache.setObject(image!, forKey: path as AnyObject)
            
            // And add in documents directory
            let data = UIImagePNGRepresentation(image!)
          
            try data?.write(to: URL(fileURLWithPath: path))
            
           
        } catch let error {
            print("Error while trying save images url.",error)
        }
  
        
    }
    
    
    //MARK:- Imagepath based on Id
    
    func pathForIdentifier(identifier:String) -> String {
        let documentsDirectoryURL: NSURL =  FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first! as! NSURL
        
        let fullPathURL = documentsDirectoryURL.appendingPathComponent(identifier)
        return fullPathURL!.path
    }
    
}
