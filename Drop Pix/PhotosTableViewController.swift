//
//  PhotosTableViewController.swift
//  Drop Pix
//
//  Created by Mike DiNicola on 3/5/16.
//  Copyright © 2016 Mike DiNicola. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController, DBRestClientDelegate {
    
    var _tabBarController: TabBarController!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tableViewReloadData", name: "DBTableViewReloadDataNotification", object: nil)
        
        _tabBarController = tabBarController as! TabBarController
    }    
    
    func tableViewReloadData() {
        tableView.reloadData()
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
        
        if _tabBarController.myContents == nil {
            return 0
        } else {
            return _tabBarController.myContents.count
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("footerView")
        
        if footerView == nil {
            footerView = UITableViewHeaderFooterView(reuseIdentifier: "footerView")
            footerView?.frame = CGRectMake(0, 0, view.bounds.size.width, 49)
            
            let backgroundView = UIView(frame: footerView!.frame)
            backgroundView.backgroundColor = .whiteColor()
            
            footerView?.contentView.addSubview(backgroundView)
        }
        
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 49
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("photoCell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        let fileName = _tabBarController.fileNames[indexPath.row]
        let dict = _tabBarController.myContents[fileName] as! [String: AnyObject]
        let file = dict["file"] as! DBMetadata
        
        let localDir = NSTemporaryDirectory()
        let localPath = localDir.stringByAppendingString(file.filename)
        
         _tabBarController.restClient.loadFile(file.path, intoPath: localPath)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        if file.filename.containsString("TITLE") {
            cell.textLabel?.text = dateFormatter.stringFromDate(file.lastModifiedDate)
            cell.detailTextLabel?.text = ""
        } else {
            
            cell.textLabel?.text = file.filename.componentsSeparatedByString(", ").first
            cell.detailTextLabel?.text = dateFormatter.stringFromDate(file.lastModifiedDate)
        }

        if let image = dict["thumb"] as? UIImage {
            cell.imageView?.image = image
            cell.imageView?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let fileName = _tabBarController.fileNames[indexPath.row]
        let dict = _tabBarController.myContents[fileName] as! [String: AnyObject]
        
        if dict["thumb"] != nil {
            if _tabBarController.imageForSharingView != nil {
                
                let timer = NSTimer(timeInterval: 0.5, target: self, selector: "animateImageForSharingViewTimerCallback:", userInfo: ["dict": dict], repeats: false)
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
                
            } else {
                
                _tabBarController.animateImageForSharingView(dict)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    // MARK: - Custom Methods
    
    func animateImageForSharingViewTimerCallback(timer: NSTimer) {
        _tabBarController.animateImageForSharingViewTimerCallback(timer)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
