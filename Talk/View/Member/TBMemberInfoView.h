//
//  TBMemberInfoView.h
//  Talk
//
//  Created by 史丹青 on 9/25/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MOUser;

@protocol TBMemberInfoViewDelegate <NSObject>

- (void)clickLeftButtonInTBMemberInfoView;
- (void)clickRightButtonInTBMemberInfoView;

@end

@interface TBMemberInfoView : UIView

@property (strong, nonatomic) MOUser *user;

@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userAvator;
@property (weak, nonatomic) IBOutlet UILabel *userPhone;
@property (weak, nonatomic) IBOutlet UILabel *userEmail;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *midButton;

@property (weak, nonatomic) id<TBMemberInfoViewDelegate> delegate;

- (void)setViewWithUser:(MOUser *)user;
- (void)displayOneButton;

@end
