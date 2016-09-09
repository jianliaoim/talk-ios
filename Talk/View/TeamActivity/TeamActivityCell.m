//
//  TeamActivityCell.m
//  Talk
//
//  Created by Suric on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "TeamActivityCell.h"
#import "constants.h"

static CGFloat const CellDefaultHeight = 72;
static CGFloat const DetailCellDefaultHeight = 95;
static CGFloat const DetailLabelDefaultHeight = 17;

@implementation TeamActivityCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (CGFloat)calculateCellHeightWithTeamActivity:(TBTeamActivity *)activity {
    if (activity.targetId) {
        if ([activity.type isEqualToString:kNotificationTypeStory]) {
            NSDictionary *storyDic = activity.target[@"data"];
            NSString *storyCategory = activity.target[@"category"];
            if ([storyCategory isEqualToString:kStoryCategoryFile]) {
                if ([storyDic[@"fileCategory"] isEqualToString:kFileCategoryImage]) {
                    CGFloat cellHeight = DetailCellDefaultHeight - DetailLabelDefaultHeight + activity.imageSize.height;
                    return cellHeight;
                } else {
                    return CellDefaultHeight;
                }
            }
            return [TeamActivityCell commonHeightForTeamActivity:activity];
        } else {
            return [TeamActivityCell commonHeightForTeamActivity:activity];
        }
    } else {
        return CellDefaultHeight;
    }
}

+ (CGFloat)commonHeightForTeamActivity:(TBTeamActivity *)activity {
    CGFloat activityDetailHeight = [TeamActivityCell getSizeWith:activity.activityDetail].height;
    CGFloat cellHeight = DetailCellDefaultHeight - DetailLabelDefaultHeight + activityDetailHeight;
    return cellHeight;
}

+ (CGSize)getSizeWith:(NSString *)messageStr {
    NSString *importStr = messageStr;
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width - ActivityDetailMargin;
    CGSize tempsize = CGSizeMake(contentViewWidth,CGFLOAT_MAX);
    
    UILabel *temLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines  = 3;
    temLabel.font = [UIFont systemFontOfSize:14.0];
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    temLabel.text = importStr;
    CGSize size = [temLabel sizeThatFits:tempsize];
    
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

@end
