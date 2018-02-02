//
//  MemeDetailViewController.swift
//  MeMe
//
//  Created by Alan Helal on 01/02/18.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    @IBOutlet weak var memeDetailedView: UIImageView!
    var memes: Meme!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
        //self.memeDetailedView!.image = UIImage(named: memes.memedImage)
        self.memeDetailedView.image = memes.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}
