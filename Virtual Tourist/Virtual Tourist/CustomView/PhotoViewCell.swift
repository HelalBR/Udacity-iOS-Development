//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by Alan Helal on 03/09/2018.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    static let identifier = "PhotoViewCell"
    
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
