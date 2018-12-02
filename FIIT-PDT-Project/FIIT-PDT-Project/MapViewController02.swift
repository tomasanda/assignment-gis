//
//  MapViewController.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 03/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyJSON
import GEOSwift
//import GEOSwiftMapboxGL

class MapViewController: UIViewController {

    var mapView: MGLMapView!

    @IBOutlet weak var testButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "mapbox://styles/mapbox/streets-v10")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 42.9162900002009, longitude: -73.7147929994514), zoomLevel: 9, animated: false)
        view.addSubview(mapView)
        view.bringSubviewToFront(testButton)


    }

    func drawPolyline() {
        // Parsing GeoJSON can be CPU intensive, do it on a background thread

        DispatchQueue.global(qos: .background).async(execute: {
            // Get the path for example.geojson in the app's bundle
            //            let jsonPath = Bundle.main.path(forResource: "example", ofType: "geojson")
            //            let url = URL(fileURLWithPath: jsonPath!)

            do {
                // Convert the file contents to a shape collection feature object
                //                let data = try Data(contentsOf: url)


                //                guard let url = URL(string: "http://192.168.2.1/test1") else {return} // -> works on physical device
                guard let url = URL(string: "http://127.0.0.1:5000/test2") else {return}
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let dataResponse = data,
                        error == nil else {
                            print(error?.localizedDescription ?? "Response Error")
                            return }
                    do{



                        ////////////

                        //                        guard let jsonObject = (try? JSONSerialization.jsonObject(with: dataResponse, options: [])) else {
                        //                            return
                        //                        }
                        //
                        //                        let featureCollection = GEOJSONFeatureCollection<GEOJSONLocationCoordinate>(json: jsonObject as! [String : Any])!
                        //
                        //                        // Access Foreign members
                        //                        let layerName = featureCollection["layerName"] as? String
                        //
                        //                        for feature in featureCollection.features {
                        //
                        //                            // Feature Properties
                        //                            let name = feature.properties["name"] as? String
                        //
                        //                            // Bounding Box
                        //                            let boundingBox = feature.boundingBox
                        //
                        //                            // Geometry
                        //                            let geometry = feature.geometry
                        //
                        //                            switch geometry {
                        //                            case .point(let coordinate):
                        //                                print("Found coordinate: \(coordinate)")
                        //                            case .polygon(let polygon):
                        //                                print("Found Polygon: \(polygon)")
                        //                            default:
                        //                                print("Found other geometry")
                        //                            }
                        //                        }

                        ///////////

                        let jsonResponse01 = try JSONSerialization.jsonObject(
                            with: dataResponse,
                            options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary

                        //here dataResponse received from a network request
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                            dataResponse, options: []) as? NSDictionary

                        let jsonResponse02 = try JSONSerialization.jsonObject(with:
                            dataResponse, options: [])

                        //                        if let s = jsonResponse02[0] as JSON {
                        //                            print(s)
                        //                        }

                        print(jsonResponse) //Response result

                        let coordinates = [
                            CLLocationCoordinate2D(latitude: 42.9162900002009, longitude: -73.7147929994514),
                            CLLocationCoordinate2D(latitude: 41.650086192867, longitude: -70.5443874377139)
                        ]
                        let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))

                        DispatchQueue.main.async(execute: {
                            // Unowned reference to self to prevent retain cycle
                            [unowned self] in
//                            self.mapView.addAnnotation(polyline)
                        })

                        //                        let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))


                        //                        MGLShapeCollectionFeature = try MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))

                        //                        if let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count)) {
                        //                            // Optionally set the title of the polyline, which can be used for:
                        //                            //  - Callout view
                        //                            //  - Object identification
                        //                            polyline.title = polyline.attributes["name"] as? String
                        //
                        //                            // Add the annotation on the main thread
                        //                            DispatchQueue.main.async(execute: {
                        //                                // Unowned reference to self to prevent retain cycle
                        //                                [unowned self] in
                        //                                self.mapView.addAnnotation(polyline)
                        //                            })
                        //                        }



                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                }
                task.resume()


                //                guard let shapeCollectionFeature = try MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature else {
                //                    fatalError("Could not cast to specified MGLShapeCollectionFeature")
                //                }
                //
                //                if let polyline = shapeCollectionFeature.shapes.first as? MGLPolylineFeature {
                //                    // Optionally set the title of the polyline, which can be used for:
                //                    //  - Callout view
                //                    //  - Object identification
                //                    polyline.title = polyline.attributes["name"] as? String
                //
                //                    // Add the annotation on the main thread
                //                    DispatchQueue.main.async(execute: {
                //                        // Unowned reference to self to prevent retain cycle
                //                        [unowned self] in
                //                        self.mapView.addAnnotation(polyline)
                //                    })
                //                }
            } catch {
                print("GeoJSON parsing failed")
            }

        })

    }

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }

    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 2.0
    }

    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        if (annotation.title == "Crema to Council Crest" && annotation is MGLPolyline) {
            // Mapbox cyan
            return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
        } else {
            return .red
        }
    }

    @IBAction func testButtonTap(_ sender: Any) {

        drawPolyline()


        //        guard let url = URL(string: "http://127.0.0.1:5000/test1") else {return}
        //        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        //            guard let dataResponse = data,
        //                error == nil else {
        //                    print(error?.localizedDescription ?? "Response Error")
        //                    return }
        //            do{
        //                //here dataResponse received from a network request
        //                let jsonResponse = try JSONSerialization.jsonObject(with:
        //                    dataResponse, options: [])
        //                print(jsonResponse) //Response result
        //
        //                guard let jsonObject = (try? JSONSerialization.jsonObject(with: dataResponse, options: [])) as? [String: Any] else {
        //                    return
        //                }
        //
        //                let featureCollection = GEOJSONFeatureCollection<GEOJSONLocationCoordinate>(json: jsonObject)!
        //
        //                // Access Foreign members
        //                let layerName = featureCollection["layerName"] as? String
        //
        //                for feature in featureCollection.features {
        //
        //                    // Feature Properties
        //                    let name = feature.properties["name"] as? String
        //
        //                    // Bounding Box
        //                    let boundingBox = feature.boundingBox
        //
        //                    // Geometry
        //                    let geometry = feature.geometry
        //
        //                    switch geometry {
        //                    case .point(let coordinate):
        //                        print("Found coordinate: \(coordinate)")
        //                    case .polygon(let polygon):
        //                        print("Found Polygon: \(polygon)")
        //                    default:
        //                        print("Found other geometry")
        //                    }
        //                }
        //
        //            } catch let parsingError {
        //                print("Error", parsingError)
        //            }
        //        }
        //        task.resume()


        let mapWorker = MapWorker()

        mapWorker.getTestJSON(completion: { result in
            print("getTestJSON result: ", result)
            if let geoJSON = result  {

                

//                print(geoJSON[0])
//                (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? [String: Any]

                if let encryptedData: Data = try? geoJSON[0][0].rawData() {


                    let features = try? Features.fromGeoJSON(encryptedData) as! [Feature]
                    print(features)
//                    print(features??[0] as Any)
//                    print(features??[0].geometries)
//                    if let geom = features??[0].geometries {
//                        print(geom)
//                        print(geom[0])
//                        if let g = geom[0] as? LineString {
//                            print(g)
//                            print(g.points)
//                        }
//                    }

//                    var coordinates: [CLLocationCoordinate2D] = []

                    let coordinates = [
                        CLLocationCoordinate2D(latitude: 42.9162900002009, longitude: -73.7147929994514),
                        CLLocationCoordinate2D(latitude: 41.650086192867, longitude: -70.5443874377139)
                    ]

                    for feature in features! {
                        if let geom = feature.geometries {

                            // get line string from geom
                            if let g = geom.first as? LineString {

                                // loop through all points
                                for point in g.points {
//                                    print(point.x)
//                                    print(point.y)

//                                    coordinates.append(CLLocationCoordinate2D(latitude: point.y, longitude: point.x))

                                }
                            }
                        }
                    }

                    let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))

                    self.mapView.addAnnotation(polyline)

//                    DispatchQueue.main.async(execute: {
//                        // Unowned reference to self to prevent retain cycle
//                        [unowned self] in
//                        self.mapView.addAnnotation(polyline)
//                    })


//                    if let features = try? Features.fromGeoJSON(geoJSONURL),
//                        let italy = features?.first?.geometries?.first as? MultiPolygon {
//                        //: ### Topological operations:
//                        //:
//                        print(italy)
////                        italy.buffer(width: 1)
////                        italy.boundary()
////                        italy.centroid()
////                        italy.convexHull()
////                        italy.envelope()
////                        italy.envelope()?.difference(italy)
////                        italy.pointOnSurface()
////                        italy.intersection(geometry2!)
////                        italy.difference(geometry2!)
////                        italy.union(geometry2!)
//                    }

//                    let LineString = Geometry.cre
//                    let shape2 = polygon.mapboxShape() // Will return a MGLPolygon

//                    if let italy = features.first?.geometries?.first as? LineString {
//                        print(italy)
//                    }

//                    if let f = features {
//                        for feature in f {
//                            if let geo = feature.first?.geometries?.first as? MGLPolyline {
//                                self.mapView.addAnnotation(geo)
//                            }
//                        }
//                    }




//                    if let polyline = features as? MGLPolylineFeature {
//                        // Optionally set the title of the polyline, which can be used for:
//                        //  - Callout view
//                        //  - Object identification
//                        polyline.title = polyline.attributes["name"] as? String
//
//                        // Add the annotation on the main thread
//                        DispatchQueue.main.async(execute: {
//                            // Unowned reference to self to prevent retain cycle
//                            [unowned self] in
//                            self.mapView.addAnnotation(polyline)
//                        })
//                    }

//                    NSLog(NSString(data: encryptedData, encoding: NSUTF8StringEncoding)!)
//                    guard let jsonObject = (try? JSONSerialization.jsonObject(with: encryptedData as Data, options: [])) as? [String: Any] else {
//                        return
//                    }
//
//                    print(jsonObject)
//
//                    let featureCollection = GEOJSONFeatureCollection<GEOJSONLocationCoordinate>(json: jsonObject)!
//
//                    // Access Foreign members
//                    let layerName = featureCollection["layerName"] as? String
//
//                    for feature in featureCollection.features {
//
//                        // Feature Properties
//                        let name = feature.properties["name"] as? String
//
//                        // Bounding Box
//                        let boundingBox = feature.boundingBox
//
//                        // Geometry
//                        let geometry = feature.geometry
//
//                        switch geometry {
//                        case .point(let coordinate):
//                            print("Found coordinate: \(coordinate)")
//                        case .polygon(let polygon):
//                            print("Found Polygon: \(polygon)")
//                        default:
//                            print("Found other geometry")
//                        }
//                    }


                }


//                self.drawPolyline(geoJSON: rd)
            }
        })
    }



}



