//
//  TBLoginViewController.swift
//  Talk
//
//  Created by 史丹青 on 9/8/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

@objc protocol TBLoginViewControllerDelegate {
    func finishLoginFromTeambition(codeString:String)
}

class TBLoginViewController: UIViewController {
    
    var delegate:TBLoginViewControllerDelegate?
    private var webView: UIWebView?
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Teambition"
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIBarButtonItemStyle.Done, target: self, action: "cancelVC")
        navigationItem.leftBarButtonItem = cancelButton
        let loadingItem: UIBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        navigationItem.rightBarButtonItem = loadingItem;
        self.navigationController?.navigationBar.barTintColor = UIColor.tb_blueColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: User Interaction

extension TBLoginViewController {
    
    func cancelVC() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
