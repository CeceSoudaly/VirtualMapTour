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


class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
   
    var pinchGesture  = UIPinchGestureRecognizer()
    let locationManager =  CLLocationManager()
    
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
        
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PhotoAlbumViewController.longPressAction(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5 // in seconds
        //add gesture recognition
         mapView.addGestureRecognizer(longPress)
    }
    
    @IBAction func longPressAction(_ recognizer: UIGestureRecognizer) {
        
        print("user had longPressAction on map",recognizer)
        
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        
        let newPin = MKPointAnnotation()
        newPin.coordinate = touchedAtCoordinate
        mapView.addAnnotation(newPin)
    }
    
    
    
    @IBAction func userPinchAction(_ sender: UIPinchGestureRecognizer) {
        
        self.view.bringSubview(toFront: mapView)
        sender.view?.transform = (sender.view?.transform)!.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1.0
        
        print("user had pinch !!!",sender)
        
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
        
        print("user userTapAction !!!",sender)
    }

}
