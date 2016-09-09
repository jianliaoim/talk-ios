//
//  JLSwitchButtonCell.h
//  Talk
//
//  Created by 史丹青 on 1/27/16.
//  Copyright © 2016 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLSwitchButtonCellDelegate <NSObject>

@optional
- (void)switchButtonTo:(BOOL)onOrNot for:(NSString *)switchFor;

@end

@interface JLSwitchButtonCell : UITableViewCell

@property (weak, nonatomic) id<JLSwitchButtonCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (copy, nonatomic) NSString *switchFor;

- (void)setCellTitle:(NSString *)title;

@end
