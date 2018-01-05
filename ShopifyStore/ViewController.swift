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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var products = [Product]()
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let json_url = "https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        let url = URL(string: json_url)
        
        Alamofire.request("https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6").responseJSON { (response) in
            print("Result: \(response.result)")
            if let JSON = response.result.value {
                let jsonResponse = JSON as! [String: AnyObject]
                let jsonObjects = jsonResponse["products"] as! [[String: AnyObject]]
                for jsonObject in jsonObjects {
                    //print(jsonObject["title"] as! String)
                    //print(jsonObject["image"]!["src"] as! String)
                    let product = Product()
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
        layout.itemSize = CGSize(width: itemSize, height: itemSize+40)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        productCollectionView.collectionViewLayout = layout
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCell
        let product = products[indexPath.row]
        //print(product.title)
        cell.titleLabel.text = product.title
        cell.descriptionLabel.text = product.desc
        let imageUrl = URL(string: product.imageUrl)
        cell.productImageView.af_setImage(withURL: imageUrl!)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
