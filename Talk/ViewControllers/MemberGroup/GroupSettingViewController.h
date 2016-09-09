//
//  GroupSettingViewController.h
//  Talk
//
//  Created by 王卫 on 15/12/24.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOGroup;

@protocol GroupSettingDelegate <NSObject>

- (void)didUpdateGroupSetting:(MOGroup *)group;

@end

@interface GroupSettingViewController : UITableViewController

@property (weak, nonatomic) id<GroupSettingDelegate> delegate;

- (instancetype)initWithGroup:(MOGroup *)group;

@end
