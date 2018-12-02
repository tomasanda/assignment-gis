//
//  ErrorHandleController.swift
//  Mealur
//
//  Created by Tomas Anda on 27/02/2017.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import UIKit

class ErrorHandleController {
    
    public static let shared = ErrorHandleController()
    
    var errorStatus: Int?
    var message: String?
    var title: String?
    
    func error(vc: UIViewController? = nil, title: String? = nil, message: String? = nil) {
        if errorStatus != nil || title != nil || message != nil || self.message != nil {
//            var titleToShow: String = ""
//            if message != nil {
//                self.message = message
//            }
//            if self.title != nil {
//                titleToShow = self.title!
//            } else if title != nil {
//                titleToShow = title!
//            } else {
//                switch errorStatus! {
//                case 400,401,402,403:
//                    titleToShow = "Auth error"
//                case 404:
//                    titleToShow = "Communication error"
//                case 422:
//                    titleToShow = "Application error"
//                case 500:
//                    titleToShow = "Business error"
//                default:
//                    titleToShow = "Other error"
//                }
//            }
//            UIAlertController.showInfo(vc: vc, title: titleToShow, message: self.message)
        }
        self.errorStatus = nil
        self.message = nil
        self.title = nil
    }
}

