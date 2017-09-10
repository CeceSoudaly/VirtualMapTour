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
    
    var locations = [Location]()
    
    let newPin = MKPointAnnotation()
    
    let dbPersistence = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
    var application = (UIApplication.shared.delegate as! AppDelegate)
    
    // All static varibales used to save data
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
        static let mapFileName = "mapRegionArchive"
        static let pinTitle = "Dropped Pin"
        static let pinSubtitle = "Address Unknown"
        static let pinCellId = "travelLocationPinId"
    }
    
    override func viewDidLoad() {
       
         super.viewDidLoad()

        
        // User's location
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Edit",style: .plain, target: self, action: #selector(deleteLocation))
        
        
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PhotoAlbumViewController.longPressAction(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5 // in seconds
        //add gesture recognition
         mapView.addGestureRecognizer(longPress)
        
        //load the save pin location
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        let data:[Location]!
        do{
            data = try self.dbPersistence.fetch(self.fetchRequest)
        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        
        if data.count > 0
        {
            for items in data
            {
                let lat = items.latitude
                let long = items.longitude
                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                mapView.removeAnnotation(annotation)
                mapView.addAnnotation(annotation)
            }
        }
        
        mapView.reloadInputViews()
    }
    
    func deleteLocation(){
        //
          print("deleteLocation action...")
    }
    
    
    @IBAction func longPressAction(_ recognizer: UIGestureRecognizer) {
        
        print("user had longPressAction on map",recognizer)
        
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        
        
        newPin.coordinate = touchedAtCoordinate

        print("latituden on map",newPin.coordinate.latitude)
        print("longitudeon map",newPin.coordinate.longitude)
        
        
        
//        mapView.addAnnotation(newPin)
        self.addAnnotation(locationPoint: touchedAtCoordinate)
        
    }
    
    func getMapLocationFromAnnotation(annotation:MKAnnotation) -> Location? {
        
        // Fetch exact map location from annotation view
//        let filteredLocations =   self.locations.filter {
//                $0.title = (annotation.title != nil);
//            $0.subtitle = (annotation.subtitle != nil) ;
//            $0.latitude == annotation.coordinate.latitude ;
//                $0.longitude == annotation.coordinate.longitude
//        }
//        if filteredLocations.count > 0 {
//            return filteredLocations.last!
//        }
        return nil
    }
    

    
    @IBAction func userDragAction(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
        
           print("user Drag !!!",sender)
        
    }
    
    @IBAction func userRotateAction(_ sender: Any) {
        
         print("user userTapAction !!!",sender)
    }
    
    @IBAction func userTapAction(_ sender: Any) {
        
        print("TapAction get the coordinates of the location!!!",sender)
        print("latituden on map",newPin.coordinate.latitude)
        print("longitudeon map",newPin.coordinate.longitude)
        
        //when tap make use its on a pin
      
    }
    
    
    // Add pin annotation after long press gesture
    func addAnnotation(locationPoint:CLLocationCoordinate2D) {
        
        let newLocation: CLLocation = CLLocation(latitude: locationPoint.latitude, longitude:locationPoint.longitude)
        
        var newAnnotation:MKPointAnnotation?
        newAnnotation = MKPointAnnotation()
        newAnnotation!.coordinate = locationPoint
        newAnnotation!.title = Keys.pinTitle
        newAnnotation!.subtitle = Keys.pinSubtitle
        
        // Get the location Using reverse geocoding - this is used to show sub title of a pin
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
            placemark, error in
            
            if error == nil && !(placemark?.isEmpty)! {
                if (placemark?.count)! > 0 {
                    
                    // Update the annotation subtitle if we get the address
                    let topPlaceMark = placemark?.last as! CLPlacemark
//                    var annotationSubtitle = self.creareSubtitleFromPlacemark(topPlaceMark)
//                    newAnnotation!.subtitle = annotationSubtitle
                }
            }
            
            // Add to mapView
            self.mapView.addAnnotation(newAnnotation!)
            
            DispatchQueue.main.async() {
                
                // Add this annotation point to core data as Location object
                self.addMapLocation(annotation: newAnnotation!)
                if self.locationToUpdate != nil  {
                    //self.removeMapLocation()
                }
            }
            
        })
    }
    
    func addMapLocation(annotation:MKAnnotation) {
        
        Location.Keys.Latitude
        
        let locationDictionary: [String : AnyObject] = [
            Location.Keys.Latitude : annotation.coordinate.latitude as AnyObject,
            Location.Keys.Longitude : annotation.coordinate.longitude as AnyObject,
            Location.Keys.Title: annotation.title! as AnyObject,
            Location.Keys.Subtitle: annotation.subtitle! as AnyObject
        ]
        
        
        let locationToBeAdded = Location(dictionary: locationDictionary, context: sharedContext)
        self.locations.append(locationToBeAdded)
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Location", in: self.dbPersistence)
        let location = Location(entity: entityDescription!, insertInto: self.dbPersistence)
        location.latitude = annotation.coordinate.latitude
        location.longitude = annotation.coordinate.longitude
        
        print("Save location to core data >")
        self.application.saveContext()
        
        
//        Pre-Fetch photos entites related to this location and save to core data
        
//        FlickrClient.sharedInstance().prefetchPhotosForLocationAndSaveToDataContext(location: locationToBeAdded) {
//            error in
//            if let errorMessage = error {
//                print(errorMessage.localizedDescription)
//            }
//        }
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reusableMapId = Keys.pinCellId
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableMapId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusableMapId)
            pinView!.isDraggable = true
            pinView!.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinColor = MKPinAnnotationColor.purple
            
            //Right call out button to display Flickr images
//            pinView!.rightCalloutAccessoryView =  UIButton.buttonWithType(UIButtonType.detailDisclosure) as! UIButton
            
            //  Left call out button as delte pin button
//            let deleteLocationButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
//            deleteLocationButton.frame = CGRectMake(0, 0, 20, 20)
//            deleteLocationButton.setImage(UIImage(named: "deleteLocation"), forState: UIControlState.Normal)
//            pinView?.leftCalloutAccessoryView = deleteLocationButton
            
            
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //MARK:- Core Data Operations
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().context
    }

}
