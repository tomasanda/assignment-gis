//
//  C5ViewController.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 29/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyJSON

class C5ViewController: UIViewController {

    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var showC5Button: UIButton!

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
        clearButton.addTarget(self, action: #selector(handleClearButton), for: .touchUpInside)
        showC5Button.addTarget(self, action: #selector(handleShowC5Button), for: .touchUpInside)
    }

    @objc func handleAddButton() {
//        getAllBikeTrails()
        //        getAllRivers() -> lot of data
    }

    @objc func handleClearButton() {
        clearMap()
    }

    @objc func handleShowC5Button() {
        getC5Heatmap()
    }

    func clearMap() {

        guard let style = self.mapView.style else { return }

        if let layer = style.layer(withIdentifier: "heamappoints") {
            style.removeLayer(layer)
        }

        if let source = style.source(withIdentifier: "heamappoints") as? MGLShapeSource {
            style.removeSource(source)
        }

    }

    func getC5Heatmap() {

        let mapWorker = MapWorker()

        mapWorker.getHeatmapData(completion: { resGeoJson in

            if let geoJ = resGeoJson {

                if let geoJson: Data = try? geoJ[0][0].rawData() {
                    // Add our GeoJSON data to the map as an MGLGeoJSONSource.
                    // We can then reference this data from an MGLStyleLayer.

                    // MGLMapView.style is optional, so you must guard against it not being set.
                    guard let style = self.mapView.style else { return }

                    guard let shapeFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) else {
                        fatalError("Could not generate MGLShape")
                    }

                    // If there's already a heamappoints on the map, do nothing
                    if let _ = self.mapView.style?.source(withIdentifier: "heamappoints") as? MGLShapeSource {
                        return
                    } else {

                        let source = MGLShapeSource(identifier: "heamappoints", shape: shapeFromGeoJSON, options: nil)
                        style.addSource(source)

                        // Create a heatmap layer.
                        let heatmapLayer = MGLHeatmapStyleLayer(identifier: "heamappoints", source: source)

                        // Adjust the color of the heatmap based on the point density.
                        let colorDictionary: [NSNumber: UIColor] = [
                            0.0: .clear,
                            0.01: .white,
                            0.15: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0),
                            0.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
                            1: .yellow
                        ]
                        heatmapLayer.heatmapColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($heatmapDensity, 'linear', nil, %@)", colorDictionary)

                        // Heatmap weight measures how much a single data point impacts the layer's appearance.
                        heatmapLayer.heatmapWeight = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)",
                                                                  [0: 0,
                                                                   1: 1])

                        // Heatmap intensity multiplies the heatmap weight based on zoom level.
                        heatmapLayer.heatmapIntensity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                                     [0: 1,
                                                                      1: 1])
                        heatmapLayer.heatmapRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                                  [0: 4,
                                                                   4: 5])

                        // The heatmap layer should be visible up to zoom level 9.
                        //                    heatmapLayer.heatmapOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0.75, %@)", [0: 0.75, 9: 0])
                        style.addLayer(heatmapLayer)

                        //                        Add a circle layer to represent the points at higher zoom levels.
                        //                        let circleLayer = MGLCircleStyleLayer(identifier: "circle-layer", source: source)
                        //
                        //                        let magnitudeDictionary: [NSNumber: UIColor] = [
                        //                            0: .white,
                        //                            0.5: .yellow,
                        //                            2.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
                        //                            5: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0)
                        //                        ]
                        //                        circleLayer.circleColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)", magnitudeDictionary)
                        //
                        //                        // The heatmap layer will have an opacity of 0.75 up to zoom level 9, when the opacity becomes 0.
                        //                        circleLayer.circleOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0, %@)", [0: 0, 9: 0.75])
                        //                        circleLayer.circleRadius = NSExpression(forConstantValue: 20)
                        //                        style.addLayer(circleLayer)
                    }

                }

            }

        })

    }

}


extension C5ViewController: MGLMapViewDelegate {

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
