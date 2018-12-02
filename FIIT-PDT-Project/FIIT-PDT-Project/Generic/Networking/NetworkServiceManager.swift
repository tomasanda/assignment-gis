//
//  NetworkServiceManager.swift
//  Mealur
//
//  Created by Tomáš Anda on 04/01/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import Alamofire
import SwiftyJSON

public class NetworkServiceManager: NSObject {
    
    static let sharedInstance = NetworkServiceManager()
    var header = ["Content-type": "application/json", "Accept": "application/json", "Accept-Language": "en-US", "Cache-Control" : "no-cache"]

    var headerMultipart = ["Content-Type": "multipart/form-data", "Accept": "application/json", "Accept-Language": "en-US", "Cache-Control" : "no-cache"]

    func makeRequest(_ serviceCall: ServiceCall, processedErrorCodes: Set<Int> = [401,403], vc: UIViewController? = nil, completion: @escaping (_ responseCode: ResponseStatusCode, _ result: JSON?) -> Void) {
        
        var processedErrorCodes = processedErrorCodes + [401,403]
       
        if Environment.current.type == .production {
            processedErrorCodes = processedErrorCodes + [500]
        }
        
        let requestUrl = Environment.current.host.url + serviceCall.requestUrl!

        Alamofire
            .request(requestUrl,
                     method: serviceCall.requestMethod,
                     parameters: serviceCall.requestParams,
                     encoding: serviceCall.encoding,
                     headers: header)
            .responseJSON { response in
                
                var statusCode: Int
                
                if response.response != nil {
                    statusCode = response.response!.statusCode
                } else {
                    statusCode = 501
                }
                
                if statusCode == 403, let data = response.data {
                    let json = JSON(data)
                    if json["message"].stringValue == "Error" {
                        statusCode = 422
                    }
                }

                if statusCode > 399, let data = response.data, !processedErrorCodes.contains(statusCode)  {
                    self.getErrorMessage(json: JSON(data), vc: vc)
                }
                
                switch statusCode {
                case 200...204:
                    if let json = try? JSON(data: response.data!) {
                        completion(.responseStatusOk, json)
                    } else {
                        completion(.responseStatusOk, nil)
                    }
                case 400,402:
                    completion(.responseStatusAuthError(statusCode), nil)
                case 401:
                    completion(.responseStatusAuthError(statusCode), nil)
                case 403:
                    completion(.responseStatusAuthError(statusCode), nil)
                case 404:
                    completion(.responseStatusApplicationError(statusCode), nil)
                case 405:
                    completion(.responseStatusApplicationError(statusCode), nil)
                case 422:
                    completion(.responseStatusApplicationError(statusCode), nil)
                case 500:
                    completion(.responseStatusBusinessError, nil)
                default:
                    completion(.responseStatusCommunicationError(statusCode), nil)
                }
        }
    }
    
    func getErrorMessage(json: JSON, vc: UIViewController? = nil) {
        if let title = json["message"].string, !title.isEmpty {
            var message = json["errors"].string
            if message == nil, let dictionary = json["errors"].dictionary {
                for (_, val) in dictionary {
                    if val.array != nil {
                        let errors = val.array!.map {$0.stringValue}
                        message = errors.joined(separator: "\n")
                    }
                }
            }
//            ErrorHandleController.shared.error(vc: vc, title: title.localized, message: message)
        }
    }
    
    func downloadImage(imageUrl: String?, completion: @escaping (_ result: UIImage?, _ url: String?) -> Void) {
        
        if imageUrl == nil {
            return completion(nil, nil)
        }
        
        if let url = URL(string: imageUrl!) {
        
            let session = URLSession(configuration: URLSessionConfiguration.default)
            session.dataTask(with: url, completionHandler: { data, response, error in
                guard let data = data, error == nil else {
                    return completion(nil, imageUrl!)
                }
                DispatchQueue.main.async {
                    completion(UIImage(data: data), imageUrl!)
                }
            }).resume()
            
        } else {
            completion(nil, imageUrl!)
        }

    }
    
    fileprivate func showErrorHUD(title:String, subtitle:String) {
        //showe only if online (if app is offline - do not spam user with error messages)
//        if ReachabilityManager.shared.isReachable {
//            HUDPlayer.shared.showErrorHUD(title: title, subTitle: subtitle)
//        }
    }
    
    func makeRequestMultipart(_ serviceCall: ServiceCall, processedErrorCodes: Set<Int> = [401,403], mimeType: String = "image/jpeg", filename: String = "avatar.jpg", completion: @escaping (_ responseCode: ResponseStatusCode, _ result: JSON?) -> Void) {
        
        var processedErrorCodes = processedErrorCodes + [401,403]
        
        if Environment.current.type == .production {
            processedErrorCodes = processedErrorCodes + [500]
        }

        let requestUrl = Environment.current.host.url + serviceCall.requestUrl

        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                for (key, value) in serviceCall.requestParams! {
                    switch key {
                    case "avatar", "image":
                        if value as? UIImage != nil {
                            MultipartFormData.append((value as! UIImage).jpegData(compressionQuality: 0.8)!, withName: key, fileName: filename, mimeType: mimeType)
                        }
                    default:
                        if value is Double {
                            MultipartFormData.append(("\(value)").data(using: String.Encoding.utf8)!, withName: key)
                        } else {
                            MultipartFormData.append((value as? String ?? "").data(using: String.Encoding.utf8)!, withName: key)
                        }
                    }
                }
        }, to: requestUrl,
           method: serviceCall.requestMethod,
           headers: headerMultipart,
           encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress { (progress) in
                    DispatchQueue.main.async() {
                        NotificationCenter.default.post(name: Notification.Name("uploadProgress"), object: (serviceCall.info ?? "",  Float(progress.fractionCompleted)))
                    }
                }
                upload.responseJSON { (response) in
                    print(response.result.value ?? "nil")
                    
                    var statusCode: Int
                    
                    if response.response != nil {
                        statusCode = response.response!.statusCode
                    } else {
                        statusCode = 501
                    }

                    if statusCode > 399 && response.data != nil && !processedErrorCodes.contains(statusCode) {
                        self.getErrorMessage(json: JSON(response.data!))
                    }

                    switch statusCode {
                    case 200...204:
                        if let json = try? JSON(data: response.data!) {
                            completion(.responseStatusOk, json)
                        } else {
                            completion(.responseStatusOk, nil)
                        }
                    case 401:
                        completion(.responseStatusAuthError(statusCode), nil)
                    case 403:
                        completion(.responseStatusAuthError(statusCode), nil)
                    case 400,402:
                        completion(.responseStatusAuthError(statusCode), nil)
                    case 404,405,422:
                        completion(.responseStatusApplicationError(statusCode), nil)
                    case 500:
                        completion(.responseStatusBusinessError, nil)
                    default:
                        completion(.responseStatusCommunicationError(statusCode), nil)
                    }

                }
            case .failure(let encodingError):
                print(encodingError)
                completion(.responseStatusNoData, nil)
            }
        })
    }
    
    
    
}

