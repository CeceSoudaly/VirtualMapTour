//
//  PhotoCollectionView.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 10/18/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit

class PhotoCollectionView: UICollectionViewCell {

    @IBOutlet weak var photoImage: UIImageView!

    @IBOutlet weak var deleteButton: UIButton!

    @IBOutlet weak var photoDownloadActivityIndicator: UIActivityIndicatorView!
    
    // Cancel download task when collection view cell is reused
//    var taskToCancelifCellIsReused: URLSessionTask{
//        
//        didSet {
//            if let taskToCancel = oldValue {
//                taskToCancel.cancel()
//            }
//        }
//    }
    
}
