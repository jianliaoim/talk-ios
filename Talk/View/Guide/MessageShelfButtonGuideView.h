//
//  MessageShelfButtonGuideView.h
//  Talk
//
//  Created by 史丹青 on 7/30/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageShelfButtonGuideView : UIView
@property (weak, nonatomic) IBOutlet UIView *guideView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;

- (void)show;

@end
