//
//  MapViewRouter.swift
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

@objc protocol MapViewRoutingLogic
{
  //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol MapViewDataPassing
{
  var dataStore: MapViewDataStore? { get }
}

class MapViewRouter: NSObject, MapViewRoutingLogic, MapViewDataPassing
{
  weak var viewController: MapViewViewController?
  var dataStore: MapViewDataStore?
  
  // MARK: Routing
  
  //func routeToSomewhere(segue: UIStoryboardSegue?)
  //{
  //  if let segue = segue {
  //    let destinationVC = segue.destination as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //  } else {
  //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //    navigateToSomewhere(source: viewController!, destination: destinationVC)
  //  }
  //}

  // MARK: Navigation
  
  //func navigateToSomewhere(source: MapViewViewController, destination: SomewhereViewController)
  //{
  //  source.show(destination, sender: nil)
  //}
  
  // MARK: Passing data
  
  //func passDataToSomewhere(source: MapViewDataStore, destination: inout SomewhereDataStore)
  //{
  //  destination.name = source.name
  //}
}