//
//  SecondViewController.swift
//  SpaceXLive
//
//  Created by Joost van den Akker on 06-03-16.
//  Copyright © 2016 Joost van den Akker. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var liveWebPageList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Make navbar black
        navigationController!.navigationBar.barStyle = .Black
        //Hide WebView
        webView.hidden = true
        //Start animating indicator
        activityIndicator.startAnimating()

        //Start parsing /live webpage for website and upcoming launch data
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let jiDoc = Ji(htmlURL: NSURL(string: "https://jojost1.github.io/live")!)
            let bodyNode = jiDoc?.xPath("body")
            let liveWebPage = ("\(bodyNode)")
            self.liveWebPageList = liveWebPage.componentsSeparatedByString("#")
        
            dispatch_async(dispatch_get_main_queue()) {
                //When no internet connection, alert
                if self.liveWebPageList[0] == "nil" {
                    let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                } else { //User has got internet connection
                    //Load the webview
                    self.loadWebView()
                    //If there is a launch time, set the notifications
                    if self.liveWebPageList[3] != "" {
                        self.setNotifications()
                    } else {
                        UIApplication.sharedApplication().cancelAllLocalNotifications()
                    }
                }
                //Stop the activity indicator after all this, internet or not
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func setNotifications() {
        //Check notification settings
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        //When settings are wrong, give alert
        if settings.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //Get userCalendar, launch name and launch date in String format
        let userCalendar = NSCalendar.currentCalendar()
        let launchName = liveWebPageList[1]
        let launchDateString = liveWebPageList[3]
        
        //String to NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let launchDate = dateFormatter.dateFromString(launchDateString)!
        
        //Set notification for 1 day up front
        let periodComponentsDay = NSDateComponents()
        periodComponentsDay.day = -1
        let launchDate1Day = userCalendar.dateByAddingComponents(
            periodComponentsDay,
            toDate: launchDate,
            options: [])!
        
        let notification1Day = UILocalNotification()
        notification1Day.fireDate = launchDate1Day
        notification1Day.timeZone = NSTimeZone.localTimeZone()
        notification1Day.alertBody = "\(launchName) will launch in 1 day!"
        notification1Day.soundName = UILocalNotificationDefaultSoundName
        notification1Day.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification1Day)
        
        //Set notification for 1 hour up front
        let periodComponentsHour = NSDateComponents()
        periodComponentsHour.hour = -1
        let launchDate1Hour = userCalendar.dateByAddingComponents(
            periodComponentsHour,
            toDate: launchDate,
            options: [])!
        
        let notification1Hour = UILocalNotification()
        notification1Hour.fireDate = launchDate1Hour
        notification1Hour.timeZone = NSTimeZone.localTimeZone()
        notification1Hour.alertBody = "\(launchName) will (hopefully) launch in 1 hour!"
        notification1Hour.soundName = UILocalNotificationDefaultSoundName
        notification1Hour.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification1Hour)
        
        //Set notification for 10 minutes up front
        let periodComponentsMinutes = NSDateComponents()
        periodComponentsMinutes.minute = -10
        let launchDate15Minutes = userCalendar.dateByAddingComponents(
            periodComponentsMinutes,
            toDate: launchDate,
            options: [])!
        
        let notification15Minutes = UILocalNotification()
        notification15Minutes.fireDate = launchDate15Minutes
        notification15Minutes.timeZone = NSTimeZone.localTimeZone()
        notification15Minutes.alertBody = "\(launchName) will (hopefully) launch in 15 minutes!"
        notification15Minutes.soundName = UILocalNotificationDefaultSoundName
        notification15Minutes.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification15Minutes)
    }
    
    func loadWebView() {
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: "\(self.liveWebPageList[2])")!))
        //Show WebView
        webView.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshButton(sender: AnyObject) {
        //Start parsing /live webpage for website and upcoming launch data
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let jiDoc = Ji(htmlURL: NSURL(string: "https://jojost1.github.io/live")!)
            let bodyNode = jiDoc?.xPath("body")
            let liveWebPage = ("\(bodyNode)")
            self.liveWebPageList = liveWebPage.componentsSeparatedByString("#")
            
            dispatch_async(dispatch_get_main_queue()) {
                //When no internet connection, alert
                if self.liveWebPageList[0] == "nil" {
                    let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                } else { //User has got internet connection
                    //Load the webview
                    self.loadWebView()
                    //If there is a launch time, set the notifications
                    if self.liveWebPageList[3] != "" {
                        self.setNotifications()
                    }
                }
            }
        }

    }
}

