//
//  JLLoginViewModel.swift
//  Talk
//
//  Created by 史丹青 on 8/28/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit
import Foundation

class JLLoginViewModel: RVMViewModel {
    
    var isRightUI:Bool
    var isChinesePhone:Bool
    var phoneNumber:String
    var countryCode:String
    var finalPhoneNumber: String {
        get {
            if isChinesePhone {
                return phoneNumber
            } else {
                return countryCode+phoneNumber
            }
        }
    }
    
    override init() {
        isRightUI = true
        isChinesePhone = true
        phoneNumber = ""
        countryCode = "+86"
        super.init()
        didBecomeActiveSignal.subscribeNext { (x:AnyObject?) -> Void in
            NSLog("view appear")
        }
        didBecomeInactiveSignal.subscribeNext { (x:AnyObject?) -> Void in
            NSLog("view disappear")
        }
    }
}

// MARK: Network 

extension JLLoginViewModel {
    
    func sendVerifyCode() -> RACSignal {
        let param: Dictionary<String, String> = ["phoneNumber":finalPhoneNumber]
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            
            client.POST(kAccountBaseURLString + kMobileSendVerifyCodePath, parameters: param, success: { (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as? NSDictionary
                let randomCode = responseDict?.valueForKey("randomCode") as? String
                subscriber.sendNext(randomCode)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
}

// MARK: Check Phone Number

extension String {
    
    func checkChineseTelNumber() -> Bool {
        let pattern = "^1[3578]\\d{9}"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluateWithObject(self)
    }
    
    func checkInternationalTelNumber() -> Bool {
        let pattern = "[0-9]{1,4}-[0-9]{3,11}"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluateWithObject(self)
    }
    
}
