//
//  Meme.swift
//  MeMe
//
//  Created by Alan Helal on 24/01/18.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText : String?
    var bottomText : String?
    var originalImage : UIImage?
    var memedImage : UIImage?
    
    init() {
    }
    
    init(topText: String?, bottomText: String?, originalImage: UIImage?, memedImage: UIImage?) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
