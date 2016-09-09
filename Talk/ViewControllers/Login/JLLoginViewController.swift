//
//  JLLoginViewController.swift
//  Talk
//
//  Created by 史丹青 on 8/27/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class JLLoginViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var zoneCodeButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var changeChannelButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!  
    @IBOutlet weak var zoneCodeButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountFieldLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var onepasswordSigninButton: UIButton!
    
    let onepasswordURL = "https://jianliao.com/"
    let ShowRetrieveCodeSegue = "ShowRetrieveCode"
    let viewModel = JLLoginViewModel()
    var tintColor: UIColor = UIColor.jl_redColor()
    var isSignin: Bool = true
    var isEmail: Bool = true
    var keyboardIsShow: Bool = false
    var signTitle: String = NSLocalizedString("Sign in", comment: "Sign in")

    var DevicePhonePadKeyboardHeight: CGFloat?
    let accountInsetRect = CGRectMake(0, 0, 15, 50)
    let passwordInsetRect = CGRectMake(0, 0, 20, 50)
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        let zoneCodeBgImage = UIImage(named: "zoneCodeBg")?.imageWithRenderingMode(.AlwaysTemplate)
        zoneCodeButton.setBackgroundImage(zoneCodeBgImage, forState: .Normal)
        zoneCodeButton.tintColor = tintColor
        changeChannelButton.setTitleColor(tintColor, forState: .Normal)

        if isSignin {
            onepasswordSigninButton.hidden = !OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
            if !onepasswordSigninButton.hidden {
                accountField.rightView = UIView(frame: CGRectMake(0, 0, 44, 44))
                accountField.rightViewMode = UITextFieldViewMode.Always
            }
            signTitle = NSLocalizedString("Sign in", comment: "Sign in")
            privacyButton.setTitle(NSLocalizedString("Can not login", comment: "Can not login"), forState: UIControlState.Normal)
            changeChannelButton.setTitle(NSLocalizedString("Sign in with mobile", comment: "Sign in with mobile"), forState: .Normal)
        } else {
            onepasswordSigninButton.hidden = true
            signTitle = NSLocalizedString("Sign up", comment: "Sign up")
            let title = NSMutableAttributedString(string: NSLocalizedString("Conform the privacy", comment: "Conform the privacy"), attributes:[NSForegroundColorAttributeName: UIColor.tb_grayColor()])
            let items = NSAttributedString(string: NSLocalizedString("Terms of service", comment: "Terms of service"), attributes:[NSForegroundColorAttributeName: tintColor])
            title.appendAttributedString(items)
            privacyButton.setAttributedTitle(title, forState: UIControlState.Normal)
            changeChannelButton.setTitle(NSLocalizedString("Sign up with mobile", comment: "Sign up with mobile"), forState: .Normal)
        }
        self.title = signTitle
        
        accountField.tintColor = tintColor
        accountField.placeholder = NSLocalizedString("Input email", comment: "Input email")
        passwordField.placeholder = NSLocalizedString("Input password", comment: "Input password")
        let accountLeftView = UIView(frame: accountInsetRect)
        accountField.leftView = accountLeftView
        accountField.leftViewMode = UITextFieldViewMode.Always
        let passwordLeftView = UIView(frame: passwordInsetRect)
        passwordField.tintColor = tintColor
        passwordField.leftView = passwordLeftView
        passwordField.leftViewMode = UITextFieldViewMode.Always

        loginButton.setTitle(signTitle, forState: .Normal)
        loginButton.enabled = false
        loginButton.alpha = 0.5
        loginButton.backgroundColor = tintColor
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)

        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tapAction(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func changeCountryCode(sender: UIButton) {
        let countryCodeVC = SelectCountryToInputMobileNumberViewController()
        countryCodeVC.delegate = self
        let navVC = UINavigationController(rootViewController: countryCodeVC)
        presentViewController(navVC, animated: true, completion: nil)
    }
    
    @IBAction func changeLoginChannel(sender: AnyObject) {
        accountField.text = ""
        isEmail = !isEmail
        if isEmail {
            accountField.placeholder = NSLocalizedString("Input email", comment: "Input email")
            accountField.keyboardType = .Default
            accountField.reloadInputViews()
            
            zoneCodeButtonWidthConstraint.constant = 0
            accountFieldLeadingConstraint.constant = 50
            if isSignin {
                changeChannelButton.setTitle(NSLocalizedString("Sign in with mobile", comment: "Sign in with mobile"), forState: .Normal)
            } else {
                changeChannelButton.setTitle(NSLocalizedString("Sign up with mobile", comment: "Sign up with mobile"), forState: .Normal)
            }
        } else {
            accountField.placeholder = NSLocalizedString("Input mobile", comment: "Input mobile")
            accountField.keyboardType = .NumberPad
            accountField.reloadInputViews()
            
            zoneCodeButtonWidthConstraint.constant = 60
            accountFieldLeadingConstraint.constant = 105
            if isSignin {
                changeChannelButton.setTitle(NSLocalizedString("Sign in with email", comment: "Sign in with email"), forState: .Normal)
            } else {
                changeChannelButton.setTitle(NSLocalizedString("Sign up with email", comment: "Sign up with email"), forState: .Normal)
            }
        }

        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIViewAnimationOptions.LayoutSubviews, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:nil )
        }
    
    @IBAction func tapAction(sender: AnyObject) {
        accountField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @IBAction func clickNextButton(sender: UIButton) {
            login()
        }
    
    @IBAction func clickThePrivacyButton(sender: UIButton) {
        tapAction(self.privacyButton)
        if isSignin {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Reset with mobile", comment: "Reset with mobile"), style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier(self.ShowRetrieveCodeSegue, sender: false)
            }))
            actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Reset with email", comment: "Reset with email"), style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier(self.ShowRetrieveCodeSegue, sender: true)
            }))
            actionSheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel, handler: { (action) -> Void in
            }))
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        } else {
            let webvc = JLWebViewController()
            webvc.urlString = kPrivacyURLString;
            webvc.hideMoreItem = true
            webvc.title = NSLocalizedString("Terms of Service and Privacy Policy", comment: "Terms of Service and Privacy Policy")
            navigationController?.pushViewController(webvc, animated: true)
        }
    }
    
    @IBAction func findLoginFrom1Password(sender: UIButton) {
        OnePasswordExtension.sharedExtension().findLoginForURLString(onepasswordURL, forViewController: self, sender: sender) { [unowned self] (loginDictionary, error) -> Void in
            if (loginDictionary == nil) {
                return
            }
            if (loginDictionary!.count == 0) {
                if (error!.code != 0) {
                    NSLog("Error invoking 1Password App Extension for find login: \(error)")
                }
                return
            }
            self.accountField.text = loginDictionary!["username"] as? String
            self.passwordField.text = loginDictionary!["password"] as? String
            self.loginButton.enabled = true
            self.loginButton.alpha = 1.0
        }
    }
    
    //MARK: Private
    
    func login() {
        if !checkAccountAndPassword() {
            return
        }
        
        tapAction(self.loginButton)
        var paras: NSDictionary
        if isEmail {
            paras = ["emailAddress": accountField.text!, "password": passwordField.text!]
        } else {
            viewModel.phoneNumber = accountField.text!
            paras = ["phoneNumber": viewModel.finalPhoneNumber, "password": passwordField.text!]
        }
        showLoading(true)
        if isSignin {
            var signInPath: String
            if isEmail {
                signInPath = kEmailSignInPath
            } else {
                signInPath = kMobileSignInPath
            }
            let analyticLabel: String = self.isEmail ? kAnalyticsLabelWithEmail : kAnalyticsLabelWithPhone
            TBLoginSessionManager.sharedManager().POST(signInPath, parameters: paras, success: { (task: NSURLSessionDataTask!, responseObject) -> Void in
                TBUtility.endTimingEventWithAction(kAnalyticsTimingLoginDuration)
                TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionLoginSuccess, label: analyticLabel, value: nil)
                self.showLoading(false)
                self.chooseTeam(responseObject)
                }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                    TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionLoginError, label: analyticLabel, value: nil)
                    TBUtility.showMessageInError(error)
                    self.showLoading(false)
            })
        } else {
            if isEmail {
                if accountField.text!.isQQEmail() {
                    remindQQEmial(paras)
                } else {
                    registerEmailAccount(paras)
                }
            } else {
                performSegueWithIdentifier("ShowImageValidSegue", sender: nil)
            }
        }
    }
    
    func remindQQEmial(params: NSDictionary) {
        let alertController: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("QQ Email Remind", comment: "QQ Email Remind"), preferredStyle: .Alert)
        let editAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Back and Edit", comment: "Back and Edit"), style: .Default) { (action) -> Void in
            self.showLoading(false)
            self.accountField.becomeFirstResponder()
        };
        let continueAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Continue", comment: "Continue"), style: .Default) { (action) -> Void in
            self.registerEmailAccount(params)
        };
        alertController.addAction(editAction)
        alertController.addAction(continueAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.jl_redColor()
    }
    
    func registerEmailAccount(params: NSDictionary) {
        TBLoginSessionManager.sharedManager().POST(kEmailSignUpPath, parameters: params, success: { (task: NSURLSessionDataTask!, responseObject) -> Void in
            TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionRegisterSuccess, label: kAnalyticsLabelWithEmail, value: nil)
            TBUtility.endTimingEventWithAction(kAnalyticsTimingRegisterDuration)
            self.showLoading(false)
            self.chooseTeam(responseObject)
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                TBUtility.sendAnalyticsEventWithCategory(kAnalyticsCategoryLogin, action: kAnalyticsActionRegisterError, label: kAnalyticsLabelWithEmail, value: nil)
                TBUtility.showMessageInError(error)
                self.showLoading(false)
        })
    }
    
    func checkAccountAndPassword() -> Bool {
        let account = accountField.text
        
        var isRightStyle:Bool
        if isEmail {
            isRightStyle = TBUtility.checkEmail(account)
        } else {
            let isChineseNumber = TBUtility.checkChinaTelNumber(account)
            let isInternationalTelNumber = TBUtility.checkPhoneNumberWithString(account)
            isRightStyle = isChineseNumber || isInternationalTelNumber
        }
        
        if isRightStyle {
            return true
        } else {
            SVProgressHUD.showErrorWithStatus(NSLocalizedString("Please input right Style", comment: "Please input right Style"))
            return false
        }
    }
    
    func textFieldTextDidChange() {
        if accountField.text?.characters.count == 0 || passwordField.text?.characters.count < 6 {
            loginButton.enabled = false
            loginButton.alpha = 0.5
        } else {
            loginButton.enabled = true
            loginButton.alpha = 1.0
        }
    }
    
    func chooseTeam(responseObject: AnyObject) {
        let responseDict = responseObject as! NSDictionary
        if let accessToken = responseDict["accountToken"] as? String {
            JLAccountHelper.setAccessToken(accessToken)
        }
        if let userId = responseDict["_id"] as? String {
            JLAccountHelper.setCurrentUserKey(userId)
        }
        
        if isSignin {
            let chooseTeamVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseTeamViewController") as! ChooseTeamViewController
            self.navigationController?.pushViewController(chooseTeamVC, animated: true)
        } else {
            let completeInfoVC = self.storyboard?.instantiateViewControllerWithIdentifier("JLCompleteUserInfoViewController") as! JLCompleteUserInfoViewController
            self.navigationController?.pushViewController(completeInfoVC, animated: true)
        }
    }
    
    func showLoading(show: Bool) {
        if show {
            loginButton.enabled = false
            loginButton.alpha = 0.5
            loginButton.setTitle("", forState: .Normal)
            loadingIndicatorView.startAnimating()
        } else {
            loginButton.enabled = true
            loginButton.alpha = 1.0
            loginButton.setTitle(signTitle, forState: .Normal)
            loadingIndicatorView.stopAnimating()
        }
    }
    
    // MARK: Naviagtion
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EnterVerificationForSignUP" {
            let verificationVC = segue.destinationViewController as! JLVerificationViewController
            verificationVC.type = VerificationType.signUp;
            verificationVC.viewModel.phoneNumber = viewModel.finalPhoneNumber
            verificationVC.viewModel.password = passwordField.text!
            verificationVC.viewModel.randomCode = sender as! String
        } else if segue.identifier == "ShowImageValidSegue" {
            let imageValidVC = segue.destinationViewController as! JLImageValidController
            imageValidVC.delegate = self
        } else if segue.identifier == ShowRetrieveCodeSegue {
            let retrieveCodeVC = segue.destinationViewController as! JLRetrieveCodeViewController
            retrieveCodeVC.isEmail = sender as! Bool
        }
    }
    
}

// MARK: Keyboard

extension JLLoginViewController {
    
    func fetchKeyBoardHieght(notification:NSNotification) {
        let userInfo :[NSObject:AnyObject] = notification.userInfo!
        let userDic = userInfo as NSDictionary
        let keyboarFrame: AnyObject? = userDic.valueForKey(UIKeyboardFrameEndUserInfoKey)
        let frame = keyboarFrame?.CGRectValue
        let keyboardY = frame?.height
        if let height = keyboardY {
            DevicePhonePadKeyboardHeight = height
        }
    }
    
    func keyboardWillShow(notification:NSNotification){
        fetchKeyBoardHieght(notification)
        keyboardIsShow = true
        updateCenter()
    }
    
    func keyboardWillHide(notification:NSNotification){
        fetchKeyBoardHieght(notification)
        keyboardIsShow = false
        updateCenter()
    }
    
    func updateCenter() {
        var center: CGPoint
        var loginViewAlpha: CGFloat
        if keyboardIsShow {
            if accountField.isFirstResponder() {
                center = CGPointMake(screenWidth/2.0, screenHeight/2.0 - DevicePhonePadKeyboardHeight! + 160)
            } else {
                center = CGPointMake(screenWidth/2.0, screenHeight/2.0 - DevicePhonePadKeyboardHeight! + 90)
            }
            loginViewAlpha = 0.0
        } else {
            center = CGPointMake(screenWidth/2.0, screenHeight/2.0)
            loginViewAlpha = 1.0
        }
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.view.center = center
            self.logoImageView.alpha = loginViewAlpha
        }
    }
}

// MARK: SelectCountryDelegate

extension JLLoginViewController: SelectCountryCodeDelegate {
    
    func selectedCountry(selectedCountry: TBCountry!) {
        viewModel.countryCode = "+\(selectedCountry.phoneCode)"
        if viewModel.countryCode == "+86" {
            viewModel.isChinesePhone = true
        } else {
            viewModel.isChinesePhone = false
        }
        zoneCodeButton.setTitle(viewModel.countryCode, forState: .Normal)
    }
}

// MARK: UITextFieldDelegate

extension JLLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == accountField {
            passwordField.becomeFirstResponder()
        } else {
            login()
        }
        
        return true
    }
}

// MARK: JLImageValidControllerDelegate

extension JLLoginViewController: JLImageValidControllerDelegate {
    func cancelValid() {
        self.showLoading(false)
    }
    
    func successValid(uid: NSString) {
        let param = ["phoneNumber": viewModel.finalPhoneNumber, "action": "signup","password": passwordField.text!,"uid":uid]
        TBLoginSessionManager.sharedManager().POST(kMobileSendVerifyCodePath, parameters: param, success: { (task: NSURLSessionDataTask!, responseObject) -> Void in
            self.showLoading(false)
            let responseDict = responseObject as? NSDictionary
            let randomCode = responseDict?.valueForKey("randomCode") as? String
            self.performSegueWithIdentifier("EnterVerificationForSignUP", sender: randomCode)
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                TBUtility.showMessageInError(error)
                self.showLoading(false)
        })
    }
}

