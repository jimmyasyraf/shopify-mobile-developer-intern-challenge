//
//  ProductViewController.swift
//  ShopifyStore
//
//  Created by Hazimi Asyraf on 1/4/18.
//  Copyright © 2018 Hazimi Asyraf. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProductViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var productId = Int()
    var product = Product()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        var jsonUrl = "https://shopicruit.myshopify.com/admin/products/" + String(productId) + ".json?access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        
        Alamofire.request(jsonUrl).responseJSON { (response) in
            if let JSON = response.result.value {
                let jsonResponse = JSON as! [String: AnyObject]
                let jsonObject = jsonResponse["product"] as! [String: AnyObject]
                self.product.title = jsonObject["title"] as! String
                self.product.desc = jsonObject["body_html"] as! String
                self.product.imageUrl = jsonObject["image"]!["src"] as! String
                self.product.vendor = jsonObject["vendor"] as! String
                self.product.type = jsonObject["product_type"] as! String
                let variants = jsonObject["variants"] as! [[String: AnyObject]]
                self.product.price = (variants[0]["price"] as! NSString).floatValue
                
                DispatchQueue.main.async {
                    self.titleLabel.text = self.product.title
                    self.descriptionLabel.text = self.product.desc
                    self.typeLabel.text = self.product.type
                    self.vendorLabel.text = self.product.vendor
                    self.priceLabel.text = "$ \(self.product.price)"
                    let imageUrl = URL(string: self.product.imageUrl)
                    self.productImageView.af_setImage(withURL: imageUrl!)
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
