//
//  ShareToTableViewController.h
//  Talk
//
//  Created by teambition-ios on 15/3/17.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareToTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *forwardMessageIdArray;
@property (nonatomic,strong) NSString *messageBody;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) BOOL isSendMessage;

@end
