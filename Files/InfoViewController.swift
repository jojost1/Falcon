//
//  InfoViewController.swift
//  SpaceXLive
//
//  Created by Joost van den Akker on 06-03-16.
//  Copyright © 2016 Joost van den Akker. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    
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
}

