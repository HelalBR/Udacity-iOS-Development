//
//  ViewController.swift
//  Color Slider
//
//  Created by Alan Helal on 12/12/17.
//  Copyright © 2017 Alan Helal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSLider: UISlider!
    @IBOutlet weak var uiView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func selectColors(_ sender: Any) {
        let r: CGFloat = CGFloat(self.redSlider.value)
        let g: CGFloat = CGFloat(self.greenSlider.value)
        let b: CGFloat = CGFloat(self.blueSLider.value)
        
        uiView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
}

