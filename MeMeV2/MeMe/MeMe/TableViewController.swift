//
//  TableViewController.swift
//  MeMe
//
//  Created by Alan Helal on 31/01/18.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableViewMemes: UITableView!
    var applicationDelegate: AppDelegate!
    var memes: [Meme]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applicationDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        memes = applicationDelegate.memes
        super.viewWillAppear(true)
        tableViewMemes.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meme = memes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell", for: indexPath)
        
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = meme.topText
        cell.detailTextLabel?.text = meme.bottomText
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.memes = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }

}
