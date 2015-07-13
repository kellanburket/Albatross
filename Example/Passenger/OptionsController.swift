//
//  OptionsController.swift
//  Passenger
//
//  Created by Kellan Cummings on 7/12/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit

class OptionsController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    var user: User?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var status: UITextView!
    
    override func viewDidLoad() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: "dismissKeyboard:"
            )
        )
    }

    @IBAction func showUserTweets(sender: AnyObject) {
        User.lookup(["screen_name": username.text]) { users in
            println(users)
            if let users = users {
                if users.count > 0 {
                    self.user = users[0]
                    
                    Status.search(["screen_name": self.username.text, "count": 20]) { statuses in
                        if let statuses = statuses as? [Status] {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier("showTweets", sender: statuses)
                            }
                        } else {
                            self.doAlert("Unable to Find Tweets for '\(self.username.text)'")
                        }
                    }
                } else {
                    self.doAlert("Unable to find user named '\(self.username.text)'")
                }
            } else {
                self.doAlert("Unable to Find User '\(self.username.text)'")
            }
        }
    }

    @IBAction func doTweeting(sender: AnyObject) {
        Status.create(["status": status.text]) { passenger in
            println("Result: \(passenger)")

            if let passenger = passenger as? Status {
                self.doAlert("Successfully Posted: \(self.status.text)")
            } else {
                self.doAlert("Unable to post: \(self.status.text)")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? StatusController {
            controller.user = user
            if let statuses = sender as? [Status] {
                controller.statuses = statuses
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func dismissKeyboard(sender: UIGestureRecognizer) {
        status.resignFirstResponder()
        username.resignFirstResponder()
    }
    
    func doAlert(message: String) {
        let alertController = UIAlertController(
            title: "Passenger Test",
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        alertController.addAction(
            UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil)
        )
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
}