//
//  UserAnnotation.swift
//  SkateBud
//
//  Created by Victor on 2022-11-29.
//

import Foundation
import MapKit

class UserAnnotation: MKPointAnnotation {
    var uid : String?
    var age: Int?
    var profileImage: UIImage?
    var experience: String?
}
