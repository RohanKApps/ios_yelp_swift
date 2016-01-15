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
    var ratings : [Double] = []
    var distances : [String] = []
    
    
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
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        input = searchBar.text!
        print(input)
        
        //Remove all Array Contents
        names.removeAll()
        addresses.removeAll()
        ratings.removeAll()
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
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: categoryArray, deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
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
                    if ((business.ratingImageURL?.path?.rangeOfString("stars_large_1.png")) != nil){
                        self.ratings.append(1.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_1_half.png")) != nil){
                        self.ratings.append(1.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_2.png")) != nil){
                        self.ratings.append(2.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_2_half.png")) != nil){
                        self.ratings.append(2.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_3.png")) != nil){
                        self.ratings.append(3.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_3_half.png")) != nil){
                        self.ratings.append(3.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_4.png")) != nil){
                        self.ratings.append(4.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_4_half.png")) != nil){
                        self.ratings.append(4.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_5.png")) != nil){
                        self.ratings.append(5.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_5_half.png")) != nil){
                        self.ratings.append(5.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_6.png")) != nil){
                        self.ratings.append(6.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_6_half.png")) != nil){
                        self.ratings.append(6.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_7.png")) != nil){
                        self.ratings.append(7.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_7_half.png")) != nil){
                        self.ratings.append(7.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_8.png")) != nil){
                        self.ratings.append(8.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_8_half.png")) != nil){
                        self.ratings.append(8.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_9.png")) != nil){
                        self.ratings.append(9.0)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_9_half.png")) != nil){
                        self.ratings.append(9.5)
                    } else if ((business.ratingImageURL?.path?.rangeOfString("stars_large_10.png")) != nil){
                        self.ratings.append(10.0)
                    }
                    
                    self.tableView.reloadData()
                    
                    print(business.name!)
                    print(business.address!)
                    print(business.ratingImageURL!)
                    print(business.distance!)
                    
                }
            } else {
                let alertController = UIAlertController(title: "Alert", message:
                    "No restuarants were found under the query: \(self.input)", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
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
