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


class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
   
    var pinchGesture  = UIPinchGestureRecognizer()
    
    override func viewDidLoad() {
       
         super.viewDidLoad()
         let image = UIImage(named: "icon_pin")?.withRenderingMode(.alwaysOriginal)
        
         mapView.delegate = self
    }
    
    @IBAction func longPressAction(_ sender: Any) {
        
        print("user had longPressAction on map",sender)
        
        let coordinate = mapView.centerCoordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
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
