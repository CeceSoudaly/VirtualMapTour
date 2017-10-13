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
    
    static var stateFlag = "none"
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Done",style: .plain, target: self, action: #selector(doneLocation))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Edit",style: .plain, target: self, action: #selector(deleteLocation))
        
        
        addTapGesturesToMapView()
        addLongTapGesturesToMapView()
        
        // Fetch all pins from core data and show in the mapview
        print("Onload ... how many?", self.locations.count )
        self.locations = fetchAllLocations()
        
        print("AFTER fetchAllLocations ... how many?", self.locations.count )
        updateMapViewWithAnnotations()
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
    
    func handleTap(panGesture: UIPanGestureRecognizer) {
        print("user had tap  !!! ",panGesture)
    }
    
    func deleteLocation() -> Void {
        PhotoAlbumViewController.stateFlag = "delete";
    }
    
    
    func doneLocation() -> Void {
        PhotoAlbumViewController.stateFlag = "done";
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
            results = try self.sharedContext.fetch(fetchRequest) as! [Location]
        }
        catch{
            print("Error in fetchAllLocations")
        }
        return results
    }
    
    func getMapLocationFromAnnotation(annotation:MKAnnotation) -> Location? {
        
        // Fetch exact map location from annotation view
        let locationDictionary: [String : AnyObject] = [
            Location.Keys.Latitude : annotation.coordinate.latitude as AnyObject,
            Location.Keys.Longitude : annotation.coordinate.longitude as AnyObject,
            Location.Keys.Title: annotation.title! as AnyObject,
            Location.Keys.Subtitle: annotation.subtitle! as AnyObject
        ]
        
        return Location(dictionary: locationDictionary, context: self.sharedContext)
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
            
            DispatchQueue.main.async() {
                
                // Add this annotation point to core data as Location object
                self.addMapLocation(annotation: newAnnotation!)
                if self.locationToUpdate != nil  {
                    self.removeMapLocation()
                }
            }
            
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
    
    func removeMapLocation() -> Void {
        
        // Remove annotation
        self.mapView.removeAnnotation(self.annotaionToUpdate!)
        self.locations = fetchAllLocations()
        
        print("self.locations" ,self.locations.count)
        
        if let locationToDelete = locationToUpdate {
            //Remove location from array
            let index: Int = (self.locations as NSArray).index(of: locationToUpdate)
            print(" b4 DELETE self.locations" ,self.locations.count  , index)
            self.locations.remove(at: index)
            
            //Remove location from context
            deletePin(locationToDelete: locationToDelete)
            
            print(" after DELETE self.locations" ,self.locations.count)
            
        }
        
        do {
            try self.sharedContext.save()
            
            print("Share context save what do you have???",self.fetchAllLocations().count)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        locationToUpdate = nil
        annotaionToUpdate = nil
        
    }
    
    func deletePin(locationToDelete :Location) {
        var _:NSError? = nil
        
        var results:[Location]!
        results = self.fetchAllLocations();
        
        print("How many do you have?..",results.count)
        
        for objectDelete in results {
            
            print("objectDelete.longitude .",objectDelete.longitude)
            print("locationToDelete.longitude.",locationToDelete.longitude)
            
            if(objectDelete.longitude == locationToDelete.longitude)
            {
                print("b4 delete...",self.fetchAllLocations().count)
                self.sharedContext.delete(objectDelete)
                print("b4 save...",self.fetchAllLocations().count)
                //Try to save it to coredata
                
                break
            }
        }
        
    }
    
    func addMapLocation(annotation:MKAnnotation) {
        
        do{
            
            //        let locationDictionary: [String : AnyObject] = [
            //            Location.Keys.Latitude : annotation.coordinate.latitude as AnyObject,
            //            Location.Keys.Longitude : annotation.coordinate.longitude as AnyObject,
            //            Location.Keys.Title: annotation.title! as AnyObject,
            //            Location.Keys.Subtitle: annotation.subtitle! as AnyObject
            //        ]
            //
            //        let locationToBeAdded = Location(dictionary: locationDictionary, context: sharedContext)
            //
            //        self.locations.append(locationToBeAdded)
            print(" Appending self.locations >>> ", self.locations.count)
            
            
            //        print("Save location to core data >")
            
            
            //save
            print(" b4 safe ",self.fetchAllLocations().count)
            let entityDescription = NSEntityDescription.entity(forEntityName: "Location", in: self.sharedContext)
            let location = Location(entity: entityDescription!, insertInto: self.sharedContext)
            //            print("Just created a notebook: \(nb)")
            try self.sharedContext.save()
            
            
            print("after save addMapLocation ",self.fetchAllLocations().count)
            
        }
        catch{
            print("Error while trying save pin Annotation.")
        }
        
    }
    
    //MARK:- Core Data Operations
    var sharedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

extension PhotoAlbumViewController {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
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
            
            //  Left call out button as delete pin button
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
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!)
    {
        
        print("1 disclosure pressed on: \(String(describing: view.annotation?.title))")
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("Swift 3 disclosure pressed on: \(String(describing: view.annotation?.title))")
        
        if(PhotoAlbumViewController.stateFlag == "done") {
            // Show flickr images on right call out
            //performSegueWithIdentifier("showAlbum", sender: view)
            
        } else if(PhotoAlbumViewController.stateFlag == "delete"){
            
            // Delete annotation and location on left call out
            locationToUpdate = getMapLocationFromAnnotation(annotation: view.annotation!)
            annotaionToUpdate = view.annotation
            removeMapLocation()
        }
        
        
        
    }
}

