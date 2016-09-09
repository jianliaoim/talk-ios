//
//  FeedbackTableViewController.h
//  Talk
//
//  Created by teambition-ios on 14/12/16.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackTableViewController : UITableViewController
@property(nonatomic,strong) NSString *reportMessageID;
@property(nonatomic,strong) NSString *reportContentStr;
@property(nonatomic) BOOL isReport;  //judge current VC is Report or Feedback
@end
