//
//  Geom.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 24/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import CoreLocation

enum GeomType: String {
    case LineString = "LineString"
    case Point = "Point"
    case MultiPoint = "MultiPoint"
    case none = ""
}

public struct Geom {
    var geomType: GeomType?
    var coordinates: [CLLocationCoordinate2D] = []
}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
