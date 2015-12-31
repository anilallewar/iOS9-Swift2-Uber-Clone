//
//  RiderFeedTableTableViewController.swift
//  Uber
//
//  Created by Anil Allewar on 12/29/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class RiderFeedTableTableViewController: UITableViewController {

    @IBOutlet var ridesTableView: UITableView!
    
    var ridesArray:[RideData] = []
    
    var acceptedRideIndex:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the refresher
        self.refreshControl?.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)

        // Load the rides that are within 10 miles
        self.retrieveAllRelevantRides()
    }

    // Reload the table every time we navigate to the view
    override func viewDidAppear(animated: Bool) {
        self.ridesTableView.reloadData()
    }
    
    private func retrieveAllRelevantRides() -> Void {
        // Get current user's location
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if let geoPoint = geoPoint {
                
                let rideQuery:PFQuery = PFQuery(className: "Rides")
                rideQuery.whereKey("pickUpCoordinates", nearGeoPoint: geoPoint, withinMiles: 10.0)
                rideQuery.whereKey("status", equalTo: RideStatus.REQUESTED.rawValue)
                
                rideQuery.limit = 5
                
                rideQuery.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                    self.ridesArray.removeAll()
                    if error != nil {
                        self.showAlert("Error retrieving ride", message: (error?.localizedDescription)!)
                    } else {
                        if let objects = results {
                            var rideData:RideData
                            
                            for object in objects {
                                rideData = RideData()
                                rideData.setObjectId(object.objectId!)
                                rideData.setAddress(object["pickUpAddress"] as! String)
                                if let riderGeoPoint = object["pickUpCoordinates"] as? PFGeoPoint {
                                    let riderCoordinates = CLLocationCoordinate2DMake(riderGeoPoint.latitude, riderGeoPoint.longitude)
                                    rideData.setCoordinates(riderCoordinates)
                                }
                                
                                rideData.setCurrentRideStatus(RideStatus(rawValue: object["status"] as! String)!)
                                
                                rideData.setRiderUserId(object["riderUserId"] as! String)
                                
                                // Load the user image
                                self.retrieveUserImage(rideData)
                                
                                // Add to array
                                self.ridesArray.append(rideData)
                            }
                            
                            self.ridesTableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    private func retrieveUserImage(rideData:RideData) -> Void {
    
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(rideData.getRiderUserId()!, block: { (object, error) -> Void in
            if error != nil {
                self.showAlert("Error retrieving user", message: (error?.localizedDescription)!)
            } else {
                if let user = object as? PFUser {
                    
                    rideData.setRiderName(user["name"] as! String)
                    
                    if let imageFile = user["picture"] as? PFFile {
                        imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if error != nil {
                                self.showAlert("Error retrieving user image", message: (error?.localizedDescription)!)
                            } else {
                                if let downloadedImage = UIImage(data : data!) {
                                    rideData.setRiderImage(downloadedImage)
                                    self.ridesTableView.reloadData()
                                }
                            }
                        })
                    }
                    
                }
            }
        })
        
    }
    
    func refreshData(refreshControl: UIRefreshControl) -> Void {
        self.retrieveAllRelevantRides()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ridesArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:RideFeedTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RideFeedTableViewCell

        // Configure the cell...
        let currentRideData = ridesArray[indexPath.row]
        cell.riderImageView.image = currentRideData.getRiderImage()
        cell.riderNameLabel.text = currentRideData.getRiderName()
        cell.riderPickUpAddressLabel.text = currentRideData.getAddress()
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   
    
    // Override to support editing the table view. In our case the actual functionality is provided by the "editActionsForRowAtIndexPath" parameter method
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let accept = UITableViewRowAction(style: .Normal, title: "Accept") { (action, index) -> Void in
            self.updateAcceptRideOnBackEnd(indexPath.row)
        }
        
        accept.backgroundColor = UIColor.grayColor()
        
        let reject = UITableViewRowAction(style: .Normal, title: "Reject") { (action, index) -> Void in
            self.ridesArray.removeAtIndex(indexPath.row)
            // Remove from the passed table view
            self.ridesTableView.reloadData()
        }

        reject.backgroundColor = UIColor.redColor()
        
        return [reject, accept]
    }
    
    private func updateAcceptRideOnBackEnd(selectedRowIndex:Int) -> Void {
        self.acceptedRideIndex = selectedRowIndex
        
        let currentRideData = self.ridesArray[self.acceptedRideIndex]
        
        let rideQuery:PFQuery = PFQuery(className: "Rides")
        
        rideQuery.getObjectInBackgroundWithId(currentRideData.getObjectId()) { (result, error) -> Void in
            if error != nil {
                self.showAlert("Error getting ride information", message: (error?.localizedDescription)!)
            } else if let object = result {
                if let currentStatus = object["status"] as? String {
                    if currentStatus == RideStatus.REQUESTED.rawValue {
                        object["status"] = RideStatus.ACCEPTED.rawValue
                        
                        object.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error != nil {
                                self.showAlert("Error accepting ride", message: (error?.localizedDescription)!)
                            } else {
                                currentRideData.setCurrentRideStatus(RideStatus.ACCEPTED)
                                // Segue to the next details view controller
                                self.performSegueWithIdentifier("showRideDetails", sender: self)
                            }
                        })
                    }
                }
                
            }
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "logOut"{
            PFUser.logOut()
            let viewController:ViewController = segue.destinationViewController as! ViewController
            viewController.navigationItem.hidesBackButton = true

        }
        
        if segue.identifier == "showRideDetails" {
            let viewController:RideAcceptedDetailsViewController = segue.destinationViewController as! RideAcceptedDetailsViewController
            viewController.currentAcceptedRide = self.ridesArray[self.acceptedRideIndex]
            self.ridesArray.removeAtIndex(self.acceptedRideIndex)
            self.ridesTableView.reloadData()
        }
    }

    
    private func showAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
