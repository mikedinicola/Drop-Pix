//
//  PhotosTableViewController.swift
//  Drop Pix
//
//  Created by Mike DiNicola on 3/5/16.
//  Copyright © 2016 Mike DiNicola. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController, DBRestClientDelegate {
    
    var restClient: DBRestClient!
    
    var myContents: [AnyObject]!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        restClient = DBRestClient(session: DBSession.sharedSession())
        restClient.delegate = self
        
        loadDBMetadata()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadDBMetadata", name: "DBLFileUploadedSuccessfullyNotification", object: nil)
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
        
        if myContents == nil {
            return 0
        } else {
            return myContents.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("photoCell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        let file = myContents[indexPath.row] as! DBMetadata
        cell.textLabel?.text = file.filename
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(file.lastModifiedDate)
        
        return cell
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
    
    func loadDBMetadata() {
        restClient.loadMetadata("/Drop-Pix")
    }
    
    // MARK: - DBRestClientDelegate
    
    func restClient(client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        if metadata.isDirectory == true && metadata.contents.count > 0 {
            NSLog("Folder '%@' contains:", metadata.path);
            for fileObject in metadata.contents {
                let file = fileObject as! DBMetadata
                NSLog("\t%@", file.filename);
            }
            myContents = metadata.contents
            if metadata.contents.count > 1 {
                parentViewController?.navigationItem.title = String(format: "%ld Photos", metadata.contents.count)
            } else {
                parentViewController?.navigationItem.title = String(format: "%ld Photo", metadata.contents.count)
            }
            tableView.reloadData()
        } else {
            parentViewController?.navigationItem.title = "No Photos"
        }
    }
    
    func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        NSLog("Error loading metadata: %@", error);
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
