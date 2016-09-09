//
//  JLCompleteUserInfoViewModel.swift
//  Talk
//
//  Created by 史丹青 on 8/28/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class JLCompleteUserInfoViewModel: RVMViewModel {
    
    var isRightUI:Bool
    var avatorImage = UIImage()
    var avatorImageData:NSData {
        get {
            return UIImageJPEGRepresentation(avatorImage, 0.5)!
        }
    }
    var avatorUrl:String?
   
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

extension JLCompleteUserInfoViewModel {
    
    func uploadUserAvator() -> RACSignal {
        let client = TBFileSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.POST(kUploadURLString, parameters: nil, constructingBodyWithBlock: { [unowned self] (formData:AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(self.avatorImageData, name: "file", fileName: "avatar.png", mimeType: "image/png")
                }, success: { (task:NSURLSessionDataTask!, response) -> Void in
                    let responseDict = response as? NSDictionary
                    self.avatorUrl = responseDict?.valueForKey("thumbnailUrl") as? String
                    subscriber.sendNext(nil)
                    subscriber.sendCompleted()
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    subscriber.sendError(error)
            })
            return nil
        });
    }
    
    func uploadUserAvatorUrl() -> RACSignal {
        let param: Dictionary<String, String> = ["avatarUrl":avatorUrl!]
        let client = TBHTTPSessionManager.sharedManager()
        let userId = NSUserDefaults.standardUserDefaults().valueForKey(kCurrentUserKey) as! String
        print("=========userId:\(userId)============")
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.PUT("users/\(userId)", parameters: param, success: { (task:NSURLSessionDataTask!, response) -> Void in
                let responseDict = response as! NSDictionary
                JLAccountHelper.updateUserDataWithResponse(responseDict as [NSObject : AnyObject])
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
            }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                print("error")
                subscriber.sendError(error)
            })
            return nil
        });
    }

    
    func getUserInfo() -> RACSignal {
        let client = TBHTTPSessionManager.sharedManager()
        return RACSignal.createSignal({ (subscriber:RACSubscriber!) -> RACDisposable! in
            client.GET(kMeInfoURLString, parameters: nil, success: { (task, response) -> Void in
                let responseDict = response as! NSDictionary
                JLAccountHelper.updateUserDataWithResponse(responseDict as [NSObject : AnyObject])
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                }, failure: { (task, error:NSError!) -> Void in
                subscriber.sendError(error)
            })
            return nil
        })
    }
    
}
