//
//  ViewController.swift
//  Chuggit
//
//  Created by Angus MacDonald on 12/30/14.
//  Copyright (c) 2014 Hutch Productions, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var signupActive = true
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var alreadyRegistered: UILabel!
    @IBOutlet var signUpLabel: UILabel!
    @IBOutlet var logInLabel: UILabel!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var signupToggleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println(PFUser.currentUser())
        
        logInLabel.alpha = 0
        
        
        //Luke Was Here
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleSignUp(sender: AnyObject) {
        
        //Instead of doubling up on the code maybe make an array to store the data?
        
//        if signupActive == true {
//            signupActive = false
//            signUpLabel.text = "Use the form below to log in"
//            signUpButton.setTitle("Log In", forState: UIControlState.Normal)
//            alreadyRegistered.text = "Not Registered"
//            signupToggleButton.setTitle("Sign Up", forState: UIControlState.Normal)
//            
//        } else {
//            signupActive = true
//            signUpLabel.text = "Use the form below to sign up"
//            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
//            alreadyRegistered.text = "Already Registered"
//            signupToggleButton.setTitle("Log In", forState: UIControlState.Normal)
//        }
        if signupActive == true {
            signupActive = false
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.logInLabel.alpha = 1
                self.signUpLabel.alpha = 0
                self.signUpButton.setTitle("Log In", forState: UIControlState.Normal)
                self.alreadyRegistered.text = "Not Registered"
                self.signupToggleButton.setTitle("Sign Up", forState: UIControlState.Normal)
            })
            
            
        } else {
             signupActive = true
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.logInLabel.alpha = 0
                self.signUpLabel.alpha = 1
                self.signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
                self.alreadyRegistered.text = "Already Registered"
                self.signupToggleButton.setTitle("Log In", forState: UIControlState.Normal)
            })
        }

        
    }
    
    
    //Remember to add in length requirements and shit for username and pass with else if statement
    @IBAction func signUp(sender: AnyObject) {
        
        var error = ""
        
        if username.text == "" || password.text == "" {
            
            error = "Please enter a username and password"
            
        }
        
        if error != "" {
            
            displayAlert("Error In Form", error: error)
            
        } else {
            
            
            var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            /*user.email = "email@example.com"
            // other fields can be set just like with PFObject
            user["phone"] = "415-392-0202" */
            
            
            if signupActive == true {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool!, signupError: NSError!) -> Void in
                    
                    activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signupError == nil {
                        // Hooray! Let them use the app now.
                        
                        println("signed up")
                        
                    } else {
                        if let errorString = signupError.userInfo?["error"] as? NSString {
                            
                            error = errorString
                            
                        } else {
                            
                            error = "Please try again later."
                        }
                        //Remember self. prefix because it is within a closure
                        self.displayAlert("Could Not Sign Up", error: error)
                    }
                }
                
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text, password:password.text) {
                    (user: PFUser!, signupError: NSError!) -> Void in
                    
                    
                    activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signupError == nil {
                        
                        println("logged in")
                        
                    } else {
                        if let errorString = signupError.userInfo?["error"] as? NSString {
                            
                            error = errorString
                            
                        } else {
                            
                            error = "Please try again later."
                        }
                        //Remember self. prefix because it is within a closure
                        self.displayAlert("Could Not Log In", error: error)
                    }
                }
            }
        }
    }
    
    
}


