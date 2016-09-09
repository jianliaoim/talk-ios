//
//  JLVerificationViewModel.swift
//  Talk
//
//  Created by 史丹青 on 8/28/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class JLVerificationViewModel: RVMViewModel {
    
    var isRightUI: Bool
    var phoneNumber: String!
    var verificationCode: String!
    var randomCode: String!
    var password: String = ""
    let resetActionString = "resetpassword"
    var isEmail: Bool = false
    var validUid: String?
    
    override init() {
        isRightUI = true
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

extension JLVerificationViewModel {
    
    func signin() -> RACSignal {
        let param: Dictionary<String, String> = ["randomCode":randomCode, "verifyCode":verificationCode]
        let client = TBLoginSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(kAccountBaseURLString + kMobileSignInPath, parameters: param, success: {(task:NSURLSessionDataTask!, response) -> Void in
                    let responseDict = response as! NSDictionary
                    print("============responseUserInfo=========")
                    print(responseDict)
                    if let accessToken = responseDict.valueForKey("accountToken") as? String {
                        JLAccountHelper.setAccessToken(accessToken)
                    }
                    subscriber.sendNext(responseDict["wasNew"])
                    subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func sendVerifyCode(action:String) -> RACSignal {
        var param: [String: String]
        var urlPath = kMobileSendVerifyCodePath
        if action == resetActionString {
            if isEmail {
                param = ["emailAddress": phoneNumber, "action": action]
                urlPath = kEmailSendVerifyCodePath
            } else {
                if let validUid = validUid {
                    param = ["phoneNumber": phoneNumber, "action": action,"uid": validUid]
                } else {
                    param = ["phoneNumber": phoneNumber, "action": action]
                }
            }
        } else {
            param = ["phoneNumber": phoneNumber, "action": action,"password": password]
        }
        print("params:\(param)")
        let client = TBLoginSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(urlPath, parameters: param, success: { (task:NSURLSessionDataTask!, response) -> Void in
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
