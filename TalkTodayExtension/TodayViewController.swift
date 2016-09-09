//
//  TodayViewController.swift
//  TalkTodayExtension
//
//  Created by 史丹青 on 1/12/16.
//  Copyright © 2016 Teambition. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(0, 80)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    @IBAction func clickTopicButton(sender: UIButton) {
        extensionContext?.openURL(NSURL(string: "tb-talk://createTopicFromToday")!, completionHandler: nil)
    }
    
    @IBAction func clickPrivateChatButton(sender: UIButton) {
        extensionContext?.openURL(NSURL(string: "tb-talk://createPrivateChatFromToday")!, completionHandler: nil)
    }
    
    @IBAction func clickImageButton(sender: UIButton) {
        extensionContext?.openURL(NSURL(string: "tb-talk://createImageFromToday")!, completionHandler: nil)
    }
    
    @IBAction func clickIdeaButton(sender: UIButton) {
        extensionContext?.openURL(NSURL(string: "tb-talk://createIdeaFromToday")!, completionHandler: nil)
    }
    
    @IBAction func clickLinkButton(sender: UIButton) {
        extensionContext?.openURL(NSURL(string: "tb-talk://createLinkFromToday")!, completionHandler: nil)
    }
}
