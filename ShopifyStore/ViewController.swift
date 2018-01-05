//
//  ViewController.swift
//  ShopifyStore
//
//  Created by Hazimi Asyraf on 1/4/18.
//  Copyright © 2018 Hazimi Asyraf. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var products = [Product]()
    var productTable = UITableView()
    
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
                    self.productTable.reloadData()
                }
            }
        }
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        productTable.frame = CGRect(x: 0, y: 100, width: screenWidth, height: screenHeight)
        productTable.dataSource = self
        productTable.delegate = self
        
        productTable.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        self.view.addSubview(productTable)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let product = self.products[indexPath.row]
        cell.textLabel?.text = product.title
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

