//
//  TBMemberCollectionCell.h
//  Talk
//
//  Created by teambition-ios on 14/10/15.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBUser.h"

@interface TBMemberCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *memberImageView;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLbl;
@property(nonatomic,strong) TBUser *user;
@end
