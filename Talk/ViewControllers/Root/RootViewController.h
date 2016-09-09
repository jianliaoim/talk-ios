//
//  RootViewController.h
//  Talk
//
//  Created by Shire on 9/18/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactTableViewController.h"

@interface RootViewController : UITabBarController
@property (strong, nonatomic) UIButton *addButton;

- (void)addChatWithChatType:(TBContactType)type;
- (void)addIdea;
- (void)addImage;
- (void)addLink;
- (void)enterChatForMessageInfo:(NSDictionary *)messageInfo;
@end
