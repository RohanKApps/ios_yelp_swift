//
//  BusinessesViewController.swift
//  WorstSpots
//
//  Edited by Rohan Katakam 1/11/16.
//  Copyright (c) 2015 Rohan Katakam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct Coordinates {
    static var currentLocation : CLLocation = CLLocation()
    static var latitude : CLLocationDegrees = CLLocationDegrees()
    static var longitude : CLLocationDegrees = CLLocationDegrees()
}

class BusinessesViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, GMSMapViewDelegate {
    

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var manager : CLLocationManager = CLLocationManager()
    
    

    var businesses: [Business]!
    var spots : [String : String] = [:]
    var input = String()
    var categoryArray : [String] = []
    var names : [String] = []
    var addresses : [String] = []
    var ratingsUrl : [String] = []
    var distances : [String] = []
    var reviewCounts : [String] = []
    var coordinates : [CLLocationCoordinate2D] = []
    
    var nameInst = String()
    var addressInst = String()
    var ratingUrlInst = String()
    var distanceInst = String()
    var reviewCountInst = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations[locations.count - 1]
        Coordinates.currentLocation = location
        Coordinates.latitude = location.coordinate.latitude
        Coordinates.longitude = location.coordinate.longitude
        
        if let location = locations.first {
            
            // 7
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // 8
            manager.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            
            
            manager.startUpdatingLocation()
            
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func getFullAddress(var address: String) -> String{
        var fullAddresses : [String] = []
        var rawJSON : String = String()
        var returnValue : String = ""
        
        //Create Request
        let inst = address
        var edit = inst.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var finalIn = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(edit)&types=geocode&language=en&key=AIzaSyCWK3r4SS4N8_n3vPvVvUmwdRikY9tABSw"
        
        print(finalIn)
        
        func parseJSON(input: String) {
            
            // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
            let postEndpoint: String = input
            let session = NSURLSession.sharedSession()
            let url = NSURL(string: postEndpoint)!
            
            // Make the POST call and handle it in a completion handler
            session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                // Make sure we get an OK response
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200 else {
                        print("Not a 200 response")
                        return
                }
                
                // Read the JSON
                do {
                    if let ipString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                        // Print what we got from the call
                        rawJSON = ipString as String
                        /*print(rawJSON)*/
                        
                        ////////////////////
                        
                        var data = rawJSON.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
                        do {
                            var json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            
                            if let dict = json as? [String: AnyObject] {
                                if let weather = dict["predictions"] as? [AnyObject] {
                                    for dict2 in weather {
                                        let description = dict2["description"] as! String
                                        fullAddresses.append(description)
                                    }
                                    returnValue = fullAddresses[0]
                                    
                                }
                            }
                            
                        }
                        catch {
                            print(error)
                        }
                    }
                } catch {
                    print("Error")
                }
                
            }).resume()
        }
        
        parseJSON(finalIn)
        while(returnValue == ""){
            if returnValue != ""{
                return returnValue
            }
        }
        return address
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! DetailViewController
        dvc.name = nameInst
        dvc.address = addressInst
        dvc.ratingsImageUrl = ratingUrlInst
        dvc.reviewCount = reviewCountInst
        dvc.distance = distanceInst
        print(ratingUrlInst)
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            print("This is \(names[indexPath.row])")
            
            nameInst = names[indexPath.row]
            addressInst = addresses[indexPath.row]
            ratingUrlInst = ratingsUrl[indexPath.row]
            distanceInst = distances[indexPath.row]
            reviewCountInst = reviewCounts[indexPath.row]
            
            performSegueWithIdentifier("detailSegue", sender: self)
        }    
    }
    
    func plotAddresses(addressArr: [String]){
        var markersArray : [GMSMarker] = []
        var placeNames = names
        var addressNames = addresses
        var iterateNames = 0
        var iterateAddresses = 0
        print(placeNames)
        for(var i = 0; i < addressArr.count; i++){
            let address = addressArr[i]
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    let  position = coordinates
                    let marker = GMSMarker(position: position)
                    marker.title = placeNames[iterateNames]
                    marker.snippet = addressNames[iterateAddresses]
                    markersArray.append(marker)
                    marker.map = self.mapView
                    if iterateNames == placeNames.count - 1 {
                        iterateNames = placeNames.count - 1
                    } else {
                        iterateNames++
                    }
                    if iterateAddresses == addressNames.count - 1 {
                        iterateAddresses = addressNames.count - 1
                    } else {
                        iterateAddresses++
                    }
                }
            })
        }
        mapView.animateToZoom(6)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        self.view.endEditing(true)
        input = searchBar.text!
        print(input)
        
        //Remove all Array Contents
        names.removeAll()
        addresses.removeAll()
        ratingsUrl.removeAll()
        distances.removeAll()
        reviewCounts.removeAll()
        
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
                
                for(var i = 0; i < self.addresses.count; i++){
                    if self.getFullAddress(self.addresses[i]) != self.addresses[i]{
                        self.addresses[i] = self.getFullAddress(self.addresses[i])
                    }
                }
                
                self.addresses = self.optomizeArray(self.addresses)
                self.ratingsUrl = self.optomizeArray(self.ratingsUrl)
                self.distances = self.optomizeArray(self.distances)
                self.reviewCounts = self.optomizeArray(self.reviewCounts)
                
                
                self.plotAddresses(self.addresses)
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

