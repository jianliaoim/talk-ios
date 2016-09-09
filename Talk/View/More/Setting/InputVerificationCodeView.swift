//
//  InputVerificationCodeView.swift
//  Talk
//
//  Created by 史丹青 on 9/1/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

protocol InputVerificationCodeViewDelegate {
    func clickCompleteButtonInInputVerificationCodeView(verifycode:String)
    func sendVerifyCodeAgain()
}

class InputVerificationCodeView: UIView {
    
    @IBOutlet weak var codeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var spaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var spaceConstraint2: NSLayoutConstraint!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var verificationCodeField: UITextField!
    @IBOutlet weak var verificationCodeView: UIView!
    @IBOutlet weak var code1: UILabel!
    @IBOutlet weak var code2: UILabel!
    @IBOutlet weak var code3: UILabel!
    @IBOutlet weak var code4: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: InputVerificationCodeViewDelegate?
    
    var verificationCode:String?
    var seconds = 60
    var isRightUI:Bool = true
    var DevicePhonePadKeyboardHeight: CGFloat = 216.0
    var isEmail: Bool = false

    func showWithTitle(title:String, reminder:String) {
        titleLabel.text = title
        reminderLabel.text = reminder
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        verificationCodeField.becomeFirstResponder()
        verificationCodeField.delegate = self
        bindingTextfieldWithCodeLabel()
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: UIControlState.Normal)
        finishButton.setTitle(NSLocalizedString("Next", comment: "Next"), forState: UIControlState.Normal)
        setCustomView()
        setSendAgainButton()
    }
    
    func rightVerificationCodeUI() {
        isRightUI = true
        self.titleLabel.text = NSLocalizedString("Input verification code", comment: "Input verification code")
        if isEmail {
            self.reminderLabel.text = NSLocalizedString("Aready send code to your email", comment: "Aready send code to your email")
        } else {
            self.reminderLabel.text = NSLocalizedString("Aready send code to you mobile", comment: "Aready send code to you mobile")
        }
        self.titleView.backgroundColor = UIColor(red: 79/255, green: 195/255, blue: 247/255, alpha: 1)
        self.code1.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.code2.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.code3.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.code4.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    }
    
    func wrongVerificationCodeUI() {
        isRightUI = false
        self.titleLabel.text = NSLocalizedString("Wrong verification code", comment: "Wrong verification code")
        if isEmail {
            self.reminderLabel.text = NSLocalizedString("Aready send code to you email", comment: "Aready send code to you email")
        } else {
            self.reminderLabel.text = NSLocalizedString("Aready send code to you mobile", comment: "Aready send code to you mobile")
        }
        self.titleView.backgroundColor = UIColor(red: 1, green: 112/255, blue: 67/255, alpha: 1)
        self.code1.backgroundColor = UIColor(red: 1, green: 185/255, blue: 9/255, alpha: 1/10)
        self.code2.backgroundColor = UIColor(red: 1, green: 185/255, blue: 9/255, alpha: 1/10)
        self.code3.backgroundColor = UIColor(red: 1, green: 185/255, blue: 9/255, alpha: 1/10)
        self.code4.backgroundColor = UIColor(red: 1, green: 185/255, blue: 9/255, alpha: 1/10)
    }
    
    func setCustomView() {
        
        codeViewWidthConstraint.constant *= UIScreen.mainScreen().bounds.width/375
        spaceConstraint.constant *= UIScreen.mainScreen().bounds.width/375
        spaceConstraint2.constant *= UIScreen.mainScreen().bounds.width/375
        verificationCodeView.layoutIfNeeded()
        
        self.code1.setCornerRadiusWithNumber(5)
        self.code2.setCornerRadiusWithNumber(5)
        self.code3.setCornerRadiusWithNumber(5)
        self.code4.setCornerRadiusWithNumber(5)
        
        dialogView.snp_remakeConstraints { (make) -> Void in
            make.centerY.equalTo(self.snp_bottom).offset(-138-20-DevicePhonePadKeyboardHeight)
        }
        dialogView.layoutIfNeeded()
        
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
    
    
    func setSendAgainButton() {
        seconds = 60
        finishButton.setTitle(NSString(format: NSLocalizedString("Send again (%d)", comment: "Send again (%d)"), 60) as String, forState: UIControlState.Normal)
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFireMethod:", userInfo: nil, repeats: true)
        finishButton.enabled = false
        finishButton.setTitleColor(UIColor.tb_grayColor(), forState: UIControlState.Normal)
    }
    
    func timerFireMethod(theTimer: NSTimer) {
        if seconds == 1 {
            theTimer.invalidate()
            seconds = 60
            finishButton.setTitle(NSLocalizedString("Send again", comment: "Send again"), forState: UIControlState.Normal)
            finishButton.enabled = true
            finishButton.setTitleColor(UIColor.tb_blueColor(), forState: UIControlState.Normal)
        } else {
            seconds -= 1
            finishButton.setTitle(NSString(format: NSLocalizedString("Send again (%d)", comment: "Send again (%d)"), seconds) as String, forState: UIControlState.Normal)
        }
    }
}

//MARK: User Interaction

extension InputVerificationCodeView {
    
    @IBAction func clickCancelButton(sender: UIButton) {
        removeFromSuperview()
    }
    @IBAction func clickCompleteButton(sender: UIButton) {
        setSendAgainButton()
        delegate!.sendVerifyCodeAgain()
    }
}

// MARK: Binding

extension InputVerificationCodeView {
    
    func bindingTextfieldWithCodeLabel() {
        self.code1.text = " "
        self.code2.text = " "
        self.code3.text = " "
        self.code4.text = " "
        verificationCodeField.rac_textSignal().subscribeNext{ (x:AnyObject!) -> Void in
            self.verificationCode = x as? String
            var codeArray = [" "," "," "," "]
            var index = 0
            for temp in (self.verificationCode!).characters {
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

extension InputVerificationCodeView: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print(">>>>>>> \(textField.text) >>>>\(textField.text!.characters.count ) >>>>\(string)>>>> \(string.characters.count )")
        if ((textField.text! + string).characters.count > 4) {
            return false
        }
        if (textField.text! + string).characters.count == 4 && string.characters.count != 0 {
            self.verificationCode = textField.text! + string
            self.delegate?.clickCompleteButtonInInputVerificationCodeView(self.verificationCode!)
        }
        if !self.isRightUI {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.rightVerificationCodeUI()
            })
        }
        return true
    }
    
}
