//
//  DetailViewController.swift
//  WorstSpots
//
//  Edited by Rohan Katakam 1/11/16.
//  Copyright (c) 2015 Rohan Katakam. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    //Data from Restaurant
    var name : String = String()
    var address : String = String()
    var distance : String = String()
    var ratingsImageUrl : String = String()
    var reviewCount : String = String()
    var data : NSData?
    
    //Outlets
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var addressOutlet: UILabel!
    @IBOutlet weak var distanceOutlet: UILabel!
    @IBOutlet weak var ratingImageOutlet: UIImageView!
    @IBOutlet weak var reviewCountOutlet: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = name
        nameOutlet.text = name
        addressOutlet.text = address
        distanceOutlet.text = "Approximately: \(distance) away"
        print(ratingsImageUrl)
        let url = NSURL(string:ratingsImageUrl)
        data = NSData(contentsOfURL:url!)
        if data != nil {
            ratingImageOutlet.image = UIImage(data:data!)
        }
        
        reviewCountOutlet.text = "From \(reviewCount) Reviews"
    }
    
    override func viewDidLayoutSubviews() {
        if data != nil {
            ratingImageOutlet.image = UIImage(data:data!)
        }
    }
}
