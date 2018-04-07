//
//  SearchViewController.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-27.
//

import UIKit
import GooglePlaces
import GooglePlacePicker
import MapKit
import Firebase


class SearchViewController: UITableViewController, GMSPlacePickerViewControllerDelegate{
    let NUMBER_OF_SECTIONS:Int = 1
    let LoginControllerIdentifier = "LoginControllerIdentifier"
    let recentPlacesTableIdentifier = "recentPlacesTableIdentifier"
    var recentPlacesDeck = RecentPlacesDeck()
    
    @IBOutlet weak var recentPlacesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let akankshasColor = UIColor(red: CGFloat(0.053), green: CGFloat(0.069), blue: CGFloat(0.095), alpha: 1);
        self.navigationController?.navigationBar.backgroundColor = akankshasColor
        self.recentPlacesTableView.tableFooterView = UIView()
        
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        }
        
        // get logged in user
        let userID = Auth.auth().currentUser?.uid
        
        // retrieve recent places from recent places database
        Database.database().reference().child("recentPlaces").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            if let places = snapshot.value as? NSDictionary{
                for place in places{
                let myplace = place.value as? NSDictionary
                self.recentPlacesDeck.addPlace(newPlace: Place(myId: (place.key as? String)!, myName: myplace!["name"]! as! String, myAddress: myplace!["address"]! as! String, myLat: myplace!["lat"]! as! String, myLng: myplace!["lng"]! as! String))
                }
            }
            
            // update table view
            self.recentPlacesTableView.reloadData()

        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func launchGooglePlacePicker(_ sender: UIBarButtonItem) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    
    // Mark: - Firebase Log Out
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Logout", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.handleLogout()
        }))
        
        alert.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            print("logged out successfullty")
            // jump to login view
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: LoginControllerIdentifier)
            present(loginViewController!, animated: true, completion: nil)
            
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    // MARK: - Deck view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return NUMBER_OF_SECTIONS
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // size of places list
        return recentPlacesDeck.size()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = recentPlacesTableView?.dequeueReusableCell(withIdentifier: recentPlacesTableIdentifier, for: indexPath)
        
        // Configure the cell...
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: recentPlacesTableIdentifier)
        }
        // place address
        cell?.textLabel?.text = recentPlacesDeck.getPlaceAt(i: indexPath.row).getName()
        
        return cell!
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = recentPlacesDeck.getPlaceAt(i: indexPath.row)
        openMapForPlace(lat: place.getLat(), lng: place.getLng(), placeName: place.getName())
    
    }
    
    // MARK: - Enable swipe to delete
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get logged in user
            let userID = Auth.auth().currentUser?.uid
            
            // delete place from recent places table in database
            let placeID = recentPlacesDeck.getPlaceAt(i: indexPath.row).getID()
            // retrieve recent places from recent places database
            Database.database().reference().child("recentPlaces").child(userID!).child(placeID).removeValue()
            
            // Delete the row from the data source
            recentPlacesDeck.removePlaceAtIndex(index: indexPath.row)
            recentPlacesTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Mark: - Google Place Picker
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
        //get current user
        let userID = Auth.auth().currentUser?.uid
        
        // get user
        let lat = String(place.coordinate.latitude)
        let lng = String(place.coordinate.longitude)
        let placeName = place.name
        let address = place.formattedAddress
        
        // add place to recent places deck and ubdate table view
        recentPlacesDeck.addPlace(newPlace: Place(myId: place.placeID, myName: placeName, myAddress: address!, myLat: lat, myLng: lng))
        recentPlacesTableView.reloadData()
        
        // add place to recent places database
        Database.database().reference().child("recentPlaces").child(userID!).child(place.placeID).child("name").setValue(placeName)
        Database.database().reference().child("recentPlaces").child(userID!).child(place.placeID).child("address").setValue(address)
        Database.database().reference().child("recentPlaces").child(userID!).child(place.placeID).child("lat").setValue(lat)
        Database.database().reference().child("recentPlaces").child(userID!).child(place.placeID).child("lng").setValue(lng)
        
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        // navigate using apple maps
        openMapForPlace(lat: lat,lng: lng, placeName: placeName)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    // Mark: - Apple maps navigation
    
    func openMapForPlace(lat: String, lng: String, placeName: String){
        
        let lat1 : NSString = lat as NSString
        let lng1 : NSString = lng as NSString

        let latitude:CLLocationDegrees =  lat1.doubleValue
        let longitude:CLLocationDegrees =  lng1.doubleValue

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(placeName)"
        mapItem.openInMaps(launchOptions: options)
        
    }

}
