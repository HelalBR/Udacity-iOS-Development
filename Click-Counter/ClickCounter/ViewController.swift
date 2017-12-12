//
//  ViewController.swift
//  ClickCounter
//
//  Created by Alan Helal on 11/12/17.
//  Copyright © 2017 Alan Helal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var count:Int = 0
    @IBOutlet var label:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        }
    
    @IBAction func incrementCount() {
        self.count = self.count + 1
        self.label.text = "\(self.count)"
    
    }
    
   


}

