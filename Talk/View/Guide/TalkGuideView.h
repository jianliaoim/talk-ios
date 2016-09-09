//
//  TalkGuideView.h
//  Talk
//
//  Created by 史丹青 on 7/29/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkGuideView : UIView

@property (weak, nonatomic) IBOutlet UIView *guideView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *reminder;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

- (void)showWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle andReminder:(NSString *)reminder;

@end
