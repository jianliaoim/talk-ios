//
//  PlaceHolderView.h
//  Talk
//
//  Created by Suric on 15/6/18.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceHolderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *noContentImage;
@property (weak, nonatomic) IBOutlet UILabel *noContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;

- (void)setPlaceHolderWithImage:(UIImage *)img andTitle:(NSString *)title andReminder:(NSString *)reminder;

@end
