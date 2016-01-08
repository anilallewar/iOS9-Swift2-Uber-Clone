//
//  RideData.swift
//  Uber
//
//  Created by Anil Allewar on 12/23/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation

// Model to hold the coordinates and the associated address
class RideData {
    private var coordinates : CLLocationCoordinate2D!
    private var address : String = " "
    private var currentRideStatus: RideStatus = RideStatus.NEW
    private var objectId : String!
    private var riderUserId : String?
    private var riderName : String?
    private var riderImage : UIImage?
    private var destinationAddress : String?
    private var destinationCoordinates : CLLocationCoordinate2D?
    
    func getCoordinates() -> CLLocationCoordinate2D {
        return coordinates
    }
    
    func setCoordinates(inputCoordinates:CLLocationCoordinate2D) -> Void {
        self.coordinates = inputCoordinates
    }
    
    func getAddress() -> String {
        return address
    }
    
    func setAddress(inputAddress:String) -> Void {
        self.address = inputAddress
    }
    
    func getCurrentRideStatus() -> RideStatus {
        return self.currentRideStatus
    }
    
    func setCurrentRideStatus(rideStatus:RideStatus) -> Void {
        self.currentRideStatus = rideStatus
    }
    
    func getObjectId() -> String {
        return self.objectId
    }
    
    func setObjectId(savedObjectId:String) -> Void {
        self.objectId = savedObjectId
    }
    
    func getRiderUserId() -> String? {
        return self.riderUserId
    }
    
    func setRiderUserId(userId:String) -> Void {
        self.riderUserId = userId
    }
    
    func getRiderName() -> String? {
        return self.riderName
    }
    
    func setRiderName(userName:String) -> Void {
        self.riderName = userName
    }
    
    func getRiderImage() -> UIImage? {
        return self.riderImage
    }
    
    func setRiderImage(savedRiderImage:UIImage) -> Void {
        self.riderImage = savedRiderImage
    }
    
    func getDestinationCoordinates() -> CLLocationCoordinate2D? {
        return destinationCoordinates
    }
    
    func setDestinationCoordinates(inputCoordinates:CLLocationCoordinate2D) -> Void {
        self.destinationCoordinates = inputCoordinates
    }
    
    func getDestinationAddress() -> String? {
        return destinationAddress
    }
    
    func setDestinationAddress(inputAddress:String) -> Void {
        self.destinationAddress = inputAddress
    }
}

enum RideStatus : String {
    case NEW = "New"
    case REQUESTED = "Requested"
    case ACCEPTED = "Accepted"
    case CANCELLED = "Cancelled"
    case COMPLETED = "Completed"
    case STARTED = "Started"
}