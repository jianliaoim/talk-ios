//
//  JLContactTableViewCell.h
//  Talk
//
//  Created by 王卫 on 15/11/4.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOUser;

typedef NS_ENUM(NSUInteger, JLContactCellPosition) {
    JLContactCellPositionNormal,
    JLContactCellPositionTop,
};

static CGFloat const JLContactCellDefaultHeight = 50.0;
static CGFloat const JLContactCellDefaultOffset = 5.0;

@interface JLContactTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic) JLContactCellPosition cellPosition;

@end
