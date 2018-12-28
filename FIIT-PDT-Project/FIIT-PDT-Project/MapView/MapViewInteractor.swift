//
//  MapViewInteractor.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 24/10/2018.
//  Copyright (c) 2018 FIIT-PDT. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MapViewBusinessLogic
{
    func doSomething(request: MapView.Something.Request)
}

protocol MapViewDataStore
{
    //var name: String { get set }
}

class MapViewInteractor: MapViewBusinessLogic, MapViewDataStore
{
    var presenter: MapViewPresentationLogic?
    var worker: MapViewWorker?
    //var name: String = ""

    // MARK: Do something

    func doSomething(request: MapView.Something.Request)
    {
        worker = MapViewWorker()
        worker?.doSomeWork()

        let response = MapView.Something.Response()
        presenter?.presentSomething(response: response)
    }
}