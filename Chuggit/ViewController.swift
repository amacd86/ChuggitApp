//
//  ViewController.swift
//  Chuggit
//
//  Created by Angus MacDonald on 12/30/14.
//  Copyright (c) 2014 Hutch Productions, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var alreadyRegistered: UILabel!
    
    @IBOutlet var topLabel: UILabel!
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println(PFUser.currentUser())
        /*Alright so with this what I am going to to do print the currentuser to the logs
        and then check to see if there is a currentuser. As long as you are logged into Parse
        on your device then there will be a currentuser. And when we see that currentuser we
        can just jump to the segue to the user table, which bypasses the need to log in everytime.
        */
        
        loginButton.setTitle("Log In", forState: UIControlState.Normal)
        signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        
    }
    
    // Using viewDidAppear because viewDidLoad happens before our view even appears right?
    
    override func viewDidAppear(animated: Bool) {
        
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
    
//    @IBAction func toggleSignUp(sender: AnyObject) {
//        
//        //Instead of doubling up on the code maybe make an array to store the data?
//        
////        if signupActive == true {
////            signupActive = false
////            signUpLabel.text = "Use the form below to log in"
////            signUpButton.setTitle("Log In", forState: UIControlState.Normal)
////            alreadyRegistered.text = "Not Registered"
////            signupToggleButton.setTitle("Sign Up", forState: UIControlState.Normal)
////            
////        } else {
////            signupActive = true
////            signUpLabel.text = "Use the form below to sign up"
////            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
////            alreadyRegistered.text = "Already Registered"
////            signupToggleButton.setTitle("Log In", forState: UIControlState.Normal)
////        }
//        if signupActive == true {
//            signupActive = false
//            
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.logInLabel.alpha = 1
//                self.signUpLabel.alpha = 0
//                self.signUpButton.setTitle("Log In", forState: UIControlState.Normal)
//                self.alreadyRegistered.text = "Not Registered"
//                self.signupToggleButton.setTitle("Sign Up", forState: UIControlState.Normal)
//            })
//            
//            
//        } else {
//             signupActive = true
//            
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.logInLabel.alpha = 0
//                self.signUpLabel.alpha = 1
//                self.signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
//                self.alreadyRegistered.text = "Already Registered"
//                self.signupToggleButton.setTitle("Log In", forState: UIControlState.Normal)
//            })
//        }
//
//        
//    }
    
    func showSpinnerOnLogin(){
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.loginButton.setTitle("", forState: UIControlState.Normal)
            
            self.activityIndicator = UIActivityIndicatorView()
            
            self.loginButton.addSubview(self.activityIndicator)
            self.activityIndicator.autoCenterInSuperview()
            self.activityIndicator.startAnimating()
        })
    
    }
    
    func showSpinnerOnSignup(){
    
         UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.signUpButton.setTitle("", forState: UIControlState.Normal)
        
            self.activityIndicator = UIActivityIndicatorView()
            
            self.signUpButton.addSubview(self.activityIndicator)
            self.activityIndicator.autoCenterInSuperview()
            self.activityIndicator.startAnimating()
        })
    
    }
    
    func hideSpinnerOnLogin() {
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.loginButton.setTitle("Log In", forState: UIControlState.Normal)
        })
        
    }
    
    func hideSpinnerOnSignup() {
    
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        })
        
    }
    
    
    func completedLogin() {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
        }
    }
    
     @IBAction func login(sender: AnyObject) {
        
        self.showSpinnerOnLogin()
        
        PFUser.logInWithUsernameInBackground(usernameField.text, password:passwordField.text) {
            (user: PFUser!, signupError: NSError!) -> Void in
            
            var isLoginValid: Bool = (signupError == nil)
            var error: NSString!
            
            self.hideSpinnerOnLogin()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if isLoginValid {
                
                println("logged in")
                self.completedLogin()
                
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
    
    //Remember to add in length requirements and shit for username and pass with else if statement
    @IBAction func signUp(sender: AnyObject) {
        
        self.showSpinnerOnSignup()
        
        var user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, signupError: NSError!) -> Void in
            
            var isSignupValid: Bool = (signupError == nil)
            var error: NSString!
            
            self.hideSpinnerOnSignup()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if isSignupValid {
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
            
            
    }
    
}


