//
//  AccountUIViewExtension.swift
//  Talk
//
//  Created by 史丹青 on 9/10/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

import UIKit

extension UIView {
    func setCornerRadiusWithNumber(number:CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = number
    }
}