//
//  StoryView.m
//  Talk
//
//  Created by 史丹青 on 10/22/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "StoryView.h"
#import "ChatViewController.h"
#import "Masonry.h"
#import "MOStory.h"
#import "constants.h"
#import "UIColor+TBColor.h"

#define TopicViewHeight 350

@interface StoryView()

@property (nonatomic, strong) MOStory *story;

@property (nonatomic, strong) UILabel *topicTitleLabel;
@property (nonatomic, strong) UILabel *topicDescriptionLabel;

@property (nonatomic, strong) UIImageView *storyImageView;

@end

@implementation StoryView

- (instancetype)initWithFrame:(CGRect)frame withStory:(MOStory *)story{
    self.story = story;
    CGRect newFrame = frame;
    self = [super initWithFrame:newFrame];
    return self;
}

#pragma mark - Getter

- (UIView *)backDrop {
    if (!_backDrop) {
        _backDrop = [[UIView alloc] initWithFrame:self.bounds];
        _backDrop.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _backDrop.alpha = 0;
        [self addSubview:_backDrop];
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnBackground)];
        singleTapGesture.numberOfTapsRequired = 1;
        [_backDrop addGestureRecognizer:singleTapGesture];
    }
    return _backDrop;
}

- (UIView *)topicView {
    if (!_topicView) {
        _topicView = [[UIView alloc] initWithFrame:CGRectMake(0, -TopicViewHeight, self.frame.size.width, TopicViewHeight)];
        _topicView.backgroundColor = [UIColor whiteColor];
    }
    return _topicView;
}

#pragma mark - Public

- (void)setViewWithStory:(MOStory *)story {
    self.story = story;
    NSDictionary *storyDataDic = self.story.data;
    
    if ([self.story.category isEqualToString:kStoryCategoryTopic]) {
        [self.topicTitleLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"title"]]];
        [self.topicDescriptionLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"text"]]];
        
    } else if ([self.story.category isEqualToString:kStoryCategoryLink]) {
        [self.topicTitleLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"title"]]];
        
        [self.topicDescriptionLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"text"]]];
        
        [self.storyImageView sd_setImageWithURL:[NSURL URLWithString:storyDataDic[@"imageUrl"]] placeholderImage:nil];
        
    } else if ([self.story.category isEqualToString:kStoryCategoryFile]) {
        
        [self.storyImageView sd_setImageWithURL:[NSURL URLWithString:storyDataDic[@"downloadUrl"]] placeholderImage:nil];
    }
}

- (void)showStoryViewInVC:(ChatViewController *)inViewController {
    [self initBackdrop];
    [self initTopicView];
    [inViewController.view addSubview:self];
    [self showAnimation];
};

- (void)showAnimation {
    [UIView animateWithDuration:0.4 delay:0 options:7<<16 animations:^{
        self.backDrop.alpha = 1;
        self.topicView.frame = CGRectMake(0, 0, self.frame.size.width, TopicViewHeight);
    } completion:nil];
};

- (void)hideAnimation {
    [UIView animateWithDuration:0.4 delay:0 options:7<<16 animations:^{
        self.backDrop.alpha = 0;
        self.topicView.frame = CGRectMake(0, -TopicViewHeight, self.frame.size.width, TopicViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
};

#pragma mark - Private

- (void)initBackdrop {
    if (self.backDrop == nil) {
        self.backDrop = [[UIView alloc] initWithFrame:self.bounds];
        self.backDrop.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.backDrop.alpha = 0;
        [self addSubview:self.backDrop];
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnBackground)];
        singleTapGesture.numberOfTapsRequired = 1;
        [self.backDrop addGestureRecognizer:singleTapGesture];
    }
}

- (void)initTopicView {
    CGFloat topicViewHeight = 200;
    if (self.topicView == nil) {
        self.topicView = [[UIView alloc] initWithFrame:CGRectMake(0, -topicViewHeight, self.frame.size.width, topicViewHeight)];
    } else {
        self.topicView.frame = CGRectMake(0, -topicViewHeight, self.frame.size.width, topicViewHeight);
    }
    
    NSDictionary *storyDataDic = self.story.data;
    
    if ([self.story.category isEqualToString:kStoryCategoryTopic]) {
        self.topicTitleLabel = [[UILabel alloc] init];
        [self.topicView addSubview:self.topicTitleLabel];
        [self.topicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicView.mas_top).with.offset(20);
            make.left.equalTo(self.topicView.mas_left).with.offset(20);
            make.right.equalTo(self.topicView.mas_right).with.offset(-20);
            make.height.mas_equalTo(80);
        }];
        self.topicTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.topicTitleLabel.numberOfLines = 0;
        [self.topicTitleLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"title"]]];
        
        self.topicDescriptionLabel = [[UILabel alloc] init];
        [self.topicView addSubview:self.topicDescriptionLabel];
        [self.topicDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.topicView.mas_bottom).with.offset(-20);
            make.left.equalTo(self.topicView.mas_left).with.offset(20);
            make.right.equalTo(self.topicView.mas_right).with.offset(-20);
            make.height.mas_equalTo(220);
        }];
        self.topicDescriptionLabel.textColor = [UIColor grayColor];
        self.topicDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.topicDescriptionLabel.numberOfLines = 0;
        [self.topicDescriptionLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"text"]]];
        
    } else if ([self.story.category isEqualToString:kStoryCategoryLink]) {
        self.topicTitleLabel = [[UILabel alloc] init];
        [self.topicView addSubview:self.topicTitleLabel];
        [self.topicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicView.mas_top).with.offset(20);
            make.left.equalTo(self.topicView.mas_left).with.offset(20);
            make.right.equalTo(self.topicView.mas_right).with.offset(-20);
            make.height.mas_equalTo(40);
        }];
        self.topicTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.topicTitleLabel.numberOfLines = 0;
        [self.topicTitleLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"title"]]];
        
        self.topicDescriptionLabel = [[UILabel alloc] init];
        [self.topicView addSubview:self.topicDescriptionLabel];
        [self.topicDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicView.mas_top).with.offset(60);
            make.left.equalTo(self.topicView.mas_left).with.offset(20);
            make.right.equalTo(self.topicView.mas_right).with.offset(-20);
            make.height.mas_equalTo(100);
        }];
        self.topicDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.topicDescriptionLabel.numberOfLines = 0;
        [self.topicDescriptionLabel setText:[NSString stringWithFormat:@"%@\n\n\n\n",storyDataDic[@"text"]]];
        
        self.storyImageView = [[UIImageView alloc] init];
        [self.topicView addSubview:self.storyImageView];
        [self.storyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topicView.mas_left).with.offset(10);
            make.right.equalTo(self.topicView.mas_right).with.offset(-10);
            make.bottom.equalTo(self.topicView.mas_bottom).with.offset(-50);
            make.height.mas_equalTo(120);
        }];
        self.storyImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.storyImageView sd_setImageWithURL:[NSURL URLWithString:storyDataDic[@"imageUrl"]] placeholderImage:nil];
        
    } else if ([self.story.category isEqualToString:kStoryCategoryFile]) {
        self.storyImageView = [[UIImageView alloc] init];
        [self.topicView addSubview:self.storyImageView];
        [self.storyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicView.mas_top).with.offset(0);
            make.left.equalTo(self.topicView.mas_left).with.offset(0);
            make.right.equalTo(self.topicView.mas_right).with.offset(0);
            make.bottom.equalTo(self.topicView.mas_bottom).with.offset(0);
        }];
        self.storyImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.storyImageView sd_setImageWithURL:[NSURL URLWithString:storyDataDic[@"downloadUrl"]] placeholderImage:nil];
    }
    
    [self addSubview:self.topicView];
}

- (void)singleTapOnBackground {
    [self hideAnimation];
}

@end
