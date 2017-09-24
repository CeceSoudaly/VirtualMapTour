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
    
    var fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()

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
        static let pinSubtitle = "Address Unknown"
        static let pinCellId = "travelLocationPinId"
    }
    
    override func viewDidLoad() {
       
         super.viewDidLoad()

        mapView.delegate = self
        
        // User's location
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Done",style: .plain, target: self, action: #selector(doneLocation))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Edit",style: .plain, target: self, action: #selector(deleteLocation))
        
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PhotoAlbumViewController.longPressAction(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5 // in seconds
        //add gesture recognition
        mapView.addGestureRecognizer(longPress)
       
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let data:[Location]!
        do{
            data = try self.sharedContext.fetch(self.fetchRequest)
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
    
    
    func deleteLocation() -> Void {
        PhotoAlbumViewController.stateFlag = "delete";
    }
    
    
    func doneLocation() -> Void {
        PhotoAlbumViewController.stateFlag = "done";
    }
    
    @IBAction func longPressAction(_ recognizer: UIGestureRecognizer) {
        
        print("user had longPressAction on map",recognizer)
        
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
       
        newPin.coordinate = touchedAtCoordinate
       
        //  mapView.addAnnotation(newPin)
        //update Core Data
        self.addAnnotation(locationPoint: touchedAtCoordinate)
        
    }

    
    @IBAction func userRotateAction(_ sender: Any) {
        
         print("user userTapAction !!!",sender)
    }
    
    /**
     tap delete
    **/
    
//    @IBAction func userTapAction(_ recognizer: UIGestureRecognizer) {
//
//       print("current state of the program ", PhotoAlbumViewController.stateFlag)
//
//
//       //when tap make use its on a pin
//       if(PhotoAlbumViewController.stateFlag == "delete")
//       {
//
//        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
//        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
//
//
//        newPin.coordinate = touchedAtCoordinate
//
//        print("latituden on map",newPin.coordinate.latitude)
//        print("longitudeon map",newPin.coordinate.longitude)
//        print("Delete the location",newPin.coordinate)
//
//        delete()
//        locationToUpdate = nil
//        annotaionToUpdate = nil
//
//       } else if(PhotoAlbumViewController.stateFlag == "done")
//       {
//             print("Back to normal",newPin.coordinate.longitude)
//       }
//        
//  
//    }
//    
    func delete() {
        var error:NSError? = nil
        
        var results:[Location]!
        
        do{
            results = fetchAllLocations()
            
            print("size of the results...",results.count)
            
            for objectDelete in results {
               sharedContext.delete(objectDelete)
            }
        }
        catch{
            
            print("Error in fetchAllLocations")
            
        }
        self.application.saveContext()
    }
    
    func fetchAllLocations() -> [Location] {
        var error:NSError? = nil
        var results:[Location]!
        do{
                //Create the fetch request
                results = try self.sharedContext.fetch(self.fetchRequest)
         }
            catch{

                print("Error in fetchAllLocations")

            }
            self.application.saveContext()
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
                    self.removeMapLocation()
                }
            }
            
        })
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
        print("self.annotaionToUpdate",self.annotaionToUpdate)
        print("locationToDelete",locationToUpdate)

        self.mapView.removeAnnotation(self.annotaionToUpdate!)
        self.locations = fetchAllLocations()

        if let locationToDelete = locationToUpdate {

            //Remove location from array
            let index = (self.locations as NSArray).index(of: locationToUpdate)

            self.locations.remove(at: index)

            //Remove location from context
            sharedContext.delete(locationToUpdate!)
            self.application.saveContext()

        }
        locationToUpdate = nil
        annotaionToUpdate = nil
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
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Location", in: self.sharedContext)
        let location = Location(entity: entityDescription!, insertInto: self.sharedContext)
        location.latitude = annotation.coordinate.latitude
        location.longitude = annotation.coordinate.longitude
        
        print("Save location to core data >")
        self.application.saveContext()
      
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
            pinView!.canShowCallout = true
            pinView!.pinColor = MKPinAnnotationColor.red
           
            //Right call out button to display Flickr images
//            pinView!.rightCalloutAccessoryView =  UIButton(type: UIButtonType.detailDisclosure)
//
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
    func mapView(_ mapView: MKMapView, annotationView view: MKPinAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
   
        switch newState {
        case .starting:
            view.dragState = .dragging
            locationToUpdate = getMapLocationFromAnnotation(annotation: view.annotation!)
            annotaionToUpdate = view.annotation
        case .ending, .canceling:
            view.dragState = .none
            addAnnotation(locationPoint: (view.annotation?.coordinate)!)
        default: break
        }
    }
    

//  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!)
//  {
//
//        if control == view.rightCalloutAccessoryView {
//            // Show flickr images on right call out
//            performSegue(withIdentifier: "showAlbum", sender: view)
//
//        } else if control == view.leftCalloutAccessoryView {
//
//            // Delete annotation and location on left call out
//            locationToUpdate = getMapLocationFromAnnotation(annotation: view.annotation!)
//            annotaionToUpdate = view.annotation
//            removeMapLocation()
//        }
//    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!)
    {
        
        print("disclosure pressed on: \(String(describing: view.annotation?.title))")
        
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
         print("disclosure pressed on: \(String(describing: view.annotation?.title))")
        // first ensure that it really is an EventAnnotation:
//        if let eventAnnotation = view.annotation as? EventAnnotation {
//            let theEvent = eventAnnotation.myEvent
//            // now do somthing with your event
//        }
    }
}
