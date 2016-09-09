//
//  MeInfoViewController.h
//  Talk
//
//  Created by Shire on 9/29/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+TBColor.h"

@class MOUser;

@interface MeInfoViewController : UIViewController
@property(nonatomic, strong) MOUser *user;
@property(nonatomic,strong) UIColor *renderColor;
@property(nonatomic) BOOL isFromSetting;
@property(nonatomic) BOOL isFromRecent; //deal for enter Conversation if this ViewController push from Recent
@end
