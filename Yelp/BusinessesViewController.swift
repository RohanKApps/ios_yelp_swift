//
//  BusinessesViewController.swift
//  Yelp
//
//  Edited by Rohan Lee Katakam 1/11/16.
//  Copyright (c) 2015 Rohan Katakam. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var businesses: [Business]!
    var spots : [String : String] = [:]
    var input = String()
    var categoryArray : [String] = []
    var names : [String] = []
    var addresses : [String] = []
    var ratingsUrl : [String] = []
    var distances : [String] = []
    var reviewCounts : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsScopeBar = true
        searchBar.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        cell.textLabel?.text = "\(names[indexPath.row]) (\(distances[indexPath.row]))"
        
        if let url = NSURL(string: ratingsUrl[indexPath.row]) {
            if let data = NSData(contentsOfURL: url) {
                cell.imageView!.image = UIImage(data: data)
            }        
        }
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        input = searchBar.text!
        print(input)
        
        //Remove all Array Contents
        names.removeAll()
        addresses.removeAll()
        ratingsUrl.removeAll()
        distances.removeAll()
        
        //Create Raw Array of Tags
        categoryArray = input.characters.split{$0 == ","}.map(String.init)
        
        //Take Out first space in the Array
        for(var i = 0; i < categoryArray.count; i++){
            categoryArray[i] = categoryArray[i].lowercaseString
            if categoryArray[i][0] == " "{
                categoryArray[i] = String(categoryArray[i].characters.dropFirst())
            }
        }
        
        print(categoryArray)
        
        //Implement Yelp API to find restaurants
        Business.searchWithTerm("Restaurants", sort: .HighestRated, categories: categoryArray, deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            if businesses != nil{
                for business in businesses {
                    //Add Name of Restaurant to Array
                    self.names.append(business.name!)
                    
                    //Add Restaurant Address to Array
                self.addresses.append(business.address!)
                    
                    //Add Restaurant Distance to Array
                    self.distances.append(business.distance!)
                    
                //Add Rating of Restaurant to Ratings Array
                    self.ratingsUrl.append("\(business.ratingImageURL!)")
                    
                    //Add Review Count of Restaurant to Review Count Array
                    self.reviewCounts.append("\(business.reviewCount!)")
                    
                    self.tableView.reloadData()
                    
                    print(business.name!)
                    print(business.address!)
                    print(business.ratingImageURL!)
                    print(business.distance!)
                    print(business.reviewCount!)
                    
                }
                //Optomize Arrays to show the five worst
                self.names = self.optomizeArray(self.names)
                self.addresses = self.optomizeArray(self.addresses)
                self.ratingsUrl = self.optomizeArray(self.ratingsUrl)
                self.distances = self.optomizeArray(self.distances)
                self.reviewCounts = self.optomizeArray(self.reviewCounts)
                
                self.tableView.reloadData()
                
            } else {
                let alertController = UIAlertController(title: "Alert", message:
                    "No restuarants were found under the query: \(self.input)", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func optomizeArray(var arr: [String]) -> [String]{
        if arr.count <= 5 {
            arr = arr.reverse()
            return arr
        } else {
            arr = [arr[arr.count - 1], arr[arr.count - 2], arr[arr.count - 3], arr[arr.count - 4], arr[arr.count - 5]]
            return arr
        }
    }
}

//String Extension for getting char at nth location of String
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start: start, end: end)]
    }
}

