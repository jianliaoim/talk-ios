//
//  JLWelcomeViewModel.swift
//  Talk
//
//  Created by 史丹青 on 9/22/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class JLWelcomeViewModel: RVMViewModel {
    
    var loginCode:String
    
    override init() {
        loginCode = ""
        super.init()
        didBecomeActiveSignal.subscribeNext { (x:AnyObject?) -> Void in
            NSLog("view appear")
        }
        didBecomeInactiveSignal.subscribeNext { (x:AnyObject?) -> Void in
            NSLog("view disappear")
        }
    }
    
    func loginWithTeambitionCode() ->RACSignal {
        let param: Dictionary<String, String> = ["code":loginCode]
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(kAccountBaseURLString + kLoginWithTeambitionPath, parameters: param, success: { (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as! NSDictionary
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
   
}
