//
//  MessageEditViewController.h
//  Talk
//
//  Created by teambition-ios on 15/1/13.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+TBColor.h"
#import "TBMessage.h"

@protocol MessageEditViewControllerDelegate <NSObject>

-(void)messageEditCancel;
-(void)messageEditSaveWith:(NSString *)changedMessageStr andOriginMessage:(TBMessage *)originMessage;

@end

@interface MessageEditViewController : UIViewController

@property(nonatomic,strong) TBMessage *editMessage;
@property(nonatomic,strong) UIColor *tintColor;
@property(nonatomic,assign)id<MessageEditViewControllerDelegate> delegate;

@end
