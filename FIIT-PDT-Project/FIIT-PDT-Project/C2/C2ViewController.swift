//
//  C2ViewController.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 29/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyJSON
import GEOSwift

// MGLPointAnnotation subclass
class StationPointAnnotation: MGLPointAnnotation {}
class PrisonPointAnnotation: MGLPointAnnotation {}
class C2PointsAnnotation: MGLPointAnnotation {}

class C2ViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var showC2Button: UIButton!

    var prisonTownTextField: UITextField?
    var stationsNumberTextField: UITextField?

    var mapView = MGLMapView()
    var prisonAnnotations = [PrisonPointAnnotation]()
    var stationAnnotations = [StationPointAnnotation]()
    var c2Annotations = [C2PointsAnnotation]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        addMap()
        setupButtons()
    }

    func setupButtons() {
        addButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(handleClearButton), for: .touchUpInside)
        showC2Button.addTarget(self, action: #selector(handleShowC2Button), for: .touchUpInside)
    }

    func addMap() {
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 42.328192, longitude: -71.896136), zoomLevel: 7, animated: false)
        mapView.delegate = self
        view.insertSubview(mapView, at: 0)
    }

    @objc func handleAddButton() {
        showAllPrisons()
        showAllRailStations()
    }

    @objc func handleClearButton() {
        clearMap()
    }

    @objc func handleShowC2Button() {

        let alert = UIAlertController(title: "N nearest railway station to the prison", message: nil, preferredStyle: .alert)

        alert.addTextField(configurationHandler: prisonTextField)
        alert.addTextField(configurationHandler: stationsNumberTextField)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    func prisonTextField(textField: UITextField) {
        prisonTownTextField = textField
        prisonTownTextField?.placeholder = "Prison town"
    }

    func stationsNumberTextField(textField: UITextField) {
        stationsNumberTextField = textField
        stationsNumberTextField?.placeholder = "Number of nearest stations"
        stationsNumberTextField?.keyboardType = .numberPad
    }

    func okHandler(alert: UIAlertAction) {

        if let town = prisonTownTextField?.text, let statNum = stationsNumberTextField?.text {
            print("Selected prison town: \(town)")
            print("Selected number of nearest stations: \(statNum)")

            showC2(town: town, nearestStationsNumber: Int(statNum) ?? 3)
        }
    }

    func showC2(town: String, nearestStationsNumber: Int) {

        let mapWorker = MapWorker()

        mapWorker.getC2Points(prisonTown: town, stationsNumber: nearestStationsNumber, completion: { [weak self] resGeoJson in

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

                                            if let distance = property["f1"] as? Double {
                                                let point = C2PointsAnnotation()
                                                point.coordinate = cordinate
                                                point.title = "Distance: \((distance/1000).rounded(toPlaces: 2))km"
                                                strong_self.c2Annotations.append(point)
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

                strong_self.mapView.addAnnotations(strong_self.c2Annotations)
            }

        })

    }

    func showAllPrisons() {

        let mapWorker = MapWorker()

        mapWorker.getAllPrisonPoints(completion: { [weak self] resGeoJson in

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

                                            if let town = property["f1"] as? String, let name = property["f2"] as? String {
                                                let point = PrisonPointAnnotation()
                                                point.coordinate = cordinate
                                                point.title = "Town: \(town)"
                                                point.subtitle = "Prison name: \(name)"
                                                strong_self.prisonAnnotations.append(point)
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


                strong_self.mapView.addAnnotations(strong_self.prisonAnnotations)

            }

        })

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

                                            if let stations = property["f1"] as? String {
                                                let point = StationPointAnnotation()
                                                point.coordinate = cordinate
                                                point.title = "stations: \(stations)"
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
        self.mapView.removeAnnotations(prisonAnnotations)
        self.mapView.removeAnnotations(stationAnnotations)
        self.mapView.removeAnnotations(c2Annotations)
    }

}

extension C2ViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
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
                annotationView?.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
                annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                annotationView?.layer.borderWidth = 1.0
                annotationView?.layer.borderColor = UIColor.white.cgColor
                annotationView!.backgroundColor = UIColor(red: 0.03, green: 0.80, blue: 0.69, alpha: 1.0)
            }

            return annotationView
        } else if let _ = annotation as? PrisonPointAnnotation {
            // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
            let reuseIdentifier = "reusablePrisonDotView"

            // For better performance, always try to reuse existing annotations.
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

            // If there’s no reusable annotation view available, initialize a new one.
            if annotationView == nil {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
                annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                annotationView?.layer.borderWidth = 2.0
                annotationView?.layer.borderColor = UIColor.white.cgColor
                annotationView!.backgroundColor = UIColor(red: 0.80, green: 0.60, blue: 0.69, alpha: 1.0)
            }

            return annotationView
        } else if let _ = annotation as? C2PointsAnnotation {
            // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
            let reuseIdentifier = "reusableC2DotView"

            // For better performance, always try to reuse existing annotations.
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

            // If there’s no reusable annotation view available, initialize a new one.
            if annotationView == nil {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
                annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                annotationView?.layer.borderWidth = 2.0
                annotationView?.layer.borderColor = UIColor.white.cgColor
                annotationView!.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            }

            return annotationView
        }

        return nil
    }

}
