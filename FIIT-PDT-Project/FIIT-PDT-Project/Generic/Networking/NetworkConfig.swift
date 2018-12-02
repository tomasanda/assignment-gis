//
//  NetworkConfig.swift
//  Mealur
//
//  Created by Tomáš Anda on 14/02/2017.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

public enum ResponseStatusCode {
    
    case responseStatusOk                          //Call Ok
    case responseStatusAuthError(Int)              //Communication with server was successful, but authentication error received (http 401 or 403)
    case responseStatusApplicationError(Int)       //Communication with server was successful, but application error received
    case responseStatusBusinessError               //Communication with server was successful, but business error received
    case responseStatusCommunicationError(Int)     //Communication with server was unsuccessful
    case responseStatusNoData
    
    
    static func ==(lhs: ResponseStatusCode, rhs: ResponseStatusCode) -> Bool {
        switch (lhs, rhs) {
        case (.responseStatusOk, .responseStatusOk):
            return true
        case (.responseStatusBusinessError, .responseStatusBusinessError):
            return true
        case (.responseStatusNoData, .responseStatusNoData):
            return true
        default:
            return false
        }
    }
    
    static func !=(lhs: ResponseStatusCode, rhs: ResponseStatusCode) -> Bool {
        return !(lhs == rhs)
    }
    
    static func ===(lhs: ResponseStatusCode, rhs: ResponseStatusCode) -> Bool {
        switch (lhs, rhs) {
        case (.responseStatusOk, .responseStatusOk):
            return true
        case (.responseStatusCommunicationError(let code1), .responseStatusCommunicationError(let code2)):
            return code1 == code2
        case (.responseStatusAuthError(let code1), .responseStatusAuthError(let code2)):
            return code1 == code2
        case (.responseStatusApplicationError(let code1), .responseStatusApplicationError(let code2)):
            return code1 == code2
        case (.responseStatusBusinessError, .responseStatusBusinessError):
            return true
        case (.responseStatusNoData, .responseStatusNoData):
            return true
        default:
            return false
        }
    }
    
}

