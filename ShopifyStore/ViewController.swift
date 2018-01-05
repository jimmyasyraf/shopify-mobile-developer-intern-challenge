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
    var products = [Product]()
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var searchTextfield: UITextField!
    
    var selectedProduct = Int()
    
    @IBAction func searchAction(_ sender: Any) {
        let searchTerm = searchTextfield.text
        if searchTerm != "" {
            search(term: searchTerm!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let jsonUrl = "https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"

        Alamofire.request(jsonUrl).responseJSON { (response) in
            if let JSON = response.result.value {
                let jsonResponse = JSON as! [String: AnyObject]
                let jsonObjects = jsonResponse["products"] as! [[String: AnyObject]]
                for jsonObject in jsonObjects {
                    let product = Product()
                    product.id = jsonObject["id"] as! Int
                    product.title = jsonObject["title"] as! String
                    product.desc = jsonObject["body_html"] as! String
                    product.imageUrl = jsonObject["image"]!["src"] as! String
                    self.products.append(product)
                }
                DispatchQueue.main.async {
                    self.productCollectionView.reloadData()
                }
            }
        }
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let itemSize = screenSize.width/2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize+35)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        productCollectionView.collectionViewLayout = layout
        searchTextfield.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let searchTerm = self.searchTextfield.text
        if searchTerm != "" {
            search(term: searchTerm!)
        }
        return true
    }
    
    func search(term: String){
        var searchJsonUrl = "https://shopicruit.myshopify.com/admin/products.json?title=" + term + "&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        products.removeAll()
        
        Alamofire.request(searchJsonUrl).responseJSON { (response) in
            if let JSON = response.result.value {
                let jsonResponse = JSON as! [String: AnyObject]
                let jsonObjects = jsonResponse["products"] as! [[String: AnyObject]]
                for jsonObject in jsonObjects {
                    let product = Product()
                    product.id = jsonObject["id"] as! Int
                    product.title = jsonObject["title"] as! String
                    product.desc = jsonObject["body_html"] as! String
                    product.imageUrl = jsonObject["image"]!["src"] as! String
                    self.products.append(product)
                }
                DispatchQueue.main.async {
                    self.productCollectionView.reloadData()
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCell
        let product = products[indexPath.row]
        cell.titleLabel.text = product.title
        cell.descriptionLabel.text = product.desc
        let imageUrl = URL(string: product.imageUrl)
        cell.productImageView.af_setImage(withURL: imageUrl!)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProduct = indexPath.row
        self.performSegue(withIdentifier: "viewProduct", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = "All Products"
        navigationItem.backBarButtonItem = backButton
        var nextViewController : ProductViewController = segue.destination as! ProductViewController
        nextViewController.productId = products[selectedProduct].id
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
