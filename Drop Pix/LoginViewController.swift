//
//  ViewController.swift
//  Drop Pix
//
//  Created by Mike DiNicola on 3/5/16.
//  Copyright © 2016 Mike DiNicola. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "segueToNavController", name: "DBLinkedSuccessfullyNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if DBSession.sharedSession().isLinked() == true {
            segueToNavController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInButtonTouchUpInside(sender: AnyObject) {
        
        if DBSession.sharedSession().isLinked() == false {
            DBSession.sharedSession().linkFromController(self)
        }
    }
    
    // MARK: Navigation
    
    func segueToNavController() {
        performSegueWithIdentifier("LoginVCToNavControllerModalSegue", sender: nil)
    }
}

