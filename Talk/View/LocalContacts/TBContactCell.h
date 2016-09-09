//
//  TBContactCell.h
//  Talk
//
//  Created by 史丹青 on 6/26/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBContact.h"
#import "TBButton.h"

@interface TBContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UILabel *contactPhone;
@property (weak, nonatomic) IBOutlet UIImageView *contactAvator;
@property (weak, nonatomic) IBOutlet UILabel *contactNameAvator;
@property (weak, nonatomic) IBOutlet UIImageView *contactIsInTeam;
@property (weak, nonatomic) IBOutlet TBButton *contactInviteButton;

- (void)setupCellWithTBContact:(TBContact *)contact;

@end
