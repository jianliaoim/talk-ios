//
//  SuccessView.swift
//  Talk
//
//  Created by 史丹青 on 9/1/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class SuccessView: UIView {

    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    func showWithTitle(title:String, reminder:String) {
        titleLabel.text = title
        reminderLabel.text = title
        completeButton.setTitle(NSLocalizedString("Finish", comment: "Finish"), forState: UIControlState.Normal)
        setCustomView()
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
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
    }
    
}

extension SuccessView {
    @IBAction func clickCompleteButton(sender: UIButton) {
        removeFromSuperview()
    }
}
