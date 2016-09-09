//
//  AddTeamAfterScanQRCodeViewController.h
//  Talk
//
//  Created by 史丹青 on 6/11/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinTeamAfterScanQRCodeViewController : UIViewController

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *signCode;
@property (strong, nonatomic) NSString *inviteCode;
@property (assign, nonatomic) BOOL isInvite;
@end
