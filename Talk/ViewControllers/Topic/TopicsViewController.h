//
//  TopicsViewController.h
//  Talk
//
//  Created by Shire on 9/25/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MORoom;

@protocol ChooseGroupDelegate <NSObject>

- (void)haveChoosenGroup:(MORoom *)myGroup;

@end

@interface TopicsViewController : UITableViewController

@property (nonatomic, assign) BOOL isForChoosingGroup;
@property (nonatomic, weak) id<ChooseGroupDelegate> delegate;

@end
