//
//  CollectionViewController.swift
//  MeMe
//
//  Created by Alan Helal on 02/02/18.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewController: UICollectionViewController {
    
    var applicationDelegate: AppDelegate!
    var memes: [Meme]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applicationDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }

    override func viewWillAppear(_ animated: Bool) {
        memes = applicationDelegate.memes
        super.viewWillAppear(true)
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let meme = memes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
//        let memeImage = self.memes[(indexPath as NSIndexPath).row]
        cell.collectionImage.image = meme.memedImage
        
        return cell
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.memes = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
 
}

