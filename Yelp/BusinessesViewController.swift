//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var businesses: [Business]!
    var names : [String] = ["asianfusion", "burgers"]
    var input = String()
    var categoryArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: names, deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        input = searchBar.text!
        print(input)
        //Create Raw Array of Tags
        categoryArray = input.characters.split{$0 == ","}.map(String.init)
        
        //Take Out first space in the Array
        for(var i = 0; i < categoryArray.count; i++){
            if categoryArray[i][0] == " "{
                categoryArray[i] = String(categoryArray[i].characters.dropFirst())
            }
        }
        
        print(categoryArray)
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
