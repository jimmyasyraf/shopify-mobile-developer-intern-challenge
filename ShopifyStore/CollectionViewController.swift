//
//  CollectionViewController.swift
//  ShopifyStore
//
//  Created by Hazimi Asyraf on 12/1/19.
//  Copyright © 2019 Hazimi Asyraf. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionId = Int()
    var productIds = [String]()
    var products = [Product]()
    var selectedProduct = Int()
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let itemSize = screenSize.width/2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize+35)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        productCollectionView.collectionViewLayout = layout
        
        getAllItems()
    }
    
    func getAllItems() {
        var collectionUrl = "https://shopicruit.myshopify.com/admin/collects.json?collection_id=" + String(collectionId) + "&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        Alamofire.request(collectionUrl).responseJSON { (response) in
            if let collectsJson = response.result.value {
                let collectsResponse = collectsJson as! [String: AnyObject]
                let collects = collectsResponse["collects"] as! [[String: AnyObject]]
                for collect in collects {
                    let productId = collect["product_id"] as! Int
                    self.productIds.append(String(productId))
                }
                print(self.productIds)
                let prouductIdsString = self.productIds.joined(separator: ",")
                print(prouductIdsString)
                let productsUrl = "https://shopicruit.myshopify.com/admin/products.json?ids=" + prouductIdsString + "&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
                print(productsUrl)
                
                Alamofire.request(productsUrl).responseJSON { (response) in
                    if let productsJson = response.result.value {
                        let productsResponse = productsJson as! [String: AnyObject]
                        let jsonObjects = productsResponse["products"] as! [[String: AnyObject]]
                        for jsonObject in jsonObjects {
                            let product = Product()
                            product.id = jsonObject["id"] as! Int
                            product.title = jsonObject["title"] as! String
                            product.desc = jsonObject["body_html"] as! String
                            product.imageUrl = jsonObject["image"]!["src"] as! String
                            let productVariants = jsonObject["variants"] as! [[String: AnyObject]]
                            var totalInventory = 0
                            for variant in productVariants {
                                let inventoryQuantity = variant["inventory_quantity"] as! Int
                                totalInventory += inventoryQuantity
                            }
                            product.totalInventory = totalInventory
                            self.products.append(product)
                        }
                        DispatchQueue.main.async {
                            self.productCollectionView.reloadData()
                        }
                    }
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
        cell.inventoryLabel.text = "Available: " + String(product.totalInventory)
        let imageUrl = URL(string: product.imageUrl)
        cell.productImageView.af_setImage(withURL: imageUrl!)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProduct = indexPath.row
        self.performSegue(withIdentifier: "viewProduct", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = "Collection"
        navigationItem.backBarButtonItem = backButton
        var nextViewController : ProductViewController = segue.destination as! ProductViewController
        nextViewController.productId = products[selectedProduct].id
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
