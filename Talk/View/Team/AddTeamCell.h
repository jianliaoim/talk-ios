//
//  AddTeamCell.h
//  Talk
//
//  Created by 史丹青 on 8/27/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTeamCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *addTeamImage;
@property (weak, nonatomic) IBOutlet UILabel *addTeamTitle;
@property (weak, nonatomic) IBOutlet UILabel *addTeamDescription;

- (void)setCellWithImageName:(NSString *)imageName andTitle:(NSString *)title andDescription:(NSString *)description;

@end
