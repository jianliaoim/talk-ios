//
//  MentionReceiptViewController.swift
//  Talk
//
//  Created by 史丹青 on 2/15/16.
//  Copyright © 2016 Teambition. All rights reserved.
//

import UIKit

class MentionReceiptViewController: UITableViewController {
    
    var receiptMembers:[MOUser]?
    var otherMembers:[MOUser]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(receiptMembers!.count)/\(receiptMembers!.count+otherMembers!.count) \(NSLocalizedString("received", comment: "received"))"
        
        let identifier = "Cell"
        tableView.registerNib(UINib(nibName: "TBMemberCell", bundle: nil), forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorColor = UIColor.tb_tableViewSeperatorColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "\(otherMembers!.count) \(NSLocalizedString("not received yet", comment: "not received yet"))"
        } else {
            return "\(receiptMembers!.count) \(NSLocalizedString("received", comment: "received"))"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return otherMembers!.count
        } else {
            return receiptMembers!.count
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView;
        headerView.textLabel?.textColor = UIColor.blackColor()
        headerView.textLabel?.font = UIFont.systemFontOfSize(14.0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! TBMemberCell
        if indexPath.section == 0 {
            cell.nameLabel?.text = TBUtility.getFinalUserNameWithMOUser(otherMembers![indexPath.row])
            cell.cellImageView?.sd_setImageWithURL(NSURL(string: otherMembers![indexPath.row].avatarURL))
        } else {
            cell.nameLabel?.text = TBUtility.getFinalUserNameWithMOUser(receiptMembers![indexPath.row])
            cell.cellImageView?.sd_setImageWithURL(NSURL(string: receiptMembers![indexPath.row].avatarURL))
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
}
