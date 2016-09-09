//
//  BindAccountCell.swift
//  Talk
//
//  Created by 史丹青 on 9/2/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

import UIKit

class BindAccountCell: UITableViewCell {

    @IBOutlet weak var bindImage: UIImageView!
    @IBOutlet weak var bindButton: UIButton!
    @IBOutlet weak var bindName: UILabel!
    @IBOutlet weak var bindAccount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
