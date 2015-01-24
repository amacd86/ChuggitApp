//
//  UserTableViewController.swift
//  Chuggit
//
//  Created by Angus MacDonald on 1/22/15.
//  Copyright (c) 2015 Hutch Productions, LLC. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    
    var users = [""]
    var following = [Bool]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Below [AnyObject!] is an array to display all objects instead of just one
        
        println(PFUser.currentUser())
        var query = PFUser.query()
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error:NSError!) -> Void in
        //Starting by removing all users so there are no repeated users in the case of refreshing the app
            self.users.removeAll(keepCapacity: true)
            
            for object in objects {
                var isFollowing:Bool
                var user:PFUser = object as PFUser
                //Display all other users except the actual user themselves
                
                if user.username != PFUser.currentUser().username {
                    self.users.append(user.username)
                    isFollowing = false
                    
                    var query = PFQuery(className: "followers")
                    query.whereKey("follower", equalTo:PFUser.currentUser().username)
                    query.whereKey("following", equalTo:user.username)
                    query.findObjectsInBackgroundWithBlock {
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            for objects in objects {
                                isFollowing = true
                            }
                            self.following.append(isFollowing)
                            self.tableView.reloadData()
                        }else {
                        println(error)
                        }
                    }
                }
            }
            self.tableView.reloadData()
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            var query = PFQuery(className:"followers")
            query.whereKey("follower", equalTo:PFUser.currentUser().username)
            query.whereKey("following", equalTo:cell.textLabel?.text)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                   /*my object.deleteInBackgorundWithTarget does not seem to be working
                    I want to clear out the objects so that you are not following the same person many times
                    as it is right now in parse...
                    */
                    for object in objects {
                        object.deleteInBackgroundWithTarget(nil, selector: nil)
                    }
                } else {
                    // Log details of the failure
                    println(error)
                }
            }
            
        }else{
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject(className: "followers")
            following["following"] = cell.textLabel?.text
            following["follower"] = PFUser.currentUser().username
            
            following.saveInBackgroundWithTarget(self, selector: nil)
        }
    }
    
}
