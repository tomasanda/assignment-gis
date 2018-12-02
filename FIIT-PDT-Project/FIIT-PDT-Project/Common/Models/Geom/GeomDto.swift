//
//  GeomDto.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 24/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import SwiftyJSON
import CoreLocation

public struct GeomDto {

    var geomType: String?
    var coordinates: [CLLocationCoordinate2D] = []

    public init(json: JSON) {
        self.geomType = json["type"].string

        switch self.geomType {
        case GeomType.Point.rawValue:
            let latitude = json["coordinates"][1].doubleValue
            let longitude = json["coordinates"][0].doubleValue

            let cor = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            coordinates.append(cor)
        default:
            for coordinate in json["coordinates"] {
                let coordinateJSON = coordinate.1

                let latitude = coordinateJSON[1].doubleValue
                let longitude = coordinateJSON[0].doubleValue

                let cor = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                coordinates.append(cor)
            }
        }

    }
}
