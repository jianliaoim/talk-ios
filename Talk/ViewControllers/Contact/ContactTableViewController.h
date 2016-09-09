//
//  ContactTableViewController.h
//  Talk
//
//  Created by 王卫 on 15/11/4.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableViewDataSourceProtocol.h"
@class MOGroup;

typedef NS_ENUM(NSUInteger, TBContactType) {
    TBContactTypeMember,
    TBContactTypeTopic,
    TBContactTypeMemberGroup,
};

@protocol ContactTableViewControllerChooseDelegate <NSObject>

- (void)didChooseItem:(id)item;

@end

@interface ContactTableViewController : UITableViewController<CommonTableViewDataSourceSearchDelegate>

@property (weak, nonatomic) id<ContactTableViewControllerChooseDelegate> delegate;
@property (assign, nonatomic) TBContactType contactType;
@property (assign, nonatomic) BOOL isCancelButtonNeedHide;
@property (assign, nonatomic) BOOL isChoosing;

@end
