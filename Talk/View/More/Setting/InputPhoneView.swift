//
//  InputPhoneView.swift
//  Talk
//
//  Created by 史丹青 on 9/1/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

protocol InputPhoneViewDelegate {
    func clickCompleteButtonInInputPhoneView(phoneNumber:String, isEmail:Bool)
    func changeCountryCode()
}

class InputPhoneView: UIView {

    var delegate: InputPhoneViewDelegate?
    var DevicePhonePadKeyboardHeight: CGFloat = 216.0
    var phoneNumber: String = ""
    var countryCode: String = "+86" {
        didSet {
            countryCodeLabel.text = countryCode
        }
    }
    var isEmail: Bool = false
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var phoneCodeView: UIView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var phoneNumberLeadingConstraint: NSLayoutConstraint!
    
    func showWithTitle(title:String, reminder:String) {
        titleLabel.text = title
        reminderLabel.text = reminder
        countryCodeLabel.text = "+86"
        setCustomView()
        if isEmail {
            countryCodeLabel.hidden = true
            countryCodeButton.hidden = true
            phoneNumberLeadingConstraint.constant = 8
            phoneNumberField.placeholder = NSLocalizedString("Input email", comment: "Input email")
            phoneNumberField.keyboardType = UIKeyboardType.EmailAddress
        } else {
            countryCodeLabel.hidden = false
            countryCodeButton.hidden = false
            phoneNumberLeadingConstraint.constant = 68
            phoneNumberField.placeholder = NSLocalizedString("Mobile number", comment: "Mobile number")
            phoneNumberField.keyboardType = UIKeyboardType.NumberPad
        }
        
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        initAnimation()
        phoneNumberField.delegate = self
        finishButton.setTitle(NSLocalizedString("Next", comment: "Next"), forState: UIControlState.Normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: UIControlState.Normal)
        rightVerificationCodeUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func setCustomView() {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        dialogView.addSubview(lineView)
        lineView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.dialogView.snp_bottom).offset(-50)
            make.left.equalTo(self.dialogView.snp_left).offset(0)
            make.right.equalTo(self.dialogView.snp_right).offset(0)
            make.height.equalTo(1)
        }
        lineView.layoutIfNeeded()
        
        let lineView2 = UIView()
        lineView2.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        dialogView.addSubview(lineView2)
        lineView2.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.dialogView.snp_bottom).offset(0)
            make.centerX.equalTo(self.dialogView.snp_centerX).offset(0)
            make.height.equalTo(50)
            make.width.equalTo(1)
        }
        lineView2.layoutIfNeeded()
    }
    
    func rightVerificationCodeUI() {
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: UIControlState.Normal)
        finishButton.setTitle(NSLocalizedString("Next", comment: "Next"), forState: UIControlState.Normal)
        self.titleView.backgroundColor = UIColor(red: 79/255, green: 195/255, blue: 247/255, alpha: 1)
        self.countryCodeLabel.backgroundColor = UIColor(red: 79/255, green: 195/255, blue: 247/255, alpha: 1)
        self.phoneCodeView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    }
    
    func wrongPhoneNumberUI() {
        if isEmail {
            titleLabel.text = NSLocalizedString("Wrong email", comment: "Wrong email")
            reminderLabel.text = NSLocalizedString("Please input your email again", comment: "Please input your email again")
        } else {
            titleLabel.text = NSLocalizedString("Wrong phone number", comment: "Wrong phone number")
            reminderLabel.text = NSLocalizedString("Please input your phone number again", comment: "Please input your phone number again")
        }
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: UIControlState.Normal)
        finishButton.setTitle(NSLocalizedString("Next", comment: "Next"), forState: UIControlState.Normal)
        self.titleView.backgroundColor = UIColor(red: 1, green: 112/255, blue: 67/255, alpha: 1)
        self.countryCodeLabel.backgroundColor = UIColor(red: 1, green: 112/255, blue: 67/255, alpha: 1)
        self.phoneCodeView.backgroundColor = UIColor(red: 1, green: 185/255, blue: 9/255, alpha: 1/10)
    }
    
}

// MARK: User Interaction
extension InputPhoneView: UITextFieldDelegate {
    @IBAction func clickCancelButton(sender: UIButton) {
        phoneNumberField.resignFirstResponder()
        dismissAnimation()
    }
    @IBAction func clickCompleteButton(sender: UIButton) {
        phoneNumber = phoneNumberField.text!
        print("====countryCode:\(countryCode)==phoneNumber:\(phoneNumber)====")
        if isEmail {
            if !TBUtility.checkEmail(phoneNumber) {
                wrongPhoneNumberUI()
                return
            }
        } else {
            if !phoneNumber.checkChineseTelNumber() && (countryCode == "+86") || !TBUtility.checkPhoneNumberWithString(phoneNumber) && !(countryCode == "+86") {
                wrongPhoneNumberUI()
                return
            }
        }
        
        delegate?.clickCompleteButtonInInputPhoneView(phoneNumber, isEmail: isEmail)
    }
    @IBAction func changeCountryCode(sender: UIButton) {
        delegate?.changeCountryCode()
    }
}

// MARK: Animation 

extension InputPhoneView {
    
    func initAnimation() {
        dialogView.snp_remakeConstraints { (make) -> Void in
            make.centerY.equalTo(self.snp_top).offset(-138)
        }
        self.dialogView.layoutIfNeeded()
        UIView.animateWithDuration(0.5, delay: 0,usingSpringWithDamping:1,initialSpringVelocity:5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.dialogView.snp_remakeConstraints { (make) -> Void in
                make.centerY.equalTo(self.snp_centerY).offset(0)
            }
            self.dialogView.layoutIfNeeded()
            }, completion: nil)
    }
    
    func dismissAnimation() {
        UIView.animateWithDuration(0.5, delay: 0,usingSpringWithDamping:1,initialSpringVelocity:5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.dialogView.snp_remakeConstraints { (make) -> Void in
                make.centerY.equalTo(self.snp_bottom).offset(138)
            }
            self.dialogView.layoutIfNeeded()
            }, completion: { finished in
                self.removeFromSuperview()
        })
    }
}

// MARK: Keyboard

extension InputPhoneView {
    
    func changeKeyboard(notification:NSNotification){
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        let userInfo :[NSObject:AnyObject] = notification.userInfo!
        let userDic = userInfo as NSDictionary
        let keyboarFrame = userDic.valueForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue
        let keyboardY = keyboarFrame?.size.height
        
        DevicePhonePadKeyboardHeight = keyboardY! == 0 ? 236: keyboardY!
        
        UIView.animateWithDuration(0.5, delay: 0,usingSpringWithDamping:1,initialSpringVelocity:5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.dialogView.snp_updateConstraints { (make) -> Void in
                make.centerY.equalTo(self.snp_bottom).offset(-138-20-self.DevicePhonePadKeyboardHeight)
            }
            self.dialogView.layoutIfNeeded()
            }, completion: nil)
    }
    
}

