//
//  SignInViewController.swift
//  Uber
//
//  Created by Anil Allewar on 12/17/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Parse

class SignInViewController: UIViewController {

    @IBOutlet var userPictureView: UIImageView!
    
    @IBOutlet var isDriver: UISwitch!
    
    
    @IBAction func signUpClicked(sender: AnyObject) {
        
        do {
            PFUser.currentUser()?["isDriver"] = self.isDriver.on
            try PFUser.currentUser()?.save()
            
            print("Signed up current user with isDriver: \(self.isDriver.on)")
            if self.isDriver.on == true {
                    self.performSegueWithIdentifier("showDriverView", sender: self)
                } else {
                    self.performSegueWithIdentifier("showRiderView", sender: self)
                }
            
        } catch {
            print("Error while signing up the user: \(error)")
        }
    }
 
    override func viewDidLoad() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, gender, email"])
        
        graphRequest.startWithCompletionHandler { (connection, object, error) -> Void in
            if error != nil {
                print("Error while making Graph request to Facebook")
            } else {
                if let result = object {
                    PFUser.currentUser()?["name"] = result["name"]
                    PFUser.currentUser()?["email"] = result["email"]
                    PFUser.currentUser()?["gender"] = result["gender"]
                    
                    PFUser.currentUser()?.saveInBackground()
                    
                    let userId = result["id"] as! String
                    self.saveUserImageInBackground(userId)
                }
            }
        }
    }
    
    private func saveUserImageInBackground(userId:String) -> Void {
        let facebookProfileUrlString = "https://graph.facebook.com/" + userId + "/picture?type=large"
        
        if let facebookProfileUrl = NSURL(string: facebookProfileUrlString){
            if let data = NSData(contentsOfURL: facebookProfileUrl){
                self.userPictureView.image = UIImage(data: data)
                
                let imageFile:PFFile = PFFile(data: data)!
                PFUser.currentUser()?["picture"] = imageFile
                PFUser.currentUser()?.saveInBackground()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logOut"{
            PFUser.logOut()
        }
    }
}
