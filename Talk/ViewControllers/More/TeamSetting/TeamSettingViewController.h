//
//  TeamSettingViewController.h
//  Talk
//
//  Created by 史丹青 on 15/4/24.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOTeam.h"

@interface TeamSettingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) MOTeam *currentTeam;
@end
