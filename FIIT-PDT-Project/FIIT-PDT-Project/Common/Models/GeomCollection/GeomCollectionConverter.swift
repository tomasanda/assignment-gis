//
//  GeomCollectionConverter.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 24/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import Foundation

public class GeomCollectionConverter {

    public static func convert(dto: GeomCollectionDto) -> GeomCollection? {

        return GeomCollection(geomCollection: dto.geomCollection)

    }
}
