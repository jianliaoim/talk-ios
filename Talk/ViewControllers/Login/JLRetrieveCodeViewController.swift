//
//  JLRetrieveCodeViewController.swift
//  Talk
//
//  Created by Suric on 15/11/5.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

class JLRetrieveCodeViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var zoneCodeButton: UIButton!
    @IBOutlet weak var zoneCodeButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountFieldLeadingConstraint: NSLayoutConstraint!
    
    var isEmail: Bool = true
    let viewModel = JLLoginViewModel()

    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        accountTextField.becomeFirstResponder()
    }
    
    func commonInit() {
        let zoneCodeBgImage = UIImage(named: "zoneCodeBg")?.imageWithRenderingMode(.AlwaysTemplate)
        zoneCodeButton.setBackgroundImage(zoneCodeBgImage, forState: .Normal)
        zoneCodeButton.tintColor = UIColor.jl_redColor()
        
        title = NSLocalizedString("Send Verification", comment:"Send Verification")
        let accountLeftView = UIView(frame: CGRectMake(0, 0, 15, 50))
        accountTextField.tintColor = UIColor.jl_redColor()
        accountTextField.leftView = accountLeftView
        accountTextField.leftViewMode = UITextFieldViewMode.Always
        if isEmail {
            accountTextField.placeholder = NSLocalizedString("Input email", comment: "Input email")
            accountTextField.keyboardType = .Default
            zoneCodeButtonWidthConstraint.constant = 0
            accountFieldLeadingConstraint.constant = 50
        } else {
            accountTextField.placeholder = NSLocalizedString("Input mobile", comment: "Input mobile")
            accountTextField.keyboardType = .NumberPad
            zoneCodeButtonWidthConstraint.constant = 60
            accountFieldLeadingConstraint.constant = 105
        }
        nextButton.setTitle(NSLocalizedString("Send Verification", comment:"Send Verification"), forState: .Normal)
        nextButton.backgroundColor = UIColor.jl_redColor()
        nextButton.enabled = false
        nextButton.alpha = 0.5
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EnterVerificationForRetrieveCode" {
            let verificationVC = segue.destinationViewController as! JLVerificationViewController
            verificationVC.type = VerificationType.retriveCode;
            verificationVC.isEmail = isEmail
            if isEmail {
                print("viewModel.PhoneNumber: \(viewModel.phoneNumber)")
                verificationVC.viewModel.phoneNumber = viewModel.phoneNumber
            } else {
                print("viewModel.finalPhoneNumber: \(viewModel.finalPhoneNumber)")
                verificationVC.viewModel.phoneNumber = viewModel.finalPhoneNumber
                verificationVC.viewModel.validUid = sender as? String
            }
        }
    }
    
    //MARK: IBActions
    
    @IBAction func nextAction(sender: AnyObject) {
        if !checkAccountAndPassword() {
            return
        }
        if isEmail {
            self.performSegueWithIdentifier("EnterVerificationForRetrieveCode", sender: self)
        } else {
            validImage()
        }
    }
    
    @IBAction func changeCountryCode(sender: UIButton) {
        let countryCodeVC = SelectCountryToInputMobileNumberViewController()
        countryCodeVC.delegate = self
        let navVC = UINavigationController(rootViewController: countryCodeVC)
        presentViewController(navVC, animated: true, completion: nil)
    }
    
    //MARK: Private methods
    
    func validImage() {
        let imageValidVC = self.storyboard?.instantiateViewControllerWithIdentifier("JLImageValidController") as! JLImageValidController
        imageValidVC.delegate = self
        presentViewController(imageValidVC, animated: true, completion: nil)
    }
    
    func textFieldTextDidChange() {
        if accountTextField.text?.characters.count == 0  {
            nextButton.enabled = false
            nextButton.alpha = 0.5
        } else {
            nextButton.enabled = true
            nextButton.alpha = 1.0
        }
    }
    
    func checkAccountAndPassword() -> Bool {
        let account = accountTextField.text
        if TBUtility.checkEmail(account) || TBUtility.checkChinaTelNumber(account) || TBUtility.checkPhoneNumberWithString(account) {
            viewModel.phoneNumber = account!
            return true
        } else {
            SVProgressHUD.showErrorWithStatus(NSLocalizedString("Please input right Style", comment: "Please input right Style"))
            return false
        }
    }
}

// MARK: SelectCountryDelegate

extension JLRetrieveCodeViewController: SelectCountryCodeDelegate {
    
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

// MARK: JLImageValidControllerDelegate

extension JLRetrieveCodeViewController: JLImageValidControllerDelegate {
    func cancelValid() {
    }
    
    func successValid(uid: NSString) {
        self.performSegueWithIdentifier("EnterVerificationForRetrieveCode", sender: uid)
    }
}
