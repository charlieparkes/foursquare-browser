/*
 Charlie Mathews, 2016
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var map: MKMapView!
    var changeInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        //let panRec = UIPanGestureRecognizer(target: self, action: #selector(didDragMap))
        //panRec.delegate = self
        //map.addGestureRecognizer(panRec)
        
        outputToMap(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        map.removeAnnotations(map.annotations)
        outputToMap(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func outputToMap(animated : Bool) {
        changeInProgress = true
        if(venues.results.count > 0) {
            
            let loc = CLLocationCoordinate2D(latitude: venues.latitude, longitude: venues.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            let reg = MKCoordinateRegion(center: loc, span: span)
            map.setRegion(reg, animated: false)
            
            for v in venues.results {
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: v.lat, longitude: v.lng)
                pin.title = v.name
                
                if v.is_closed {
                    pin.subtitle = "CLOSED"
                } else {
                    pin.subtitle = "OPEN"
                }
                
                map.addAnnotation(pin)
            }
            
            map.showAnnotations(map.annotations, animated: animated)
        }
        changeInProgress = false
    }
    
    func loadObservers() {
        venues.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
    }
    
    func removeObservers() {
        venues.removeObserver(self, forKeyPath: "foundResults")
    }
    
    deinit {
        removeObservers()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "foundResults" && venues.foundResults == true {
            
            map.removeAnnotations(map.annotations)
            outputToMap(false)
            
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = MKPinAnnotationView()
        //check if user location
        if(annotation.isKindOfClass(MKUserLocation)) {
            return nil
        }
        //try to dismiss already open
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation:annotation,reuseIdentifier:"pin")
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            view.canShowCallout = true
        }
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier("mapShowDetail", sender: view)
        }
    }
    
    /*
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didDragMap(recog: UIGestureRecognizer) {
        if (recog.state == UIGestureRecognizerState.Ended) {
            if changeInProgress == true {
                return
            }
            print("1 map is pulling new results")
            let loc = map.centerCoordinate
            venues.clear()
            venues.get(loc.latitude, lng: loc.longitude)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if changeInProgress == true {
            return
        }
        print("2 map is pulling new results")
        let loc = map.centerCoordinate
        venues.clear()
        venues.get(loc.latitude, lng: loc.longitude)
    }
     */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}