//
//  JLVerificationViewController.swift
//  Talk
//
//  Created by 史丹青 on 8/28/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

enum VerificationType {
    case signUp
    case retriveCode
}

class JLVerificationViewController: UIViewController {
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var code1: UILabel!
    @IBOutlet weak var code2: UILabel!
    @IBOutlet weak var code3: UILabel!
    @IBOutlet weak var code4: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    
    var timer: NSTimer?
    let viewModel = JLVerificationViewModel()
    var seconds = 60
    var type: VerificationType = .signUp
    var isEmail: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        bindingTextfieldWithCodeLabel()
        if type != VerificationType.signUp {
            self.sendVerification()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        verificationCodeTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        verificationCodeTextField.resignFirstResponder()
        if let runingTimer = timer {
            runingTimer.invalidate()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Naviagtion
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowNewCode" {
            let newCodeVC = segue.destinationViewController as! JLNewCodeViewController
            newCodeVC.isEmail = isEmail;
        }
    }
}

// MARK: UI Layout

extension JLVerificationViewController {
    
    func commonInit() {
        verificationCodeTextField.delegate = self
        title = NSLocalizedString("Enter Verification", comment: "Enter Verification")
        nextButton.enabled = false
        nextButton.alpha = 0.5
        nextButton.setTitle(NSLocalizedString("Sure", comment: "Sure"), forState: .Normal)
        nextButton.backgroundColor = UIColor.jl_redColor()
        setSendAgainButton()
    }
    
    func sendVerification() {
        var action: String
        switch type {
        case .signUp:
            action = "signup"
        case .retriveCode:
            action = "resetpassword"
        }
        viewModel.isEmail = isEmail
        viewModel.sendVerifyCode(action).subscribeNext({ [unowned self] (x) -> Void in
            let randomCode = x as? String
            self.viewModel.randomCode = randomCode
            }, error: { (error: NSError!) -> Void in
                TBUtility.showMessageInError(error)
                self.resetSendVerifycode()
        })
    }
    
    func setSendAgainButton() {
        resendButton.setTitleColor(UIColor.tb_grayColor(), forState: .Normal)
        resendButton.setTitle(NSString(format: NSLocalizedString("Send again (%d)", comment: "Send again (%d)"), 60) as String , forState: UIControlState.Normal)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFireMethod:", userInfo: nil, repeats: true)
    }
    
    func timerFireMethod(theTimer: NSTimer) {
        if seconds == 1 {
            resetSendVerifycode()
        } else {
            resendButton.enabled = false
            resendButton.setTitleColor(UIColor.tb_grayColor(), forState: UIControlState.Normal)
            seconds -= 1
            resendButton.setTitle(NSString(format: NSLocalizedString("Send again (%d)", comment: "Send again (%d)"), seconds) as String , forState: UIControlState.Normal)
        }
    }
    
    func resetSendVerifycode() {
        timer!.invalidate()
        seconds = 60
        resendButton.setTitle(NSLocalizedString("Send again", comment: "Send again"), forState: UIControlState.Normal)
        resendButton.enabled = true
        resendButton.setTitleColor(UIColor.jl_redColor(), forState: .Normal)
    }
}

// MARK: User Interaction

extension JLVerificationViewController {
    
    @IBAction func clickResendButton(sender: UIButton) {
        viewModel.validUid = nil
        self.setSendAgainButton()
        self.sendVerification()
    }
    
    @IBAction func clickNextButton(sender: UIButton) {
        switch type {
        case .signUp:
            self.signUp()
        case .retriveCode:
            self.verificationForRetriveCode()
        }
    }
    
    func signUp() {
        showLoading(true)
        let paras = ["phoneNumber": viewModel.phoneNumber!, "password": viewModel.password, "randomCode": viewModel.randomCode, "verifyCode": verificationCodeTextField.text!]
        TBLoginSessionManager.sharedManager().POST(kMobileSignUpPath, parameters: paras, success: { (task: NSURLSessionDataTask!, responseObject) -> Void in
            print(responseObject)
            self.showLoading(false)
            TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionRegisterSuccess, label: kAnalyticsLabelWithPhone, value: nil)
            TBUtility.endTimingEventWithAction(kAnalyticsTimingRegisterDuration)

            let responseDict = responseObject as! NSDictionary
            if let accessToken = responseDict["accountToken"] as? String {
                JLAccountHelper.setAccessToken(accessToken)
            }
            
            if let userId = responseDict["_id"] as? String {
                JLAccountHelper.setCurrentUserKey(userId)
            }
            
            self.performSegueWithIdentifier("ShowCompleteUserInfo", sender: self)
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                self.showLoading(false)
                TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionRegisterError, label: kAnalyticsLabelWithPhone, value: nil)
                TBUtility.showMessageInError(error)
        })
    }
    
    func verificationForRetriveCode() {
        showLoading(true)
        let paras: NSDictionary
        var urlPath: String
        if isEmail {
            paras = ["randomCode": viewModel.randomCode, "verifyCode": verificationCodeTextField.text!]
            urlPath = kEmailCheckVerifyCodePath
        } else {
            paras = ["randomCode": viewModel.randomCode, "verifyCode": verificationCodeTextField.text!, "action": viewModel.resetActionString]
            urlPath = kMobileCheckVerifyCodePath
        }
        TBLoginSessionManager.sharedManager().POST(urlPath, parameters: paras, success: { (task: NSURLSessionDataTask!, responseObject) -> Void in
            print(responseObject)
            self.showLoading(false)
            
            let responseDict = responseObject as! NSDictionary
            if let accessToken = responseDict["accountToken"] as? String {
                JLAccountHelper.setAccessToken(accessToken)
            }
            self.performSegueWithIdentifier("ShowNewCode", sender: self)
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                self.showLoading(false)
                TBUtility.showMessageInError(error)
        })
    }
    
    func showLoading(show: Bool) {
        if show {
            nextButton.enabled = false
            nextButton.alpha = 0.5
            nextButton.setTitle("", forState: .Normal)
            loadingIndicatorView.startAnimating()
        } else {
            nextButton.enabled = true
            nextButton.alpha = 1.0
            nextButton.setTitle(NSLocalizedString("Sure", comment: "Sure"), forState: .Normal)
            loadingIndicatorView.stopAnimating()
        }
    }
    
    func textFieldTextDidChange() {
        if verificationCodeTextField.text?.characters.count == 4 {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        } else {
            nextButton.enabled = false
            nextButton.alpha = 0.5
        }
    }
}

// MARK: Binding

extension JLVerificationViewController {
    
    func bindingTextfieldWithCodeLabel() {
        self.code1.text = " "
        self.code2.text = " "
        self.code3.text = " "
        self.code4.text = " "
        verificationCodeTextField.rac_textSignal().subscribeNext{ (x:AnyObject!) -> Void in
            self.viewModel.verificationCode = x as? String
            var codeArray = [" "," "," "," "]
            var index = 0
            for temp in self.viewModel.verificationCode.characters {
                codeArray[index] = String(temp)
                index += 1
            }
            self.code1.text = codeArray[0]
            self.code2.text = codeArray[1]
            self.code3.text = codeArray[2]
            self.code4.text = codeArray[3]
        }
    }
    
}

// MARK: UITextFieldDelegate

extension JLVerificationViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text! + string).characters.count > 4) {
            return false
        }
        return true
    }
    
}
