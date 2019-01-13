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

class CollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var collectionTitle = String()
    var collectionDescription = String()
    var collectionImageUrl = String()
    var collectionId = Int()
    var productIds = [String]()
    var products = [Product]()
    var selectedProduct = Int()
    
    @IBOutlet weak var collectionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
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

                let prouductIdsString = self.productIds.joined(separator: ",")
                let productsUrl = "https://shopicruit.myshopify.com/admin/products.json?ids=" + prouductIdsString + "&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
                
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
                            self.collectionTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
            cell.titleLabel.text = collectionTitle
            cell.descriptionLabel.text = collectionDescription
            let imageUrl = URL(string: collectionImageUrl)
            cell.collectionImageView.af_setImage(withURL: imageUrl!)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
            let product = products[indexPath.row - 1]
            cell.titleLabel.text = product.title
            cell.descriptionLabel.text = product.desc
            cell.inventoryLabel.text = "Available: " + String(product.totalInventory)
            let imageUrl = URL(string: product.imageUrl)
            cell.productImageView.af_setImage(withURL: imageUrl!)
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            selectedProduct = indexPath.row - 1
            self.performSegue(withIdentifier: "viewProduct", sender: self)
        }
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
    }
}
