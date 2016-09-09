//
//  TBTopicOpenCell.h
//  Talk
//
//  Created by teambition-ios on 15/2/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TBTopicSwitchCellType) {
    TBTopicSwitchCellTypeOpen,
    TBTopicSwitchCellTypePin,
    TBTopicSwitchCellTypeMute,
    TBTopicSwitchCellTypeHideMobile
};

@protocol TBTopicOpenCellDelegate <NSObject>
@optional
- (void)openTopicWith:(BOOL)isOpen;
- (void)pinTopicWith:(BOOL)isOpen;
- (void)muteTopicWith:(BOOL)isOpen;
- (void)hideMobileWith:(BOOL)isOpen;

@end

@interface TBTopicOpenCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;
@property (nonatomic) TBTopicSwitchCellType switchType;
@property (nonatomic, assign) id <TBTopicOpenCellDelegate> delegate;

@end
