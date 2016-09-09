//
//  TBShareToCell.h
//  Talk
//
//  Created by teambition-ios on 15/3/17.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MORoom.h"
#import "MOUser.h"
#import "UIColor+TBColor.h"

@interface TBShareToCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) MORoom *room;
@property (strong, nonatomic) MOUser *user;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) UIColor *searchTintColor;

@end
