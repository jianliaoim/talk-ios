//
//  TBChatBaseCell.h
//  Talk
//
//  Created by Suric on 15/5/29.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+TBUtilities.h"

@interface TBChatBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *imageShadowView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatorImageView;
@property (weak, nonatomic) IBOutlet UIView *bubbleContainer;
@property (weak, nonatomic) IBOutlet UIButton *resendBtn;  //for message send failed
@property (weak, nonatomic) IBOutlet UIImageView *tagImg;

@property (assign, nonatomic) BOOL showMenu;

@end
