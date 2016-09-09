//
//  BindAccountRemindView.swift
//  Talk
//
//  Created by 史丹青 on 8/31/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

@objc protocol RemindViewDelegate {
    func clickFinishButtonInRemindView()
}

class RemindView: UIView {
    
    var delegate: RemindViewDelegate?

    @IBOutlet weak var DialogView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapBackground")
        self.addGestureRecognizer(tapGesture)
    }

    func showWithTitle(title:String, reminder:String, rightButtonName: String, color:UIColor) {
        titleLabel.text = title
        reminderLabel.text = reminder
        acceptButton.setTitle(rightButtonName, forState: UIControlState.Normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: UIControlState.Normal)
        acceptButton.titleLabel?.tintColor = UIColor.jl_redColor()
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        titleView.backgroundColor = color
        acceptButton.setTitleColor(color, forState: UIControlState.Normal)
        setCustomView()
    }
    
    func setCustomView() {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        DialogView.addSubview(lineView)
        lineView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.DialogView.snp_bottom).offset(-50)
            make.left.equalTo(self.DialogView.snp_left).offset(0)
            make.right.equalTo(self.DialogView.snp_right).offset(0)
            make.height.equalTo(1)
        }
        lineView.layoutIfNeeded()
        
        let lineView2 = UIView()
        lineView2.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        DialogView.addSubview(lineView2)
        lineView2.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.DialogView.snp_bottom).offset(0)
            make.centerX.equalTo(self.DialogView.snp_centerX).offset(0)
            make.height.equalTo(50)
            make.width.equalTo(1)
        }
        lineView2.layoutIfNeeded()
    }
    
}

// MARK: User Interaction

extension RemindView {
    
    @IBAction func clickCancelButton(sender: UIButton) {
        self.removeFromSuperview()
    }
    @IBAction func clickFinishButton(sender: UIButton) {
        delegate?.clickFinishButtonInRemindView()
        self.removeFromSuperview()
    }
    
    
    func tapBackground() {
        removeFromSuperview()
    }
}

// MARK: Load Nib

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}
