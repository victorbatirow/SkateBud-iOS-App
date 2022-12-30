//
//  MapViewController.swift
//  SkateBud
//
//  Created by Victor on 2022-11-28.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var users = [User]()
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        segmentControl.isHidden = true
        segmentControl.addTarget(self, action: #selector(showDirection(coordinate:)), for: UIControl.Event.valueChanged)
        addAnnotation()

        // Do any additional setup after loading the view.
    }
    
    @objc func showDirection(coordinate: CLLocationCoordinate2D) {
        switch segmentControl.selectedSegmentIndex {
        case 0: self.currentTransportType = .automobile
        case 1: self.currentTransportType = .walking
        default: break
        }
        print(coordinate)
        segmentControl.isHidden = false
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = currentTransportType
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { routeResponse, error in
            guard  let routeResponse = routeResponse else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            
            let route = routeResponse.routes[0]
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1) : UIColor.orange
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let coordinate = view.annotation?.coordinate {
            showDirection(coordinate: coordinate)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // hide navigation bar andtab bar when mapview opens
//        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func addAnnotation() {
        var nearByAnnotations: [MKAnnotation] = []
        for user in users {
            let location = CLLocation(latitude: Double(user.latitude)!, longitude: Double(user.longitude)!)
            let annotation = UserAnnotation()
            annotation.title = user.username
            if let age = user.age {
                annotation.subtitle = "age: \(age)"
            }
            if let experience = user.experience {
                annotation.experience = user.experience
            }
            annotation.coordinate = location.coordinate
            annotation.profileImage = user.profileImage
            nearByAnnotations.append(annotation)
        }
        self.mapView.showAnnotations(nearByAnnotations, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        var annotationView : MKAnnotationView?
        
        // reuse the annotation if possible
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "icon_skater_map")
        } else if let deqAno = mapView.dequeueReusableAnnotationView(withIdentifier:identifier) {
            annotationView = deqAno
            annotationView?.annotation = annotation
        } else {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annoView.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
            annotationView = annoView
        }
        
        if let annotationView = annotationView, let anno = annotation as? UserAnnotation {
            annotationView.canShowCallout = true
            
            let image = anno.profileImage
            let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            resizeRenderImageView.layer.cornerRadius = 25
            resizeRenderImageView.clipsToBounds = true
            resizeRenderImageView.contentMode = .scaleAspectFill
            resizeRenderImageView.image = image
            
            UIGraphicsBeginImageContextWithOptions(resizeRenderImageView.frame.size,false, 0.0)
            resizeRenderImageView.layer.render (in: UIGraphicsGetCurrentContext()!)
            let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            annotationView.image = thumbnail
            
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30 , height: 30)
            btn.setImage(UIImage(named: "icon_directions"), for: UIControl.State.normal)
            annotationView.rightCalloutAccessoryView = btn
            
            let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            if let experience = anno.experience {
                if experience == "Beginner" {
                    leftIconView.image = UIImage(named: "icon_beginner")
                } else if experience == "Intermediate" {
                    leftIconView.image = UIImage(named: "icon_intermediate")
                } else if experience == "Advanced" {
                    leftIconView.image = UIImage(named: "icon_advanced")
                }
            } else {
                leftIconView.image = UIImage (named: "icon_experience")
            }
            annotationView.leftCalloutAccessoryView = leftIconView
        }
        return annotationView
    }
}
