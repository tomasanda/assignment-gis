//
//  C3ViewController.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 29/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyJSON

class C3ViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var showC3Button: UIButton!

    var mapView = MGLMapView()
    var stationAnnotations = [StationPointAnnotation]()

    var stationATextField: UITextField?
    var stationBTextField: UITextField?
    var stationCTextField: UITextField?

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
        showC3Button.addTarget(self, action: #selector(handleShowC3Button), for: .touchUpInside)
    }

    @objc func handleAddButton() {
        showAllRailStations()
    }

    @objc func handleShowC3Button() {

        let alert = UIAlertController(title: "Shortest route from one station to another train", message: nil, preferredStyle: .alert)

        alert.addTextField(configurationHandler: stationATextField)
        alert.addTextField(configurationHandler: stationBTextField)
        alert.addTextField(configurationHandler: stationCTextField)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    func okHandler(alert: UIAlertAction) {

        if let stationA = stationATextField?.text, let stationB = stationBTextField?.text {
            print("Selected station A: \(stationA)")
            print("Selected station B: \(stationB)")

            if let stationC = stationCTextField?.text, !stationC.isEmpty {
                print("Selected station C: \(stationC)")
                getTheShortestPathForThreeStations(stationA: stationA, stationB: stationB, stationC: stationC)
            } else if !stationA.isEmpty && !stationB.isEmpty {
                getTheShortestPathForTwoStations(stationA: stationA, stationB: stationB)
            }

        }
    }

    func stationATextField(textField: UITextField) {
        stationATextField = textField
        stationATextField?.placeholder = "Station A"
    }

    func stationBTextField(textField: UITextField) {
        stationBTextField = textField
        stationBTextField?.placeholder = "Station B"
    }

    func stationCTextField(textField: UITextField) {
        stationCTextField = textField
        stationCTextField?.placeholder = "Optional - Station C"
    }

    @objc func handleClearButton() {
        clearMap()
    }

    func showAllRailStations() {

        let mapWorker = MapWorker()

        mapWorker.getAllRailWayStations(completion: { [weak self] resGeoJson in

            guard let strong_self = self else {
                return
            }

            if let geoJ = resGeoJson {

                do {
                    let jsonData = try geoJ[0][0].rawData()
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
                            if let personArray = jsonResult.value(forKey: "features") as? NSArray {
                                for (_, element) in personArray.enumerated() {
                                    if let element = element as? NSDictionary {

                                        if let property = element["properties"] as? NSDictionary,
                                            let geom = element["geometry"] as? NSDictionary, let coordinates = geom["coordinates"] as? NSArray

                                        {
                                            let lat = coordinates[1] as! Double
                                            let lng = coordinates[0] as! Double
                                            let cordinate = CLLocationCoordinate2DMake(lat, lng)

                                            if let stationName = property["f1"] as? String {
                                                let point = StationPointAnnotation()
                                                point.coordinate = cordinate
                                                point.title = "Station name: \(stationName)"
                                                strong_self.stationAnnotations.append(point)
                                            }

                                        }

                                    }
                                }
                            }
                        }
                    } catch let error as NSError {
                        print("Error: \(error)")
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }

                strong_self.mapView.addAnnotations(strong_self.stationAnnotations)

            }

        })

    }

    func clearMap() {
        self.mapView.removeAnnotations(stationAnnotations)

        guard let style = self.mapView.style else { return }

        if let layer = style.layer(withIdentifier: "shortestPathAB") {
            style.removeLayer(layer)
        }

        if let source = style.source(withIdentifier: "shortestPathAB") as? MGLShapeSource {
            style.removeSource(source)
        }

        if let layer = style.layer(withIdentifier: "shortestPathABC") {
            style.removeLayer(layer)
        }

        if let source = style.source(withIdentifier: "shortestPathABC") as? MGLShapeSource {
            style.removeSource(source)
        }

    }

    func getTheShortestPathForTwoStations(stationA: String, stationB: String) {

        let mapWorker = MapWorker()

        mapWorker.getTheShortestPathBetweenTwoStations(stationA: stationA, stationB: stationB, completion: { resGeoJson in
        //mapWorker.getTheShortestPathBetweenTwoStations(stationA: "springfield", stationB: "fitchburg", completion: { resGeoJson in

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
                    if let _ = style.source(withIdentifier: "shortestPathAB") as? MGLShapeSource {
                        return
                    } else {
                        let source = MGLShapeSource(identifier: "shortestPathAB", shape: shapeFromGeoJSON, options: nil)
                        style.addSource(source)

                        // Create new layer for the line.
                        let layer = MGLLineStyleLayer(identifier: "shortestPathAB", source: source)

                        // Set the line join and cap to a rounded end.
                        layer.lineJoin = NSExpression(forConstantValue: "round")
                        layer.lineCap = NSExpression(forConstantValue: "round")

                        // Set the line color to a constant blue color.
                        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 255/255, green: 100/255, blue: 208/255, alpha: 1))

                        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
                        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                       [14: 2, 18: 20])

                        style.addLayer(layer)
                    }

                    // We can also add a second layer that will draw a stroke around the original line.
//                    let casingLayer = MGLLineStyleLayer(identifier: "polyline-case", source: source)
//                    // Copy these attributes from the main line layer.
//                    casingLayer.lineJoin = layer.lineJoin
//                    casingLayer.lineCap = layer.lineCap
//                    // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
//                    casingLayer.lineGapWidth = layer.lineWidth
//                    // Stroke color slightly darker than the line color.
//                    casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 200/255, green: 80/255, blue: 171/255, alpha: 1))
//                    // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
//                    casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])

                    // Just for fun, let’s add another copy of the line with a dash pattern.
//                    let dashedLayer = MGLLineStyleLayer(identifier: "polyline-dash", source: source)
//                    dashedLayer.lineJoin = layer.lineJoin
//                    dashedLayer.lineCap = layer.lineCap
//                    dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
//                    dashedLayer.lineOpacity = NSExpression(forConstantValue: 0.5)
//                    dashedLayer.lineWidth = layer.lineWidth
//                    // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
//                    dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
//
//                    style.addLayer(layer)
                    //                    style.addLayer(dashedLayer)
                    //                    style.insertLayer(casingLayer, below: layer)
                }


            }

        })

    }

    func getTheShortestPathForThreeStations(stationA: String, stationB: String, stationC: String) {

        let mapWorker = MapWorker()

        mapWorker.getTheShortestPathBetweenThreeStations(
            stationA: stationA,
            stationB: stationB,
            stationC: stationC,
            completion: { resGeoJson in

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
                    if let _ = self.mapView.style?.source(withIdentifier: "shortestPathABC") as? MGLShapeSource {
                        return
                    } else {
                        let source = MGLShapeSource(identifier: "shortestPathABC", shape: shapeFromGeoJSON, options: nil)
                        style.addSource(source)

                        // Create new layer for the line.
                        let layer = MGLLineStyleLayer(identifier: "shortestPathABC", source: source)

                        // Set the line join and cap to a rounded end.
                        layer.lineJoin = NSExpression(forConstantValue: "round")
                        layer.lineCap = NSExpression(forConstantValue: "round")

                        // Set the line color to a constant blue color.
                        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 80/255, green: 15/255, blue: 15/255, alpha: 1))

                        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
                        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                       [14: 3, 18: 20])

                        style.addLayer(layer)
                    }

//                    // We can also add a second layer that will draw a stroke around the original line.
//                    let casingLayer = MGLLineStyleLayer(identifier: "polyline-case", source: source)
//                    // Copy these attributes from the main line layer.
//                    casingLayer.lineJoin = layer.lineJoin
//                    casingLayer.lineCap = layer.lineCap
//                    // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
//                    casingLayer.lineGapWidth = layer.lineWidth
//                    // Stroke color slightly darker than the line color.
//                    casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 41/255, green: 145/255, blue: 171/255, alpha: 1))
//                    // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
//                    casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])
//
//                    // Just for fun, let’s add another copy of the line with a dash pattern.
//                    let dashedLayer = MGLLineStyleLayer(identifier: "polyline-dash", source: source)
//                    dashedLayer.lineJoin = layer.lineJoin
//                    dashedLayer.lineCap = layer.lineCap
//                    dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
//                    dashedLayer.lineOpacity = NSExpression(forConstantValue: 0.5)
//                    dashedLayer.lineWidth = layer.lineWidth
//                    // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
//                    dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
//
//                    style.addLayer(layer)
//                    style.addLayer(dashedLayer)
//                    style.insertLayer(casingLayer, below: layer)
                }

            }

        })

    }

}

extension C3ViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {

    }

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

    // This delegate method is where you tell the map to load a view for a specific annotation based on the willUseImage property of the custom subclass.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {

        if let _ = annotation as? StationPointAnnotation {
            // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
            let reuseIdentifier = "reusableStationDotView"

            // For better performance, always try to reuse existing annotations.
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

            // If there’s no reusable annotation view available, initialize a new one.
            if annotationView == nil {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                annotationView?.layer.borderWidth = 1.0
                annotationView?.layer.borderColor = UIColor.white.cgColor
                annotationView!.backgroundColor = UIColor(red: 0.03, green: 0.80, blue: 0.69, alpha: 1.0)
            }

            return annotationView
        }

        return nil
    }

}
