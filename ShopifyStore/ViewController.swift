//
//  ViewController.swift
//  ShopifyStore
//
//  Created by Hazimi Asyraf on 1/4/18.
//  Copyright © 2018 Hazimi Asyraf. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    var collections = [Collection]()
    
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var collectionCollectionView: UICollectionView!
    
    var selectedProduct = Int()
    var selectedCollection = Int()
    
    @IBAction func searchAction(_ sender: Any) {
        let searchTerm = searchTextfield.text
        if searchTerm != "" {
            search(term: searchTerm!)
        }
        else {
            getAllItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let itemSize = screenSize.width/2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize+35)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionCollectionView.collectionViewLayout = layout
        searchTextfield.delegate = self
        
        getAllItems()
    }
    
    func getAllItems() {
        let jsonUrl = "https://shopicruit.myshopify.com/admin/custom_collections.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        self.collections.removeAll()
        
        Alamofire.request(jsonUrl).responseJSON { (response) in
            if let JSON = response.result.value {
                let jsonResponse = JSON as! [String: AnyObject]
                let jsonObjects = jsonResponse["custom_collections"] as! [[String: AnyObject]]
                for jsonObject in jsonObjects {
                    let collection = Collection()
                    collection.id = jsonObject["id"] as! Int
                    collection.title = jsonObject["title"] as! String
                    collection.desc = jsonObject["body_html"] as! String
                    collection.imageUrl = jsonObject["image"]!["src"] as! String
                    self.collections.append(collection)
                }
                DispatchQueue.main.async {
                    self.collectionCollectionView.reloadData()
                }
            }
        }
    }
    
    func search(term: String){
        var searchJsonUrl = "https://shopicruit.myshopify.com/admin/custom_collections.json?title=" + term + "&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        collections.removeAll()
        
        Alamofire.request(searchJsonUrl).responseJSON { (response) in
            if let JSON = response.result.value {
                let jsonResponse = JSON as! [String: AnyObject]
                let jsonObjects = jsonResponse["custom_collections"] as! [[String: AnyObject]]
                for jsonObject in jsonObjects {
                    let collection = Collection()
                    collection.id = jsonObject["id"] as! Int
                    collection.title = jsonObject["title"] as! String
                    collection.desc = jsonObject["body_html"] as! String
                    collection.imageUrl = jsonObject["image"]!["src"] as! String
                    self.collections.append(collection)
                }
                DispatchQueue.main.async {
                    self.collectionCollectionView.reloadData()
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionCell
        let collection = collections[indexPath.row]
        cell.titleLabel.text = collection.title
        let imageUrl = URL(string: collection.imageUrl)
        cell.collectionImageView.af_setImage(withURL: imageUrl!)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCollection = indexPath.row
        self.performSegue(withIdentifier: "viewCollection", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let searchTerm = self.searchTextfield.text
        if searchTerm != "" {
            search(term: searchTerm!)
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = "All Collections"
        navigationItem.backBarButtonItem = backButton
        var nextViewController : CollectionViewController = segue.destination as! CollectionViewController
        nextViewController.collectionId = collections[selectedCollection].id
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
