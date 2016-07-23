//
//  SettingsTableViewController.swift
//  SpaceXLive
//
//  Created by Joost van den Akker on 06-03-16.
//  Copyright © 2016 Joost van den Akker. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var switch1: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barStyle = .Black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func feedbackButton(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["SUPPORTSHITMAIL@gmail.com"])
            mail.setSubject("Feedback SpaceX App")
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    @IBAction func notificationSwitch(sender: AnyObject) {
        
    }
    
}

