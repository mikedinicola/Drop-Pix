//
//  TabBarController.swift
//  Drop Pix
//
//  Created by Mike DiNicola on 3/5/16.
//  Copyright © 2016 Mike DiNicola. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var picButton: UIButton?
    
    let tabBarHeight: CGFloat = 49
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0...2 {
            tabBar.items![i].setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)
            tabBar.items![i].titlePositionAdjustment = UIOffsetMake(0, -tabBarHeight/3);
        }
        
        picButton = UIButton(type: .System)
        picButton!.frame = CGRectMake(view.frame.size.width/3*1, 0, view.frame.size.width/3, tabBarHeight)
        picButton!.backgroundColor = .darkGrayColor()
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
    
    func picButtonTouchUpInside() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .Camera
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        
        // Upload photo to Dropbox
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
