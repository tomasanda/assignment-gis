//
//  MapWorker.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 21/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import Alamofire
import SwiftyJSON

class MapWorker {

    func getAllLandTypes(completion: @escaping (_ result: [String]?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/getalllandusetypes",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                var landUseTypes: [String] = []
                let jsonData = json[0][0]
                for landType in jsonData {
                    landUseTypes.append(landType.1.string ?? "")
                }

                completion(landUseTypes)
            } else {
                completion(nil)
            }
        })

    }

    func getC1LandUsePercentage(landUseType: String, completion: @escaping (_ result: Double?) -> Void = { _  in }) {

        let requestParams = ["landUseType": landUseType] as [String : Any]

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: requestParams,
            requestUrl: "/c1landuse",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                if let percentageResult = json[0][0].double {
                    completion(percentageResult)
                } else {
                    completion(nil)
                }

            } else {
                completion(nil)
            }
        })

    }

    func getTheShortestPathBetweenTwoStations(stationA: String, stationB: String, completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let requestParams = ["stationA": stationA,
                             "stationB" : stationB] as [String : Any]

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: requestParams,
            requestUrl: "/connBetweenTwoStations",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getTheShortestPathBetweenThreeStations(stationA: String, stationB: String, stationC: String, completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let requestParams = ["stationA": stationA,
                             "stationB" : stationB,
                             "stationC" : stationC,
                             ] as [String : Any]

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: requestParams,
            requestUrl: "/connBetweenThreeStations",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getHeatmapData(completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/hazardousmaterials",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getAllPrisonPoints(completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/getallprisonpoints",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getC2Points(prisonTown: String, stationsNumber: Int, completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let requestParams = ["prisonTown": prisonTown,
                             "stationsNumber" : stationsNumber
                             ] as [String : Any]

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: requestParams,
            requestUrl: "/c2points",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getAllRailWayStations(completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/getallrailwaystations",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getAllBikeTrails(completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/getallbiketrails",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getAllRivers(completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/getallrivers",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }

    func getC4Lines(completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/c4lines",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                completion(json)
            } else {
                completion(nil)
            }
        })

    }


    func getPointsGeomCollection(completion: @escaping (_ result: GeomCollection?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/test1",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                let geomCollectionDto = GeomCollectionDto(json: json)
                let geomCollection = GeomCollectionConverter.convert(dto: geomCollectionDto)

                completion(geomCollection)
            } else {
                completion(nil)
            }
        })

    }

    func getGeomCollection(completion: @escaping (_ result: GeomCollection?) -> Void = { _  in }) {

        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: nil,
            requestUrl: "/test1",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                let geomCollectionDto = GeomCollectionDto(json: json)
                let geomCollection = GeomCollectionConverter.convert(dto: geomCollectionDto)

                completion(geomCollection)
            } else {
                completion(nil)
            }
        })

    }

    func getTestJSON(completion: @escaping (_ result: JSON?) -> Void = { _  in }) {

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
//            } catch let parsingError {
//                print("Error", parsingError)
//            }
//        }
//        task.resume()

        let requestParams = ["param1": "From iOS",
                             "param2" : "MassBier"] as [String : Any]


        let serviceCall = ServiceCall(
            requestMethod: .get,
            requestParams: requestParams,
            requestUrl: "/test5",
            encoding: URLEncoding.default)

        NetworkServiceManager.sharedInstance.makeRequest(serviceCall, completion: { (responseCode, result) in
            if responseCode == .responseStatusOk {

                guard let json = result else {
                    return completion(nil)
                }

                let geomCollectionDto = GeomCollectionDto(json: json)
                let geomCollection = GeomCollectionConverter.convert(dto: geomCollectionDto)

                print("DEBUG")
//                print(json)
                completion(json)
            } else {
                completion(nil)
            }
        })

    }

}


