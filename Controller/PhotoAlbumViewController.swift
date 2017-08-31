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
    
    override func viewDidLoad() {
         super.viewDidLoad()
         let image = UIImage(named: "icon_pin")?.withRenderingMode(.alwaysOriginal)
        
         mapView.delegate = self
    }

}
