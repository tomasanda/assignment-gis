//
//  GeomConverter.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 24/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import Foundation

public class GeomConverter {

    public static func convert(dto: GeomDto) -> Geom? {

        return Geom(geomType: GeomType(rawValue: dto.geomType ?? ""),
                    coordinates: dto.coordinates)

    }
}
