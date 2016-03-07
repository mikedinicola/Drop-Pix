//
//  TabBarController.swift
//  Drop Pix
//
//  Created by Mike DiNicola on 3/5/16.
//  Copyright © 2016 Mike DiNicola. All rights reserved.
//

import UIKit
import CoreLocation

class TabBarController: UITabBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DBRestClientDelegate, CLLocationManagerDelegate {
    
    var restClient: DBRestClient!
    
    var myContents: [String: AnyObject]! = [:]
    var fileNames: [String]! = []
    var imageForSharingView: ImageForSharingView?
    
    var picButton: UIButton?
    
    var locationManager: CLLocationManager!
    
    let tabBarHeight: CGFloat = 49
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        restClient = DBRestClient(session: DBSession.sharedSession())
        restClient.delegate = self
        
        loadDBMetadata()
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            
            locationManager.delegate = self
            
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            
            locationManager.delegate = self
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0...2 {
            tabBar.items![i].setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)
            tabBar.items![i].titlePositionAdjustment = UIOffsetMake(0, -tabBarHeight/3)
        }
        
        picButton = UIButton(type: .System)
        picButton!.frame = CGRectMake(view.frame.size.width/3*1, 0, view.frame.size.width/3, tabBarHeight)
        picButton!.backgroundColor = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
        picButton?.setTitle("Camera", forState: .Normal)
        picButton?.setTitleColor(.whiteColor(), forState: .Normal)
        
        picButton!.addTarget(self, action: Selector("picButtonTouchUpInside"), forControlEvents: .TouchUpInside)
        
        tabBar.addSubview(picButton!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    
    func loadDBMetadata() {
        restClient.loadMetadata("/Drop-Pix")
    }
    
    func imageForSharingViewButtonTouchUpInside() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .TransitionNone, animations: { () -> Void in
            
            var imageForSharingViewFrame =  self.view.bounds
            imageForSharingViewFrame.origin.y = self.view.bounds.size.height+128
            self.imageForSharingView?.frame = imageForSharingViewFrame
            }) { (completed) -> Void in
                
                self.imageForSharingView?.removeFromSuperview()
                self.imageForSharingView = nil
        }
    }
    
    func animateImageForSharingViewTimerCallback(timer: NSTimer) {
        
        let userInfo = timer.userInfo as! [String: AnyObject]
        let dict = userInfo["dict"] as! [String: AnyObject]
        animateImageForSharingView(dict)
    }
    
    func animateImageForSharingView(dict: [String: AnyObject]) {
        
        if imageForSharingView != nil {
            imageForSharingView?.removeFromSuperview()
            imageForSharingView = nil
        }
        
        imageForSharingView = NSBundle.mainBundle().loadNibNamed("ImageForSharingView", owner: self, options: nil).first as? ImageForSharingView
        var imageForSharingViewFrame =  view.bounds
        imageForSharingViewFrame.origin.y = view.bounds.size.height
        imageForSharingView?.frame = imageForSharingViewFrame
        
        imageForSharingView?.button.addTarget(self, action: "imageForSharingViewButtonTouchUpInside", forControlEvents: .TouchUpInside)
        
        if dict["image"] != nil {
            imageForSharingView?.imageView.image = dict["image"] as? UIImage
        } else {
            imageForSharingView?.imageView.image = dict["thumb"] as? UIImage
        }
        
        imageForSharingView?.imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        
        super.view.addSubview(imageForSharingView!)
        
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .TransitionNone, animations: { () -> Void in
            self.imageForSharingView?.frame = self.view.bounds
            }, completion: nil)
        
    }
    
    func picButtonTouchUpInside() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .Camera
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func uploadImageToDropbox(image: UIImage!, filename: String? = "TITLE.PNG") {
        let localDir = NSTemporaryDirectory()
        let localPath = localDir.stringByAppendingString(filename!)
        
        let imageData = NSData(data: UIImagePNGRepresentation(image)!)
        imageData.writeToFile(localPath, atomically: true)
        
        let destDir = "/Drop-Pix"
        restClient.uploadFile(filename, toPath: destDir, withParentRev: nil, fromPath: localPath)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        
        // Upload photo to Dropbox
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {

            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(locationManager.location!, completionHandler: { (placemarkArray, error) -> Void in
                guard let locality = placemarkArray?.first?.locality else {return}
                
                self.uploadImageToDropbox(image, filename: locality.stringByAppendingString(".PNG"))
            })
        } else {
            uploadImageToDropbox(image)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status != .AuthorizedWhenInUse && status != .NotDetermined {
            
            let alertController = UIAlertController(title: "That's okay!", message: "You can enable location services anytime in your system settings.", preferredStyle: .Alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(alertAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - DBRestClientDelegate
    
    func restClient(client: DBRestClient!, uploadedFile destPath: String!, from srcPath: String!, metadata: DBMetadata!) {
        NSLog("File uploaded successfully to path: %@", metadata.path)
        
        loadDBMetadata()
    }
    
    func restClient(client: DBRestClient!, uploadFileFailedWithError error: NSError!) {
        NSLog("File upload failed with error: %@", error)
    }
    
    func restClient(client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        if metadata.isDirectory == true && metadata.contents.count > 0 {
            NSLog("Folder '%@' contains:", metadata.path)
            
            for fileObject in metadata.contents {
                let file = fileObject as! DBMetadata
                NSLog("\t%@", file.filename)
                
                if myContents[file.filename] == nil {
                    myContents[file.filename] = ["file": file]
                    fileNames.append(file.filename)
                    
                    let localDir = NSTemporaryDirectory()
                    let localPath = localDir.stringByAppendingString(file.filename)
                    
                    let thumbPath = localPath.stringByAppendingString("_THUMB")
                    restClient.loadThumbnail(file.path, ofSize: "xs", intoPath: thumbPath)
                }
            }
            if metadata.contents.count > 1 {
                navigationItem.title = String(format: "%ld Photos", metadata.contents.count)
            } else {
                navigationItem.title = String(format: "%ld Photo", metadata.contents.count)
            }
            NSNotificationCenter.defaultCenter().postNotificationName("DBTableViewReloadDataNotification", object: nil)
        } else {
            navigationItem.title = "No Photos"
        }
    }
    
    func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        NSLog("Error loading metadata: %@", error)
    }
    
    func restClient(client: DBRestClient!, loadedFile destPath: String!, contentType: String!, metadata: DBMetadata!) {
        NSLog("File loaded into path: %@", destPath)
        
        let image = UIImage(contentsOfFile: destPath)
        
        var dict = myContents[metadata.filename] as! [String: AnyObject]
        dict["image"] = image
        
        myContents[metadata.filename] = dict
    }
    
    func restClient(client: DBRestClient!, loadFileFailedWithError error: NSError!) {
        NSLog("There was an error loading the file: %@", error)
    }
    
    func restClient(client: DBRestClient!, loadedThumbnail destPath: String!, metadata: DBMetadata!) {
        NSLog("Thumbnail loaded into path: %@", destPath)
        
        let image = UIImage(contentsOfFile: destPath)
        
        var dict = myContents[metadata.filename] as! [String: AnyObject]
        dict["thumb"] = image
        
        myContents[metadata.filename] = dict
        
        NSNotificationCenter.defaultCenter().postNotificationName("DBTableViewReloadDataNotification", object: nil)
    }
    
    func restClient(client: DBRestClient!, loadThumbnailFailedWithError error: NSError!) {
        NSLog("There was an error loading the thumbnail: %@", error)
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
