//
//  C1ViewController.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 29/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import UIKit
import Mapbox
import SwiftyJSON
import GEOSwift

class C1ViewController: UIViewController {

    @IBOutlet weak var showC1Button: UIButton!

    var mapView = MGLMapView()

    var landUseTypes: [String] = []

    var selectedLandUseType = ""
    var percentageResult: Double = 0

    override func viewDidLoad()
    {
        super.viewDidLoad()
        addMap()
        setupButtons()

        let mapWorker = MapWorker()

        mapWorker.getAllLandTypes(completion: { result in
            if let landTypes = result {
                self.landUseTypes = landTypes
            }
        })
    }

    func setupButtons() {
        showC1Button.addTarget(self, action: #selector(handleShowC1Button), for: .touchUpInside)
    }

    func addMap() {
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 42.328192, longitude: -71.896136), zoomLevel: 7, animated: false)
        view.insertSubview(mapView, at: 0)
    }

    @objc func handleShowC1Button() {

        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)

        let editRadiusAlert = UIAlertController(title: "Choose land use type", message: "", preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")

        let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        editRadiusAlert.addAction(okAction)
        editRadiusAlert.addAction(cancelAction)

        self.present(editRadiusAlert, animated: true)
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }

    func okHandler(alert: UIAlertAction) {
        let mapWorker = MapWorker()

        mapWorker.getC1LandUsePercentage(landUseType: selectedLandUseType, completion: { [weak self] result in
            if let percentageResult = result {
                self?.showLandUseDetails(landUseType: self?.selectedLandUseType ?? "", coverPercentage: percentageResult)
            }
        })
    }

    func showLandUseDetails(landUseType: String, coverPercentage: Double) {
        let alert = UIAlertController(title: String(format: "Massachusetts has %.2f%% \(landUseType) land type coverage", coverPercentage), message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


}

extension C1ViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return landUseTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return landUseTypes[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedLandUseType = landUseTypes[row]
    }

}

