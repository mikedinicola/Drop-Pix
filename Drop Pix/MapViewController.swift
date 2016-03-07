//
//  SettingsViewController.swift
//  Drop Pix
//
//  Created by Mike DiNicola on 3/5/16.
//  Copyright © 2016 Mike DiNicola. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate  {

    var _tabBarController: TabBarController!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _tabBarController = tabBarController as! TabBarController
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if _tabBarController.myContents != nil {
            for name in _tabBarController.fileNames {
                let dict = _tabBarController.myContents[name]!
                
                if let latitude = dict["latitude"] as? CLLocationDegrees {
                    let longitude = dict["longitude"] as! CLLocationDegrees
                    
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                    pointAnnotation.title = name.componentsSeparatedByString(", ").first
                    
                    mapView.addAnnotation(pointAnnotation)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
