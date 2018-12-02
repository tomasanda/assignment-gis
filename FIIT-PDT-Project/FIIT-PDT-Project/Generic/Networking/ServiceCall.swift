//
//  ServiceCall.swift
//  Mealur
//
//  Created by Tomas Anda on 04/01/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import Alamofire

public struct ServiceCall {
    public var requestMethod: HTTPMethod!
    public var requestParams: [String : Any]?
    public var requestUrl: String!
    public var encoding: ParameterEncoding
    public var mimeType: String?
    public var filename: String?
    public var info: String?
    
    init(requestMethod: HTTPMethod, requestParams: [String : Any]?, requestUrl: String, encoding: ParameterEncoding, info: String? = nil) {
        self.requestMethod = requestMethod
        self.requestParams = requestParams
        self.requestUrl = requestUrl
        self.encoding = encoding
        self.info = info
    }
    
}
