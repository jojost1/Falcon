//
//  LaunchTableViewController.swift
//  HoTS
//
//  Created by Joost van den Akker on 26-01-16.
//  Copyright © 2016 JoAk. All rights reserved.
//

import UIKit

extension NSDate {
    func dateStringWithFormat(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

class LaunchTableViewController: UITableViewController {
    // MARK: Properties
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var launches = [Launch]()
    var newLaunches = [Launch]()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barStyle = .Black
        progressView.progressTintColor = UIColor(red:0.97, green:0.91, blue:0.11, alpha:1)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        let loadedlastLaunchData = defaults.stringForKey("lastLaunchData")
        
        //If this is first startup, get data; otherwise just load old data
        if loadedlastLaunchData == nil {
            loadLaunches()
        } else {
            let launchDataList = loadedlastLaunchData!.componentsSeparatedByString("#")
            var launchComponents = [String]()
            var t = 0
            for x in launchDataList {
                if t == 0 {
                    launchComponents = x.substringWithRange(Range<String.Index>(x.startIndex.advancedBy(17)..<x.endIndex)).componentsSeparatedByString(";")
                } else {
                    launchComponents = x.componentsSeparatedByString(";")
                }
                let launch = Launch(launchID: Int(launchComponents[0])!, name: launchComponents[1], launchDate: launchComponents[2], successful: launchComponents[3], landing: launchComponents[4], payload: launchComponents[5], orbit: launchComponents[6], launchVehicle: launchComponents[7], launchType: launchComponents[8], launchSite: launchComponents[9], launchSpecial: launchComponents[10], youtubeFullWebcast: launchComponents[11], youtubeTechnicalWebcast: launchComponents[12], youtubeLanding: launchComponents[13], launchDescription: launchComponents[14])!
                t += 1
                launches += [launch]
            }
        }
    }
    
    func loadLaunches() {
        //List with all data in String format
        var launchDataList = [String]()
        //On background, get WebPage data
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        let jiDoc = Ji(htmlURL: NSURL(string: "https://jojost1.github.io/")!)
        let bodyNode = jiDoc?.xPath("body")
        let launchData = ("\(bodyNode)")
        launchDataList = launchData.componentsSeparatedByString("#")
        //On foreground, check internet etc
        dispatch_async(dispatch_get_main_queue()) {
            var t = 0
            var launchComponents = [String]()
            var minuteTimeDifference:Int?
            let minuteTimeDifferenceParameter = 240 //Minutes between refreshes when everything gets loaded again (images)
        //If list is empty, so no internet, alert
        if launchDataList[0] == "nil" {
            self.refreshControl!.endRefreshing()
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else { //If list is not empty, save String and check the time difference
            self.defaults.setObject(launchData, forKey: "lastLaunchData")
            //Calculate time between checking if there was a last time
            if self.defaults.stringForKey("LastCheckedTime") != nil {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
                let lastCheckedTime = dateFormatter.dateFromString(self.defaults.stringForKey("LastCheckedTime")!)
                let currentTimeString = NSDate().dateStringWithFormat("dd-MM-yyyy hh:mm:ss")
                let currentTime = dateFormatter.dateFromString(currentTimeString)
                minuteTimeDifference = currentTime!.minutesFrom(lastCheckedTime!)
                if minuteTimeDifference > minuteTimeDifferenceParameter {
                    self.progressView.progress = 0
                    self.progressView.hidden = false
                }
            } else {
                    self.progressView.progress = 0
                    self.progressView.hidden = false
            }
            
            //Remove all launches from the list
            self.newLaunches.removeAll()
            //On background, parse String
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                print("Begin Downloads")
                for x in launchDataList {
                    if t == 0 {
                        launchComponents = x.substringWithRange(Range<String.Index>(x.startIndex.advancedBy(17)..<x.endIndex)).componentsSeparatedByString(";")
                    } else {
                        launchComponents = x.componentsSeparatedByString(";")
                    }
                    let launch = Launch(launchID: Int(launchComponents[0])!, name: launchComponents[1], launchDate: launchComponents[2], successful: launchComponents[3], landing: launchComponents[4], payload: launchComponents[5], orbit: launchComponents[6], launchVehicle: launchComponents[7], launchType: launchComponents[8], launchSite: launchComponents[9], launchSpecial: launchComponents[10], youtubeFullWebcast: launchComponents[11], youtubeTechnicalWebcast: launchComponents[12], youtubeLanding: launchComponents[13], launchDescription: launchComponents[14])!
                    
                    if minuteTimeDifference != nil {
                        if minuteTimeDifference > minuteTimeDifferenceParameter {
                            self.downloadPatches(Int(launchComponents[0])!)
                        }
                    } else {
                        self.downloadPatches(Int(launchComponents[0])!)
                    }
                    
                    self.newLaunches += [launch]
                    t += 1
                    //On foreground between parsing, update progress
                    dispatch_async(dispatch_get_main_queue()) {
                    print("PROGRESS \(t)")
                    self.progressView.progress = Float(t)/Float(launchDataList.count)
                    }
                }
                //On foreground after parsing, reload tableView / Stop Refreshing / Get and save date and time
                dispatch_async(dispatch_get_main_queue()) {
                    print("STOP REFRESH")
                    self.launches = self.newLaunches
                    self.tableView.reloadData()
                    self.progressView.hidden = true
                    self.refreshControl!.endRefreshing()
                    self.defaults.setObject(NSDate().dateStringWithFormat("dd-MM-yyyy hh:mm:ss"), forKey: "LastCheckedTime")
                }
            }
        }
        }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return launches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "LaunchTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LaunchTableViewCell
        
        // Fetches the appropriate hero for the data source layout.
        let launch = launches[indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .NoStyle
        
        //Patch Image, if path is there -> Patch, otherwise the PlaceholderPatch
        cell.photoImageView.image = loadImageFromPath(self.fileInDocumentsDirectory("launch\(launch.launchID)Image"))
        
        cell.nameLabel.text = launch.name
        cell.vehicleLabel.text = "\(launch.launchDate) - \(launch.launchVehicle)"
        cell.specialLabel.text = launch.launchSpecial
        
        if launch.successful == "Y" {
            cell.backgroundColor = UIColor.init(red: 0.5, green: 0.8, blue: 0.2, alpha: 0.15)
            }
        if launch.successful == "N" {
            cell.backgroundColor = UIColor.init(red: 0.8, green: 0.4, blue: 0.3, alpha: 0.15)
        }
        if launch.successful == "P" {
            cell.backgroundColor = UIColor.init(red: 0.85, green: 0.7, blue: 0.25, alpha: 0.15)
        }
        if launch.successful == "U" {
            cell.backgroundColor = UIColor.init(red: 0.2, green: 0.4, blue: 0.9, alpha: 0.15)
        }
        if launch.successful == "S" {
            cell.backgroundColor = UIColor.init(red: 0.8, green: 0.2, blue: 0.8, alpha:0.15)
        }
        
        return cell
    }
    
    func downloadPatches(launchID: Int) {
        let imageURL = NSURL(string: "https://jojost1.github.io/\(launchID).png")
        
            let data = NSData(contentsOfURL: imageURL!)
            if data == nil {
                print("No Patch found on Server for launch \(launchID)")
            } else {
                print("Downloading Patch for launch \(launchID)")
                self.saveImage(UIImage(data: data!)!, path: self.fileInDocumentsDirectory("launch\(launchID)Image"))
            }
                print("Image Downloaded for launch \(launchID)")
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "Show Launch Detail":
                    let LaunchDetailVC = segue.destinationViewController as! LaunchDetailViewController
                    if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                        LaunchDetailVC.currentLaunch = launchAtIndexPath(indexPath)
                }
                default: break
            }
        }
    }
    
    func launchAtIndexPath (indexPath: NSIndexPath) -> Launch {
        return launches[indexPath.row]
    }
    
    //Pull to Refresh
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.loadLaunches()
        self.tableView.reloadData()
        
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func saveImage (image: UIImage, path: String ) -> Bool{
        
        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = pngImageData!.writeToFile(path, atomically: true)
        
        return result
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        
        if image == nil {
            print("Path not on phone, placeholder loaded")
            return UIImage(named: "PatchPlaceholder")
        }
        print("Loading image from path") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
}