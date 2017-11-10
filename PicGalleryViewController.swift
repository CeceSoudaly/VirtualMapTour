//
//  PicGalleryViewController.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 10/15/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseIdentifier = "PicGallery"

class PicGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    // Location object for which Flickr images are displayed in collection view
    var location:Location!
    var photoData:[Photo] = [Photo]()
    var selectedIndexPaths = [NSIndexPath]()
    var currentPage = 0
    //MARK:- Core Data Operations
    var sharedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // Track index paths for Selection, Insertion, Update and Deletion of images
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // Datatask to fetch images for new collection
    var dataTask: URLSessionDataTask?
    
//    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
  
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    
    //@IBOutlet weak var newPhotoCollectionButton: UIBarButtonItem!
    @IBOutlet weak var dataDownloadActivityIndicator: UIActivityIndicatorView!
    
    
    
    //MARK:- Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
       // locationMapView.delegate = self
        // Register cell classes
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //addSelectedAnnotation()
        print("selected pin location: \(location)")
        
        fetchPhotos()
        
        // MARK: Set spacing between items
        let space: CGFloat = 3.0
        let viewWidth = self.view.frame.width
        let dimension: CGFloat = (viewWidth-(2*space))/3.0
   
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // This is called rarely - as Flickr photos are already fetched when pin is dropped on the map in previous view controller
//        if location.photos.isEmpty {
//            var currentPageNumber = 0
//            //loadNewCollection(currentPageNumber: currentPageNumber)
//             fetchPhotos()
//        }
//    }
    
    // new flickr image collection by taking into account next page number
    func loadNewCollection(currentPageNumber: Int) {
        dataTask = FlickrClient.sharedInstance().fetchPhotosForNewAlbumAndSaveToDataContext(location: location , nextPageNumber: currentPageNumber + 1) {
            error in
            if let errorMessage = error {
                DispatchQueue.main.async() {
                    var alert =  UIAlertController(title: "Search Error", message: errorMessage.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: {
                        self.dataDownloadActivityIndicator.stopAnimating()
                    })
                }
            }
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // Remove the delegate reference
//        //NSFetchedResultsController.delegate = nil
//
//        
//        // Stop all the downloading tasks
//        if dataTask?.state == URLSessionTask.State.running {
//            dataTask?.cancel()
//        }
//    }
    
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
    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return NSFetchedResultsController.sections?.count ?? 0
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         print("photoData.count: \(photoData.count)")
        return photoData.count
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        
        let index = selectedIndexPaths.index(of: indexPath as NSIndexPath)
        
        if let index = index {
            selectedIndexPaths.remove(at: index)
            cell.photoImage.alpha = 1.0
        } else {
            selectedIndexPaths.append(indexPath as NSIndexPath)
            print(selectedIndexPaths)
            selectedIndexPaths.sort{$1.row < $0.row}
            print("Selected IndexPaths: \(selectedIndexPaths)")

            cell.photoImage.alpha = 0.25
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        configureCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    // This method will download the image and display as soon  as the imgae is downloaded
    func configureCell(cell:PhotoCell, atIndexPath indexPath:NSIndexPath) {
        
        dataDownloadActivityIndicator.stopAnimating()
        
        // Show the placeholder image till the time image is being downloaded
        if cell != nil {
            //print("\(PhotoCell)")
        }
        
        let photo = photoData[indexPath.row]
        
        var cellImage = UIImage(named: "imagePlaceholder")
        cell.photoImage.image = nil
        
        // Set the flickr image if already available (from hard disk or image cache)
        if photo.image != nil {
            cellImage = photo.image
        } else {
            
            //If image is not available, download the flickr image
            //Start the task that will eventually download the image
            
            cell.photoDownloadActivityIndicator.startAnimating()
            
            let task = FlickrClient.sharedInstance().taskForImage(filePath: photo.imageUrl!) {
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
                    DispatchQueue.main.async() {
                        
                        photo.downloadStatus = true
                        cell.photoImage.image = image
                        cell.photoDownloadActivityIndicator.stopAnimating()
                        
                        // Update the state of the image that it is downloaded
                      // self.sharedContext.save()
                        
                       // self.updateToolbarButton()
                    }
                } else {
                    print("Data is not convertible to Image Data.")
                    cell.photoDownloadActivityIndicator.stopAnimating()
                }
            }
           // cell.taskToCancelifCellIsReused = task
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
 
    //MARK:- Core Data
    
    func fetchPhotos(){
        
        //MARK: Fetch Request
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest() as! NSFetchRequest<Photo>
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "location = %@", self.location)
        let context = self.sharedContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        if let data = fetchedResultsController.fetchedObjects, data.count > 0 {
            print("\(data.count) photos from core data fetched.")
            photoData = data
            self.photoCollectionView.reloadData()
        } else {
           getPhotosFromFlickr(currentPageNumber:currentPage)
        }
    }
    
    //MARK: get new collection of photos from flickr

    func getPhotosFromFlickr(currentPageNumber: Int) {
        
        FlickrClient.sharedInstance().getImagesFromFlickr(location,currentPage) { (results, error) in
            
            guard error == nil else {
                self.displayAlert(title: "Could not get photos from flickr", message: error?.localizedDescription)
                return
            }
          
           DispatchQueue.main.async() {
                if results != nil {
                    self.photoData = results!
                    
                    print("\(self.photoData.count) photos from flickr fetched")
                    self.photoCollectionView.reloadData()
                }
            }
        }
    }
    
    // Alert
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            // present(alert, animated: true, completion: nil)
        }
    }
    //MARK:- Core Data
    
//    lazy var fetchResultController: NSFetchedResultsController<NSFetchRequestResult> = {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
//        fetchRequest.sortDescriptors = []
//        fetchRequest.predicate = NSPredicate(format: "location == %@", self.location)
//        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
//        return fetchResultController
//    }()
    
}

