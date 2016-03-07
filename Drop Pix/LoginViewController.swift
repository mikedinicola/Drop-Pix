//
//  ViewController.swift
//  Drop Pix
//
//  Created by Mike DiNicola on 3/5/16.
//  Copyright © 2016 Mike DiNicola. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "segueToNavController", name: "DBLinkedSuccessfullyNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if DBSession.sharedSession().isLinked() == true {
            segueToNavController()
        } else {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.signInButton.alpha = 1.0
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Custom Methods
    
    @IBAction func signInButtonTouchUpInside(sender: AnyObject) {
        
        if DBSession.sharedSession().isLinked() == false {
            DBSession.sharedSession().linkFromController(self)
        }
    }
    
    // MARK: - Navigation
    
    func segueToNavController() {
        performSegueWithIdentifier("LoginVCToNavControllerModalSegue", sender: nil)
    }
    
    @IBAction func unwindToLoginVC (segue : UIStoryboardSegue) {
        NSLog("%@", segue.identifier!)
        
        self.signInButton.alpha = 1.0
    }
}

