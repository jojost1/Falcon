//
//  LaunchDetailViewController.swift
//  SpaceXLive
//
//  Created by Joost van den Akker on 06-03-16.
//  Copyright © 2016 Joost van den Akker. All rights reserved.
//

import UIKit
import SafariServices

class LaunchDetailViewController: UIViewController {
    
    @IBOutlet weak var launchsiteLabel: UILabel!
    @IBOutlet weak var payloadLabel: UILabel!
    @IBOutlet weak var orbitLabel: UILabel!
    @IBOutlet weak var landingLabel: UILabel!
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var topImageDownloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var landingButton: UIButton!
    
    var currentLaunch:Launch?
    
    var topImageData:NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = currentLaunch?.name
        if currentLaunch?.landing == "-" || currentLaunch?.landing == "N/A" {
            self.landingButton.hidden = true
        }
        
        if currentLaunch?.orbit == "N/A" && (currentLaunch?.landing == "RTLS Success" || currentLaunch?.landing == "ASDS Attempt") {
            self.launchButton.hidden = true
        }
        
        if currentLaunch?.successful == "U" {
            self.launchButton.hidden = true
            self.landingButton.hidden = true
        }
        
        topImageDownloadActivityIndicator.startAnimating()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.downloadImage((self.currentLaunch?.launchID)!)
            
            dispatch_async(dispatch_get_main_queue()) {
                if self.topImageData != nil {
                    self.topImage.image = UIImage(data:self.topImageData!)
                }
                self.topImageDownloadActivityIndicator.stopAnimating()
            }
        }
        
        /*if currentLaunch?.successful == "Y" {
            self.view.backgroundColor = UIColor.init(red: 0.5, green: 0.8, blue: 0.2, alpha: 1)
        }
        if currentLaunch?.successful == "N" {
            self.view.backgroundColor = UIColor.init(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)
        }
        if currentLaunch?.successful == "P" {
            self.view.backgroundColor = UIColor.init(red: 0.9, green: 0.6, blue: 0.25, alpha: 1)
        }
        if currentLaunch?.successful == "U" {
            self.view.backgroundColor = UIColor.init(red: 0.2, green: 0.5, blue: 0.9, alpha: 1)
        }
        if currentLaunch?.successful == "S" {
            self.view.backgroundColor = UIColor.init(red: 0.9, green: 0.4, blue: 0.8, alpha: 1)
        }*/
        
        launchsiteLabel.text = currentLaunch?.launchSite
        
        payloadLabel.text = currentLaunch?.payload
        
        orbitLabel.text = currentLaunch?.orbit
        
        landingLabel.text = currentLaunch?.landing
        
        descriptionTextView.text = currentLaunch?.launchDescription
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadImage(launchID: Int) {
        let imageURL = NSURL(string: "https://jojost1.github.io/\(launchID)TopImage.png")
        
        let data = NSData(contentsOfURL: imageURL!)
        print("Downloaded Data")
        if data == nil {
            print("No Top Image found on Server for launch \(launchID)")
        } else {
            print("Got Top Image for launch \(launchID)")
            topImageData = data
        }
    }
    
    @IBAction func youtubeLaunchButton(sender: AnyObject) {
        //If FullWebcast is empty, give alert
        if currentLaunch?.youtubeFullWebcast != "" {
            let fullWebcastURL = NSURL(string: (currentLaunch?.youtubeFullWebcast)!)!
            //If TechnicalWebcast is empty, just go to FullWebcast
            if currentLaunch?.youtubeTechnicalWebcast == "" {
            if #available(iOS 9.0, *) {
                    let vc = SFSafariViewController(URL: fullWebcastURL, entersReaderIfAvailable: true)
                    presentViewController(vc, animated: true, completion: nil)
                } else { //When no iOS9
                    UIApplication.sharedApplication().openURL(fullWebcastURL)
                }
            } else { //If there are two webcasts, give option
                let technicalWebcastURL = NSURL(string: (currentLaunch?.youtubeTechnicalWebcast)!)!
                let alertController = UIAlertController(title: "Watch the launch", message: "Which webcast would you like to see?", preferredStyle: .ActionSheet)
                let fullWebcast = UIAlertAction(title: "Full Webcast", style: .Default, handler: { (action) -> Void in
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: fullWebcastURL, entersReaderIfAvailable: true)
                        self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(fullWebcastURL)
                    }
                })
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                })
                let technicalWebcast = UIAlertAction(title: "Technical Webcast", style: .Default) { (action) -> Void in
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: technicalWebcastURL, entersReaderIfAvailable: true)
                        self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(technicalWebcastURL)
                    }
                }
                
                alertController.addAction(fullWebcast)
                alertController.addAction(cancel)
                alertController.addAction(technicalWebcast)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
        } else { //Alert
            let alert = UIAlertView(title: "No Launch Footage", message: "I couldn't find any launch footage for this launch!", delegate: nil, cancelButtonTitle: "Damn.")
            alert.show()
        }
    }
    
    @IBAction func youtubeLandingButton(sender: AnyObject) {
        //If there is a link, show it, otherwise give alert
        if currentLaunch?.youtubeLanding != "" {
            let landingURL = NSURL(string: (currentLaunch?.youtubeLanding)!)!
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(URL: landingURL, entersReaderIfAvailable: true)
                presentViewController(vc, animated: true, completion: nil)
            } else { //When no iOS9
                UIApplication.sharedApplication().openURL(landingURL)
            }
        } else { //Alert
            let alert = UIAlertView(title: "No Landing Footage", message: "I couldn't find any landing footage for this landing!", delegate: nil, cancelButtonTitle: "Damn.")
            alert.show()
        }
    }
}

