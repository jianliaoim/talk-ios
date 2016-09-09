//
//  TBMemberCollectionCell.m
//  Talk
//
//  Created by teambition-ios on 14/10/15.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBMemberCollectionCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBUtility.h"

@implementation TBMemberCollectionCell
-(void)awakeFromNib
{
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;

    _memberImageView.clipsToBounds = YES;
    _memberImageView.layer.cornerRadius = _memberImageView.bounds.size.height/2;
    _memberImageView.layer.allowsEdgeAntialiasing = YES;
}

-(void)setUser:(TBUser *)user
{
    _user = user;
    self.memberNameLbl.text = [TBUtility getFinalUserNameWithTBUser:user];
    [self.memberImageView sd_setImageWithURL:user.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    [self setNeedsDisplay];
}
@end
