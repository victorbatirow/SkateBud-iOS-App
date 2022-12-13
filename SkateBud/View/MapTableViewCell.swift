//
//  MapTableViewCell.swift
//  SkateBud
//
//  Created by Victor on 2022-12-02.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapIcon: UIImageView!
    
    var controller: DetailViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapIcon.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc func showMap() {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_MAP) as! MapViewController
        mapVC.users = [controller.user]
        
        controller.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    func configure(location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        self.mapView.setRegion(region, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
