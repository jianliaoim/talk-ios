//
//  TBTeamCell.h
//  Talk
//
//  Created by Shire on 10/9/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <M13BadgeView.h>

@interface TBTeamCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *InitialNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *teambitionLogo;
@property (weak, nonatomic) IBOutlet UIButton *badgeButton;
@property (weak, nonatomic) IBOutlet UIView *dotView;

@end
