//
//  PicGalleryViewController.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 10/15/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PicGalleryViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate {
    
    // Location object for which Flickr images are displayed in collection view
    var location:Location!
    
    // Track index paths for Selection, Insertion, Update and Deletion of images
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // Datatask to fetch images for new collection
    var dataTask: URLSessionDataTask?
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newPhotoCollectionButton: UIBarButtonItem!
    @IBOutlet weak var dataDownloadActivityIndicator: UIActivityIndicatorView!
    
    
    
    //MARK:- Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.hidden = false
//        self.navigationController?.navigationItem.hidesBackButton = false
//        self.navigationController?.toolbarHidden = false
//
//        //Display the annotation for location
//        setMapRegionAndAddAnnotation(true)
//
//        dataDownloadActivityIndicator.startAnimating()
//
//        // Start the fetched results controller
        do {
                var error: NSError?
                try fetchedResultsController.performFetch()
                if let error = error {
                    print("Error performing initial fetch: \(error)")
                }
                fetchedResultsController.delegate = self
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
//
//        // Tool bar button to toggle New collection and Save collection button
//        updateToolbarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This is called rarely - as Flickr photos are already fetched when pin is dropped on the map in previous view controller
        if location.photos.isEmpty {
            var currentPageNumber = 0
            loadNewCollection(currentPageNumber: currentPageNumber)
        }
    }
    
    func loadNewCollection(currentPageNumber _: Int)
    {
        //Pre-Fetch photos entites related to this location and save to core data
        
//        FlickrClient.sharedInstance().prefetchPhotosForLocationAndSaveToDataContext(locationToBeAdded) {
//            error in
//            if let errorMessage = error {
//                println(errorMessage.localizedDescription)
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the delegate reference
        fetchedResultsController.delegate = nil
        
        // Stop all the downloading tasks
        if dataTask?.state == URLSessionTask.State.running {
            dataTask?.cancel()
        }
    }
    
    //Layout collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width, with space
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(photoCollectionView.frame.width / 3)
        layout.itemSize = CGSize(width: width, height: width)
        photoCollectionView.collectionViewLayout = layout
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionView", for: indexPath) as! PhotoCollectionView
        
     //   configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // This method will download the image and display as soon  as the imgae is downloaded
    func configureCell(cell:PhotoCollectionView, atIndexPath indexPath:NSIndexPath) {
        
        //dataDownloadActivityIndicator.stopAnimating()
        
        // Show the placeholder image till the time image is being downloaded
        let photo = self.fetchedResultsController.object(at: indexPath as IndexPath) as! Photo
        var cellImage = UIImage(named: "imagePlaceholder")
        cell.photoImage.image = nil
        
        // Set the flickr image if already available (from hard disk or image cache)
        if photo.image != nil {
            cellImage = photo.image
        } else {
            
            //If image is not available, download the flickr image
            //Start the task that will eventually download the image
            
            cell.photoDownloadActivityIndicator.startAnimating()
            
            let task = FlickrClient.sharedInstance().taskForImage(filePath: photo.imageUrl) {
                data, error in
                if let downloaderror = error {
                    print("Flick image download error: \(downloaderror.localizedDescription)")
                    cell.photoDownloadActivityIndicator.stopAnimating()
                }
                if let imageData = data {
                    
                    // Create the image
                    let image = UIImage(data: imageData as Data)
                    
                    // Update the model so that information gets cached
                    photo.image = image
                    
                    // update the cell later, on the main thread
                    DispatchQueue.main.async{
                        
                        photo.downloadStatus = true
                        cell.photoImage.image = image
                        cell.photoDownloadActivityIndicator.stopAnimating()
                        
                        // Update the state of the image that it is downloaded
//                        CoreDataStackManager.sharedInstance().saveContext()
                        
//                        self.updateToolbarButton()
                    }
                } else {
                    print("Data is not convertible to Image Data.")
                    cell.photoDownloadActivityIndicator.stopAnimating()
                }
            }
//            cell.taskToCancelifCellIsReused = task
        }
        
        cell.photoImage.image = cellImage
        
        //If the cell is selected, it will show delete button
//        if let index = find(selectedIndexes, indexPath) {
//            cell.deleteButton.hidden = false
//            cell.photoImage.alpha = 0.5
//        } else {
//            cell.deleteButton.hidden = true
//            cell.photoImage.alpha = 1.0
//        }
    }
    //MARK:- Core Data Operations
    var sharedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    //MARK:- Core Data
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.location)
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultController
    }()
    
}

