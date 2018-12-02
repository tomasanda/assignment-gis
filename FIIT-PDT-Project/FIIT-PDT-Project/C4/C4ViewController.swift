//
//  C4ViewController.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 29/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyJSON
import GEOSwift

class C4ViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var showC4Button: UIButton!

    var mapView = MGLMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        setupButtons()
    }

    func addMap() {
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 42.328192, longitude: -71.896136), zoomLevel: 7, animated: false)
        mapView.delegate = self
        view.insertSubview(mapView, at: 0)
    }

    func setupButtons() {
        addButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(handleClearButton), for: .touchUpInside)
        showC4Button.addTarget(self, action: #selector(handleShowC4Button), for: .touchUpInside)
    }

    @objc func handleAddButton() {
        getAllBikeTrails()
//        getAllRivers() -> lot of data
    }

    @objc func handleClearButton() {
        clearMap()
    }

    @objc func handleShowC4Button() {
        getC4Lines()
    }

    func clearMap() {

        guard let style = self.mapView.style else { return }

        if let layer = style.layer(withIdentifier: "bikeTrails") {
            style.removeLayer(layer)
        }

        if let source = style.source(withIdentifier: "bikeTrails") as? MGLShapeSource {
            style.removeSource(source)
        }

        if let layer = style.layer(withIdentifier: "rivers") {
            style.removeLayer(layer)
        }

        if let source = style.source(withIdentifier: "rivers") as? MGLShapeSource {
            style.removeSource(source)
        }

        if let layer = style.layer(withIdentifier: "c4lines") {
            style.removeLayer(layer)
        }

        if let source = style.source(withIdentifier: "c4lines") as? MGLShapeSource {
            style.removeSource(source)
        }
        
    }

    func getAllBikeTrails() {

        let mapWorker = MapWorker()

        mapWorker.getAllBikeTrails(completion: { resGeoJson in

            if let geoJ = resGeoJson {

                if let geoJson: Data = try? geoJ[0][0].rawData() {
                    // Add our GeoJSON data to the map as an MGLGeoJSONSource.
                    // We can then reference this data from an MGLStyleLayer.

                    // MGLMapView.style is optional, so you must guard against it not being set.
                    guard let style = self.mapView.style else { return }

                    guard let shapeFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) else {
                        fatalError("Could not generate MGLShape")
                    }

                    // If there's already a route line on the map, do nothing
                    if let _ = style.source(withIdentifier: "bikeTrails") as? MGLShapeSource {
                        return
                    } else {
                        let source = MGLShapeSource(identifier: "bikeTrails", shape: shapeFromGeoJSON, options: nil)
                        style.addSource(source)

                        // Create new layer for the line.
                        let layer = MGLLineStyleLayer(identifier: "bikeTrails", source: source)

                        // Set the line join and cap to a rounded end.
                        layer.lineJoin = NSExpression(forConstantValue: "round")
                        layer.lineCap = NSExpression(forConstantValue: "round")

                        // Set the line color to a constant blue color.
                        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 255/255, green: 100/255, blue: 208/255, alpha: 1))

                        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
                        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                       [14: 4, 18: 20])

                        style.addLayer(layer)
                    }

                }


            }

        })

    }


    func getAllRivers() {

        let mapWorker = MapWorker()

        mapWorker.getAllRivers(completion: { resGeoJson in

            if let geoJ = resGeoJson {

                if let geoJson: Data = try? geoJ[0][0].rawData() {
                    // Add our GeoJSON data to the map as an MGLGeoJSONSource.
                    // We can then reference this data from an MGLStyleLayer.

                    // MGLMapView.style is optional, so you must guard against it not being set.
                    guard let style = self.mapView.style else { return }

                    guard let shapeFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) else {
                        fatalError("Could not generate MGLShape")
                    }

                    // If there's already a route line on the map, do nothing
                    if let _ = style.source(withIdentifier: "rivers") as? MGLShapeSource {
                        return
                    } else {
                        let source = MGLShapeSource(identifier: "rivers", shape: shapeFromGeoJSON, options: nil)
                        style.addSource(source)

                        // Create new layer for the line.
                        let layer = MGLLineStyleLayer(identifier: "rivers", source: source)

                        // Set the line join and cap to a rounded end.
                        layer.lineJoin = NSExpression(forConstantValue: "round")
                        layer.lineCap = NSExpression(forConstantValue: "round")

                        // Set the line color to a constant blue color.
                        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 80/255, green: 80/255, blue: 240/255, alpha: 1))

                        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
                        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                       [14: 4, 18: 20])

                        style.addLayer(layer)
                    }

                }


            }

        })

    }


    func getC4Lines() {

        let mapWorker = MapWorker()

        mapWorker.getC4Lines(completion: { resGeoJson in

            if let geoJ = resGeoJson {

                if let geoJson: Data = try? geoJ[0][0].rawData() {
                    // Add our GeoJSON data to the map as an MGLGeoJSONSource.
                    // We can then reference this data from an MGLStyleLayer.

                    // MGLMapView.style is optional, so you must guard against it not being set.
                    guard let style = self.mapView.style else { return }

                    guard let shapeFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) else {
                        fatalError("Could not generate MGLShape")
                    }

                    // If there's already a route line on the map, do nothing
                    if let _ = style.source(withIdentifier: "c4lines") as? MGLShapeSource {
                        return
                    } else {
                        let source = MGLShapeSource(identifier: "c4lines", shape: shapeFromGeoJSON, options: nil)
                        style.addSource(source)

                        // Create new layer for the line.
                        let layer = MGLLineStyleLayer(identifier: "c4lines", source: source)

                        // Set the line join and cap to a rounded end.
                        layer.lineJoin = NSExpression(forConstantValue: "round")
                        layer.lineCap = NSExpression(forConstantValue: "round")

                        // Set the line color to a constant blue color.
                        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 100/255, green: 255/255, blue: 100/255, alpha: 1))

                        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
                        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                       [14: 2, 18: 20])

                        style.addLayer(layer)
                    }

                }


            }

        })

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension C4ViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }

    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 2.0
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

}
