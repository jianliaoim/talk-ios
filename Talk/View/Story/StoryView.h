//
//  StoryView.h
//  Talk
//
//  Created by 史丹青 on 10/22/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOStory;
@class ChatViewController;

@interface StoryView : UIView

@property (nonatomic, strong) UIView* backDrop;
@property (nonatomic, strong) UIView* topicView;

- (instancetype)initWithFrame:(CGRect)frame withStory:(MOStory *)story;

- (void)setViewWithStory:(MOStory *)story;
- (void)showStoryViewInVC:(ChatViewController *)inViewController;

- (void)showAnimation;
- (void)hideAnimation;

@end
