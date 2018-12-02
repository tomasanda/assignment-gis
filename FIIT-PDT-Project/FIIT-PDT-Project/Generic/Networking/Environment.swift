//
//  Environment.swift
//  Skunkaga
//
//  Created by Tomas Anda on 20/06/2017.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import Foundation

enum EnvironmentType: String {
    case development = " Develop "
    case production = ""
}

struct Host {
    let url:String
}

class Environment {
    
    var host: Host
    var urlScheme: String
    var type: EnvironmentType

    fileprivate static var _currentEnv: Environment?
    public static var current: Environment {
        assert(_currentEnv != nil, "Current environment is not set. Call Environment.setup first!")
        return _currentEnv!
    }

    private init(type: EnvironmentType) {
        
        self.type = type

//        let mainURL = "http://192.168.100.34:5000"
        let mainURL = "http://10.62.12.214:5000"
//        let mainURL = "http://localhost:5000"

        switch type {
        case .development:
            self.host = Host(url: mainURL)
            self.urlScheme = "sk.FIIT.FIIT-PDT-Project"

        case .production:
            self.host = Host(url: mainURL)
            self.urlScheme = "sk.FIIT.FIIT-PDT-Project"
        }
    }
    
    class func setup(type: EnvironmentType) {
        _currentEnv = Environment(type: type)
    }
    
}
