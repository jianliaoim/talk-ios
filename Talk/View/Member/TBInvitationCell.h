//
//  TBInvitationCell.h
//  Talk
//
//  Created by 史丹青 on 9/16/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBInvitationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *avatarLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)setupCellWithName:(NSString *)name;

@end
