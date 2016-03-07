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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadAnnotations", name: "DBLoadAnnotationsNotification", object: nil)
        
        _tabBarController = tabBarController as! TabBarController
        
        loadAnnotations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    
    func loadAnnotations() {
        
        if _tabBarController.myContents != nil {
            for name in _tabBarController.fileNames {
                let dict = _tabBarController.myContents[name]!
                
                if let latitude = dict["latitude"] as? CLLocationDegrees {
                    let longitude = dict["longitude"] as! CLLocationDegrees
                    
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                    pointAnnotation.title = name
                    
                    mapView.addAnnotation(pointAnnotation)
                }
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        }
        
        annotationView?.frame = CGRectMake(0, 0, 44, 44)
        
        let dict = _tabBarController.myContents[annotation.title!!]!
        
        if let image = dict["thumb"] as? UIImage {
            let imageView = UIImageView(frame: annotationView!.frame)
            
            imageView.layer.cornerRadius = 5
            imageView.clipsToBounds = true
            
            imageView.image = image
            imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            
            annotationView?.addSubview(imageView)
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let dict = _tabBarController.myContents[view.annotation!.title!!] as! [String: AnyObject]
        
        if dict["thumb"] != nil {
            if _tabBarController.imageForSharingView != nil {
                
                let timer = NSTimer(timeInterval: 0.5, target: self, selector: "animateImageForSharingViewTimerCallback:", userInfo: ["dict": dict], repeats: false)
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
                
            } else {
                
                _tabBarController.animateImageForSharingView(dict)
            }
        }
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
