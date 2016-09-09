//
//  JLNewCodeViewController.swift
//  Talk
//
//  Created by Suric on 15/11/5.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

class JLNewCodeViewController: UIViewController {
    
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var isEmail: Bool = true
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Set New Password", comment: "Set New Password")
        newPasswordField.placeholder = NSLocalizedString("New password", comment: "New password")
        newPasswordField.tintColor = UIColor.jl_redColor()
        confirmField.placeholder = NSLocalizedString("Confirm password", comment: "Confirm password")
        confirmField.tintColor = UIColor.jl_redColor()
        confirmButton.setTitle(NSLocalizedString("Sure", comment: "Sure"), forState: .Normal)
        confirmButton.backgroundColor = UIColor.jl_redColor()
        
        let inset = CGRectMake(0, 0, 20, 50)
        let newPasswordLeftView = UIView(frame: inset)
        newPasswordField.leftView = newPasswordLeftView
        newPasswordField.leftViewMode = UITextFieldViewMode.Always
        let confirmLeftView = UIView(frame: inset)
        confirmField.leftView = confirmLeftView
        confirmField.leftViewMode = UITextFieldViewMode.Always
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        newPasswordField.becomeFirstResponder()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: IBActions
    
    @IBAction func tapGestureAction(sender: AnyObject) {
        newPasswordField.resignFirstResponder()
        confirmField.resignFirstResponder()
    }
    
    
    @IBAction func confirmAction(sender: AnyObject) {
        if newPasswordField.text != confirmField.text {
            SVProgressHUD.showWithStatus(NSLocalizedString("Not same passWord", comment: "Not same passWord"))
            return
        }
        
        var resetPath: String
        if isEmail {
            resetPath = KEmailResetPasswordpath
        } else {
            resetPath = KMobileResetPasswordpath
        }
        let paras = ["newPassword": newPasswordField.text!]
        TBLoginSessionManager.sharedManager().POST(resetPath, parameters: paras, success: { (task: NSURLSessionDataTask!, responseObject) -> Void in
            print(responseObject)
            SVProgressHUD.dismiss()
            self.chooseTeam(responseObject)
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                TBUtility.showMessageInError(error)
        })
    }
    
    //MARK: Private methods
    
    func textFieldTextDidChange() {
        if newPasswordField.text?.characters.count < 6 || confirmField.text?.characters.count < 6  {
            confirmButton.enabled = false
            confirmButton.alpha = 0.5
        } else {
            confirmButton.enabled = true
            confirmButton.alpha = 1.0
        }
    }
    
    func chooseTeam(responseObject: AnyObject) {
        let responseDict = responseObject as! NSDictionary
        if let accessToken = responseDict["accountToken"] as? String {
            JLAccountHelper.setAccessToken(accessToken)
        }
        let chooseTeamVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseTeamViewController") as! ChooseTeamViewController
        self.navigationController?.pushViewController(chooseTeamVC, animated: true)
    }
}

// MARK: UITextFieldDelegate

extension JLNewCodeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == newPasswordField {
            confirmField.becomeFirstResponder()
        } else {
            confirmAction(confirmButton)
        }
        
        return true
    }
}
