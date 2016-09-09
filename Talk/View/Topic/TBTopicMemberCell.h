//
//  TBTopicMemberCell.h
//  Talk
//
//  Created by teambition-ios on 15/4/3.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBButton.h"

@interface TBTopicMemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet TBButton *deleteButton;

@end
