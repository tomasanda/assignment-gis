//
//  GeomCollectionDto.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 24/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import SwiftyJSON

public struct GeomCollectionDto {

    var geomCollection: [Geom] = []

    public init(json: JSON) {

        for geom in json {
            let geomJSON = geom.1

            let geomDto = GeomDto(json: geomJSON[0])
            let geomObj = GeomConverter.convert(dto: geomDto)

            if let newGeom = geomObj {
                geomCollection.append(newGeom)
            }

        }
        
    }
}
