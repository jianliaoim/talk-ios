//
//  JLShareSendController.h
//  Talk
//
//  Created by teambition-ios on 15/4/14.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLShareViewController.h"

@protocol JLShareSendControllerDelgate <NSObject>

@optional
- (void)sendTORoom:(NSDictionary *)roomInfo;
- (void)sendTOMember:(NSDictionary *)memberInfo;

@end

@interface JLShareSendController : UITableViewController

@property (strong, nonatomic) NSDictionary *teamDic;
@property (weak, nonatomic) id<JLShareSendControllerDelgate> delegate;
@property (weak, nonatomic) id<JLShareExtensionDelegate> uiDelegate;
@property (assign, nonatomic) BOOL isStory;

@end
