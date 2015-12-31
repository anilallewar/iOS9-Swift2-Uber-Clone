//
//  RideAcceptedDetailsViewController.swift
//  Uber
//
//  Created by Anil Allewar on 12/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RideAcceptedDetailsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    var currentAcceptedRide:RideData?
    
    @IBOutlet var acceptedRideMapView: MKMapView!
    
    @IBOutlet var destinationAddress: UITextField!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        self.acceptedRideMapView.showsUserLocation = true
        self.locationManager.startUpdatingLocation()
        
        self.acceptedRideMapView.delegate = self
        
        // Define zoom level
        let latDelta:CLLocationDegrees = 0.02
        let longDelta:CLLocationDegrees = 0.02
        
        let mkSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let mkRegion = MKCoordinateRegionMake(self.currentAcceptedRide!.getCoordinates(), mkSpan)
        
        self.acceptedRideMapView.setRegion(mkRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.currentAcceptedRide!.getCoordinates()
        annotation.title = "PickUp Address"
        
        annotation.subtitle = self.currentAcceptedRide!.getAddress()
        
        self.acceptedRideMapView.addAnnotation(annotation)
        
        self.acceptedRideMapView.selectAnnotation(annotation, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tripButtonClicked(sender: AnyObject) {
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentUserCoordinate = locations[0].coordinate
        
        let destinationCoordinate = self.currentAcceptedRide!.getCoordinates()
        
        let directionsRequest = MKDirectionsRequest()
        
        let markCurrentAddress = MKPlacemark(coordinate: CLLocationCoordinate2DMake(currentUserCoordinate.latitude, currentUserCoordinate.longitude), addressDictionary: nil)
        let markPickupAddress = MKPlacemark(coordinate: CLLocationCoordinate2DMake(destinationCoordinate.latitude, destinationCoordinate.longitude), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: markCurrentAddress)
        directionsRequest.destination = MKMapItem(placemark: markPickupAddress)
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if error != nil {
                print(error)
            } else {
                if let response = response {
                    if let calculatedRoute = response.routes[0] as? MKRoute {
                        self.acceptedRideMapView.addOverlay(calculatedRoute.polyline)
                    }
                }
            }
        }
    }
    
    // How to render the line overlay on the map
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            polyLineRenderer.strokeColor = UIColor.blueColor()
            polyLineRenderer.lineWidth = 3
            return polyLineRenderer
        }
        
        // If overlay is not polyline, then need to be handled differently
        return MKOverlayRenderer()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController:RiderFeedTableTableViewController = segue.destinationViewController as! RiderFeedTableTableViewController
        
        viewController.acceptedRideIndex = -1
    }
}
