//
//  BindAccountViewModel.swift
//  Talk
//
//  Created by 史丹青 on 9/8/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class BindAccountViewModel: RVMViewModel {
    
    var countryCode: String
    var phoneNumber: String
    var finalPhoneNumber: String {
        get {
            if countryCode == "+86" {
                return phoneNumber
            } else {
                return countryCode + phoneNumber
            }
        }
    }
    var verificationCode:String!
    var randomCode:String!
    var bindCode:String?
    var loginCode:String?
    
    var hasBindMobile: Bool
    var showPhoneMobile: String
    var hasBindEmail: Bool
    var showEmail: String
    var hasBindTeambition: Bool
    var showTeambitionAccount: String
    var wantUnbindTeambition: Bool
    var needForceBindMobile: Bool
    var needForceBindEmail: Bool
    var needForceBindTeambition: Bool
    var isEmail:Bool = false
    var validUid: String!
    
    override init() {
        countryCode = "+86"
        phoneNumber = ""
        hasBindMobile = false
        hasBindEmail = false
        hasBindTeambition = false
        showPhoneMobile = "unbind"
        showEmail = "unbind"
        showTeambitionAccount = "unbind"
        wantUnbindTeambition = false
        needForceBindMobile = false
        needForceBindEmail = false
        needForceBindTeambition = false
        super.init()
        didBecomeActiveSignal.subscribeNext { (x:AnyObject?) -> Void in
            print("view appear")
        }
        didBecomeInactiveSignal.subscribeNext { (x:AnyObject?) -> Void in
            print("view disappear")
        }
    }
}

// MARK: Network

extension BindAccountViewModel {
    
    func checkBindStatus() -> RACSignal {
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.GET(kAccountBaseURLString + kCheckAllBindAccountsPath, parameters: nil, success: { (task, response) -> Void in
                let responseArray = response as! NSArray
                for accountInfo in responseArray {
                    let accountDic = accountInfo as! NSDictionary
                    print(accountDic)
                    if (accountDic["login"] as! String) == "mobile" {
                        self.hasBindMobile = true
                        self.showPhoneMobile = accountDic["phoneNumber"] as! String
                    } else if (accountDic["login"] as! String) == "email" {
                        self.hasBindEmail = true
                        self.showEmail = accountDic["emailAddress"] as! String
                    } else if (accountDic["login"] as! String) == "teambition" {
                        self.hasBindTeambition = true
                        self.showTeambitionAccount = accountDic["showname"] as! String
                    }
                }
                print(self.showPhoneMobile)
                print(self.showEmail)
                print(self.showTeambitionAccount)
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task, error:NSError!) -> Void in
                subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func sendVerifyCode() -> RACSignal {
        let param: Dictionary<String, String>
        let verifyCodeURLString: String
        if isEmail {
            verifyCodeURLString = kEmailSendVerifyCodePath
            param = ["emailAddress": phoneNumber, "action": "bind"]
        } else {
            verifyCodeURLString = kMobileSendVerifyCodePath
            param = ["phoneNumber": finalPhoneNumber, "uid": validUid]
        }
        
        let client = TBLoginSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(verifyCodeURLString, parameters: param, success: { [unowned self] (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as? NSDictionary
                self.randomCode = responseDict?.valueForKey("randomCode") as? String
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func bindMobileOrEmail() -> RACSignal {
        let param: Dictionary<String, String> = ["randomCode":randomCode, "verifyCode":verificationCode]
        let client = TBHTTPSessionManager.sharedManager()
        print(param)
        let bindURLString: String
        if isEmail {
            bindURLString = kAccountBaseURLString + kEmailBindPath
        } else {
            bindURLString = kAccountBaseURLString + kMobileBindPath
        }
        
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(bindURLString, parameters: param, success: { [unowned self] (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as! NSDictionary
                if let accessToken = responseDict["accountToken"] as? String {
                    JLAccountHelper.setAccessToken(accessToken)
                }
                self.syncUserInfo()
                if self.isEmail {
                    self.hasBindEmail = true
                    self.showEmail = responseDict["emailAddress"] as! String
                } else {
                    self.hasBindMobile = true
                    self.showPhoneMobile = responseDict["showname"] as! String
                }
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func changeMobileOrEmail() -> RACSignal {
        let param: Dictionary<String, String> = ["randomCode":randomCode, "verifyCode":verificationCode]
        let changeBindURLString: String
        if isEmail {
            changeBindURLString = kAccountBaseURLString + kEmailChangePath
        } else {
            changeBindURLString = kAccountBaseURLString + kMobileChangePath
        }
        
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(changeBindURLString, parameters: param, success: { [unowned self] (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as! NSDictionary
                
                if let accessToken = responseDict["accountToken"] as? String {
                    JLAccountHelper.setAccessToken(accessToken)
                }
                self.syncUserInfo()
                if self.isEmail {
                    self.hasBindEmail = true
                    self.showEmail = responseDict["emailAddress"] as! String
                } else {
                    self.hasBindMobile = true
                    self.showPhoneMobile = responseDict["showname"] as! String
                }
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func unbindMobile() -> RACSignal {
        let param: Dictionary<String, String> = ["phoneNumber":phoneNumber]
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(kAccountBaseURLString + kMobileUnbindPath, parameters: param, success: { (task:NSURLSessionDataTask!, response) -> Void in
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func forceBindMobileOrEmail() -> RACSignal {
        let param: Dictionary<String, String> = ["bindCode":bindCode!]
        let forceBindURLString: String
        if isEmail {
            forceBindURLString = kAccountBaseURLString + kEmailForceBindPath
        } else {
            forceBindURLString = kAccountBaseURLString + kMobileForceBindPath
        }
        
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(forceBindURLString, parameters: param, success: { [unowned self] (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as! NSDictionary
                
                if let accessToken = responseDict.valueForKey("accountToken") as? String {
                    JLAccountHelper.setAccessToken(accessToken)
                }
                self.syncUserInfo()
                if self.isEmail {
                    self.hasBindEmail = true
                    self.showEmail = responseDict["emailAddress"] as! String
                } else {
                    self.hasBindMobile = true
                    self.showPhoneMobile = responseDict["showname"] as! String
                }
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func bindWithTeambitionCode() ->RACSignal {
        let param: Dictionary<String, String> = ["code":loginCode!]
        print("========code:\(loginCode)==========")
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(kAccountBaseURLString + kBindTeambitionPath, parameters: param, success: { [unowned self] (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as! NSDictionary
                print(responseDict)
                
                if let accessToken = responseDict.valueForKey("accountToken") as? String {
                    JLAccountHelper.setAccessToken(accessToken)
                }
                self.syncUserInfo()
                self.hasBindTeambition = true
                self.showTeambitionAccount = responseDict["showname"] as! String
                subscriber.sendNext(responseDict["wasNew"])
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func forceBindWithTeambitionAccount() ->RACSignal {
        let param: Dictionary<String, String> = ["bindCode":bindCode!]
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(kAccountBaseURLString + kForceBindTeambitionPath, parameters: param, success: { [unowned self] (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as! NSDictionary
                
                if let accessToken = responseDict.valueForKey("accountToken") as? String {
                    JLAccountHelper.setAccessToken(accessToken)
                }
                self.syncUserInfo()
                self.hasBindTeambition = true
                self.showTeambitionAccount = responseDict["showname"] as! String
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func unbindTeambitionAccount() ->RACSignal {
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            let client = TBHTTPSessionManager.sharedManager()
            client.POST(kAccountBaseURLString + kUnbindTeambitionPath, parameters: nil, success: { [unowned self] (task:NSURLSessionDataTask!, response) -> Void in
                self.hasBindTeambition = false
                self.showTeambitionAccount = "unbind"
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        })
    }
    
    func syncUserInfo() {
        let client = TBHTTPSessionManager.sharedManager()
        client.GET(kMeInfoURLString, parameters: nil, success: { (task, response) -> Void in
            let responseDict = response as! NSDictionary
            JLAccountHelper.updateUserDataWithResponse(responseDict as [NSObject : AnyObject])
            }) { (task, error:NSError!) -> Void in
            print(error)
        }
    }
}
