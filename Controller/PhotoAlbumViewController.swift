//
//  File.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 8/28/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var deleteLabel: UILabel!
    //    var pinchGesture  = UIPinchGestureRecognizer()
    let locationManager =  CLLocationManager()
    
    // Geocoder to get the address of the pin
    let geocoder = CLGeocoder()
    
    // Location is updated when pin is dragged from one location to another location
    var locationToUpdate:Location?
    
    // Pin is updated when pin is dragged from one location to another
    var annotaionToUpdate: MKAnnotation?
    
    var annotationView: MKAnnotationView?
    
    var locations = [Location]()
    
    let newPin = MKPointAnnotation()
    
    //    var fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
    
    var application = (UIApplication.shared.delegate as! AppDelegate)
    
    static var stateFlag = "view"
    
    // All static varibales used to save data
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
        static let mapFileName = "mapRegionArchive"
        static let pinTitle = "Dropped Pin"
        static let pinSubtitle = "Address Unknown!"
        static let pinCellId = "travelLocationPinId"
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // User's location
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
        if(PhotoAlbumViewController.stateFlag == "Delete")
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Delete",style: .plain, target: self, action: #selector(deleteLocation))
            
        }else
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Edit",style: .plain, target: self, action: #selector(doneLocation))
        }
        
      
        restoreMapRegion(animated: false)
        addTapGesturesToMapView()
        addLongTapGesturesToMapView()
        
        // Fetch all pins from core data and show in the mapview
        self.locations = fetchAllLocations()
        updateMapViewWithAnnotations()
        deleteLabel.isHidden = true
    }
    
    func addLongTapGesturesToMapView() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPressAction:"))
        longPressGesture.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func addTapGesturesToMapView() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func updateMapViewWithAnnotations() {
        var annotations = [MKPointAnnotation]()
      
        if locations.count > 0 {
            for location in locations {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                annotation.title = location.title
                annotation.subtitle = location.subtitle
                annotations.append(annotation)
            }
        }
        mapView.addAnnotations(annotations)
    }
    
    @objc func handleTap(panGesture: UIPanGestureRecognizer) {
        print("user had tap Testing !!! ",panGesture)
        
    }
    
    @objc func deleteLocation(panGesture: UIPanGestureRecognizer) -> Void {
        PhotoAlbumViewController.stateFlag = "Edit";
        deleteLabel.isHidden = true
         navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Edit",style: .plain, target: self, action: #selector(doneLocation))
    }
    
    
    @objc func doneLocation(panGesture: UIPanGestureRecognizer) -> Void {
        PhotoAlbumViewController.stateFlag = "delete";
        deleteLabel.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Done",style: .plain, target: self, action: #selector(deleteLocation))
    }
    
    @IBAction func longPressAction(_ recognizer: UIGestureRecognizer) {
        
        if (recognizer.state == UIGestureRecognizerState.ended)
        {
            let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
            let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will
            newPin.coordinate = touchedAtCoordinate
            //update Core Data
            self.addPinToMapAndCoreData(locationPoint: touchedAtCoordinate)
        }
    }
    
    @IBAction func userRotateAction(_ sender: Any) {
        
        print("user userTapAction !!!",sender)
    }
    
    /**
     tap delete
     **/
    
    @IBAction func userTapAction(_ recognizer: UIGestureRecognizer) {
        
        print("current state of the program ", PhotoAlbumViewController.stateFlag)
        
    }
    
    func fetchAllLocations() -> [Location] {
        var error:NSError? = nil
        var results:[Location]!
        do{
            //Create the fetch request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            results = try CoreDataStackManager.getContext().fetch(fetchRequest) as! [Location]
        }
        catch{
            print("Error in fetchAllLocations")
        }
        return results
    }
    
    func getMapLocationFromAnnotation(annotation:MKAnnotation) -> Location? {
        // Fetch exact map location from annotation view
       for location in self.locations {
            for var i in 0..<self.locations.count {
                if((self.locations[i].title).contains(annotation.title as! String))
                {
                    return self.locations[i]
                    i -= 1
                }
            }
        }
        
        return self.locations.last
    }
    
    // Add pin annotation after long press gesture
    func addPinToMapAndCoreData(locationPoint:CLLocationCoordinate2D) {
        
        let newLocation: CLLocation = CLLocation(latitude: locationPoint.latitude, longitude:locationPoint.longitude)
        
        var newAnnotation:MKPointAnnotation?
        newAnnotation = MKPointAnnotation()
        newAnnotation!.coordinate = newLocation.coordinate
        newAnnotation!.title = Keys.pinTitle
        newAnnotation!.subtitle = Keys.pinSubtitle
        
        // Get the location Using reverse geocoding - this is used to show sub title of a pin
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
            placemark, error in
            
            if error == nil && !(placemark?.isEmpty)! {
                if (placemark?.count)! > 0 {
                    
                    // Update the annotation subtitle if we get the address
                    let topPlaceMark = placemark?.last as! CLPlacemark
                    var annotationSubtitle = self.creareSubtitleFromPlacemark(placemark: topPlaceMark)
                    newAnnotation!.subtitle = annotationSubtitle
                    newAnnotation!.title = annotationSubtitle
                }
            }
             // Add to mapView
            self.mapView.addAnnotation(newAnnotation!)
            //save
            self.addMapLocation(annotation: newAnnotation!)
             
        })
    }
    
    //Helper method to create address from placemark object
    func creareSubtitleFromPlacemark(placemark:CLPlacemark) -> String {
        var addressComponents = [String]()
        
        addressComponents = appendComponentIfNotNil(addressComponent: placemark.inlandWater, addressComponents: addressComponents)
        addressComponents = appendComponentIfNotNil(addressComponent: placemark.ocean, addressComponents: addressComponents)
        addressComponents = appendComponentIfNotNil(addressComponent: placemark.subThoroughfare, addressComponents: addressComponents)
        addressComponents = appendComponentIfNotNil(addressComponent: placemark.thoroughfare, addressComponents: addressComponents)
        addressComponents = appendComponentIfNotNil(addressComponent: placemark.locality, addressComponents: addressComponents)
        addressComponents = appendComponentIfNotNil(addressComponent: placemark.administrativeArea, addressComponents: addressComponents)
        addressComponents = appendComponentIfNotNil(addressComponent: placemark.postalCode, addressComponents: addressComponents)
        addressComponents = appendComponentIfNotNil(addressComponent:placemark.country, addressComponents: addressComponents)
        
        if addressComponents.isEmpty {
            return Keys.pinSubtitle
        }
        var completeAddress = addressComponents.flatMap({$0}).joined()
        return completeAddress
    }
    
    func appendComponentIfNotNil(addressComponent:String?, addressComponents :[String]) -> [String] {
        var addressComponents = addressComponents
        if let component = addressComponent {
            addressComponents.append(component)
        }
        return addressComponents
    }
    //MARK:- MapView and MapRegion
    
    // Save the mapRegion using NSKeyedArchiver
    
    var mapRegionFilePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first as! NSURL
        return url.appendingPathComponent(Keys.mapFileName)!.path
    }
    
    func saveMapRegion() {
        let mapRegionDictionary = [
            Keys.Latitude : mapView.region.center.latitude,
            Keys.Longitude : mapView.region.center.longitude,
            Keys.LatitudeDelta : mapView.region.span.latitudeDelta,
            Keys.LongitudeDelta : mapView.region.span.longitudeDelta
        ]
        NSKeyedArchiver.archiveRootObject(mapRegionDictionary, toFile: mapRegionFilePath)
    }
    
    func restoreMapRegion(animated: Bool) {
        if let mapRegionDictionary = NSKeyedUnarchiver.unarchiveObject(withFile: mapRegionFilePath) as? [String:AnyObject] {
            
            let longitude = mapRegionDictionary[Keys.Longitude] as! CLLocationDegrees
            let latitude = mapRegionDictionary[Keys.Latitude] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = mapRegionDictionary[Keys.LongitudeDelta] as! CLLocationDegrees
            let latitudeDelta = mapRegionDictionary[Keys.LatitudeDelta] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
    func removeMapLocation() -> Void {
        
        // Remove annotation
        self.mapView.removeAnnotation(self.annotaionToUpdate!)
        self.locations = fetchAllLocations()
        
        print("self.locations" ,self.locations.count)
        
        if let locationToDelete = locationToUpdate {
            //Remove location from array
            let index: Int = (self.locations as NSArray).index(of: locationToUpdate)
            self.locations.remove(at: index)
            //Remove location from context
            deletePin(locationToDelete: locationToUpdate!)
        }
        
        CoreDataStackManager.saveContext()
        print("Share context save what do you have???",self.fetchAllLocations().count)
    
        locationToUpdate = nil
        annotaionToUpdate = nil
        
    }
    
    func deletePin(locationToDelete :Location) {
        var _:NSError? = nil
        
        var results:[Location]!
        results = self.fetchAllLocations();
       
        for objectDelete in results {
        if(objectDelete.longitude == locationToDelete.longitude)
            {
              CoreDataStackManager.getContext().delete(objectDelete)
              CoreDataStackManager.saveContext()
              break
            }
        }
        
    }
    
    func addMapLocation(annotation:MKAnnotation) {
        
        do{
            
            let locationDictionary: [String : AnyObject] = [
                Location.Keys.Latitude : annotation.coordinate.latitude as AnyObject,
                Location.Keys.Longitude : annotation.coordinate.longitude as AnyObject,
                Location.Keys.Title: annotation.title! as AnyObject,
                Location.Keys.Subtitle: annotation.subtitle! as AnyObject
            ]
    
            let locationToBeAdded = Location(dictionary: locationDictionary, context: CoreDataStackManager.getContext())
            self.locations.append(locationToBeAdded)
            
           // try self.sharedContext.save()
             CoreDataStackManager.saveContext()
            
            //Pre-Fetch photos entites related to this location and save to core data
            FlickrClient.sharedInstance().prefetchPhotosForLocationAndSaveToDataContext(location: locationToBeAdded) {
                error in
                if let errorMessage = error {
                    print(errorMessage.localizedDescription)
                }
            }
           
        }
        catch{
            print("Error while trying save pin Annotation.")
        }
        
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PicGallery"{
            if let annotaionView = sender as? MKAnnotationView {
                let controller = segue.destination as! PicGalleryViewController
                 controller.location =  self.locationToUpdate
            }
        }
    }
  
}

extension PhotoAlbumViewController {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated: \(String(describing: mapView.description))")
        saveMapRegion()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) ->  MKAnnotationView?{
        let reusableMapId = Keys.pinCellId
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableMapId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation as! MKAnnotation, reuseIdentifier: reusableMapId)
            pinView!.isDraggable = true
            pinView!.animatesDrop = true
            //pinView!.canShowCallout = true
            pinView!.pinColor = MKPinAnnotationColor.red
            
            //Right call out button to display Flickr images
            pinView!.rightCalloutAccessoryView =  UIButton(type: UIButtonType.detailDisclosure)
            
            //  Left call out button as delete location button
            let deleteLocationButton = UIButton(type: UIButtonType.system)
            deleteLocationButton.frame = CGRect(x:0, y:0, width:200, height:300)
            //            deleteLocationButton.setImage(UIImage(named: "deleteLocation"), for: UIControlState.normal)
            //            deleteLocationButton.backgroundColor = UIColor.cyan
            //            pinView?.leftCalloutAccessoryView = deleteLocationButton
            pinView!.rightCalloutAccessoryView =  deleteLocationButton
            pinView?.isEnabled = true
            annotaionToUpdate = pinView?.annotation
            
        } else {
            pinView!.annotation = annotation as! MKAnnotation
            
        }
        return pinView
    }
    
    // Update location when pin is dragged
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        switch newState {
        case .starting:
            view.dragState = .dragging
            locationToUpdate = getMapLocationFromAnnotation(annotation: view.annotation!)
            annotaionToUpdate = view.annotation
        case .ending, .canceling:
            view.dragState = .none
            addPinToMapAndCoreData(locationPoint: (view.annotation?.coordinate)!)
        default: break
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("Swift 4 disclosure pressed on: \(String(describing: view.annotation?.title))")
        //Set the current locatin of the pin
        locationToUpdate = nil
        annotaionToUpdate = nil
        self.locationToUpdate = getMapLocationFromAnnotation(annotation: view.annotation!)
        annotaionToUpdate = view.annotation
      
        if(PhotoAlbumViewController.stateFlag != "delete" ) {
            // Show flickr images on right call out
            performSegue(withIdentifier: "PicGallery", sender: view)
            
        } else if(PhotoAlbumViewController.stateFlag == "delete"){
            // Delete annotation and location on left call out
             annotaionToUpdate = view.annotation
             removeMapLocation()
        }
        
    }
}

