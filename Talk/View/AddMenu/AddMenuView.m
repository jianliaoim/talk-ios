//
//  AddMenuView.m
//  Talk
//
//  Created by 史丹青 on 10/13/15.
//  Copyright © 2015 jiaoliao. All rights reserved.
//

#import "AddMenuView.h"
#import "Masonry.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+TBColor.h"

@interface AddMenuView()

@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIView *addItemsView;
@property (nonatomic,strong) UIButton *groupChatButton;
@property (nonatomic,strong) UIButton *privateChatButton;
@property (nonatomic,strong) UIButton *addImageButton;
@property (nonatomic,strong) UIButton *addTopicButton;
@property (nonatomic,strong) UIButton *addLinkButton;
@property (nonatomic,strong) CAShapeLayer *maskLayer;
@property (nonatomic,strong) UITapGestureRecognizer *tapBackgroundGesture;
@property (nonatomic,strong) UIImageView *plusImage;
@property (nonatomic,strong) UIView *plusBackgroundView;

@end

@implementation AddMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        
        self.tapBackgroundGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground)];
        self.addItemsView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 120, self.frame.size.height - 190, 240, 190)];
        
        self.groupChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.groupChatButton addTarget:self action:@selector(addGroupChat) forControlEvents:UIControlEventTouchUpInside];
        [self.groupChatButton setImage:[UIImage imageNamed:@"TopicLogoShadow"] forState:UIControlStateNormal];
        self.groupChatButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.groupChatButton.layer.shadowColor = [UIColor colorWithRed:44/255.f green:133/255.f blue:171/255.f alpha:0.2].CGColor;
        self.groupChatButton.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.groupChatButton.layer.shadowOpacity = YES;
        
        self.privateChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.privateChatButton addTarget:self action:@selector(addPrivateChat) forControlEvents:UIControlEventTouchUpInside];
        [self.privateChatButton setImage:[UIImage imageNamed:@"PrivateChatLogoShadow"] forState:UIControlStateNormal];
        self.privateChatButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.privateChatButton.layer.shadowColor = [UIColor colorWithRed:179/255.f green:51/255.f blue:34/255.f alpha:0.2].CGColor;
        self.privateChatButton.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.privateChatButton.layer.shadowOpacity = YES;
        
        self.addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addImageButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
        [self.addImageButton setImage:[UIImage imageNamed:@"ImageStoryLogoShadow"] forState:UIControlStateNormal];
        self.addImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.addImageButton.layer.shadowColor = [UIColor colorWithRed:148/255.f green:90/255.f blue:132/255.f alpha:0.2].CGColor;
        self.addImageButton.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.addImageButton.layer.shadowOpacity = YES;
        
        self.addTopicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addTopicButton addTarget:self action:@selector(addTopic) forControlEvents:UIControlEventTouchUpInside];
        [self.addTopicButton setImage:[UIImage imageNamed:@"TopicStoryLogoShadow"] forState:UIControlStateNormal];
        self.addTopicButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.addTopicButton.layer.shadowColor = [UIColor colorWithRed:184/255.f green:139/255.f blue:4/255.f alpha:0.2].CGColor;
        self.addTopicButton.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.addTopicButton.layer.shadowOpacity = YES;
        
        self.addLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addLinkButton addTarget:self action:@selector(addLink) forControlEvents:UIControlEventTouchUpInside];
        [self.addLinkButton setImage:[UIImage imageNamed:@"LinkStoryLogoShadow"] forState:UIControlStateNormal];
        self.addLinkButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.addLinkButton.layer.shadowColor = [UIColor colorWithRed:47/255.f green:122/255.f blue:84/255.f alpha:0.2].CGColor;
        self.addLinkButton.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.addLinkButton.layer.shadowOpacity = YES;
        
        self.plusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Plus"]];
        self.plusImage.tintColor = [UIColor jl_plusColor];
        self.plusBackgroundView = [[UIView alloc] init];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        //self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        [self addSubview:self.backgroundView];
        // Create a gradient layer that goes transparent -&gt; opaque
        CAGradientLayer *alphaGradientLayer = [CAGradientLayer layer];
        NSArray *colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithWhite:1 alpha:1] CGColor],
                           (id)[[UIColor colorWithWhite:1 alpha:0.8] CGColor],
                           nil];
        [alphaGradientLayer setColors:colors];
        // Start the gradient at the bottom and go almost half way up.
        [alphaGradientLayer setStartPoint:CGPointMake(0.5f, 0.8f)];
        [alphaGradientLayer setEndPoint:CGPointMake(0.5f, 0.0f)];
        [alphaGradientLayer setFrame:[self.backgroundView bounds]];
        [[self.backgroundView layer] setMask:alphaGradientLayer];
        
        [self.addItemsView addSubview:self.groupChatButton];
        [self.addItemsView addSubview:self.privateChatButton];
        [self.addItemsView addSubview:self.addImageButton];
        [self.addItemsView addSubview:self.addTopicButton];
        [self.addItemsView addSubview:self.addLinkButton];
        [self originalPosition];
        
        CGFloat plusBackgroundViewHeight = 36;
        self.plusBackgroundView.backgroundColor = [UIColor jl_redColor];
        self.plusBackgroundView.layer.masksToBounds = YES;
        self.plusBackgroundView.layer.cornerRadius = plusBackgroundViewHeight/2;
        [self.addItemsView addSubview:self.plusBackgroundView];
        [self.addItemsView addSubview:self.plusImage];
        [self.plusImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.addItemsView.mas_centerX);
            make.centerY.equalTo(self.addItemsView.mas_bottom).with.offset(-49/2.0);
            make.width.mas_equalTo(24);
            make.height.mas_equalTo(24);
        }];
        [self.plusBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.addItemsView.mas_centerX);
            make.centerY.equalTo(self.addItemsView.mas_bottom).with.offset(-49/2.0);
            make.width.mas_equalTo(plusBackgroundViewHeight);
            make.height.mas_equalTo(plusBackgroundViewHeight);
        }];
        [self.addItemsView layoutIfNeeded];
        
        [self addSubview:self.addItemsView];
        
        self.backgroundView.alpha = 0;
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:5 options:7 animations:^{
            self.backgroundView.alpha = 1.0;
            [self finalPosition];
            CGAffineTransform rotateTrasform = CGAffineTransformMakeRotation(135 * M_PI/180);
            self.plusImage.transform = rotateTrasform;
            self.plusImage.tintColor = [UIColor whiteColor];
            self.plusBackgroundView.backgroundColor = [UIColor jl_lightGrayColor];
        } completion:^(BOOL finished) {
            [self addGestureRecognizer:self.tapBackgroundGesture];
        }];
    }
}

#pragma mark - Action

- (void)addPrivateChat {
    [self.delegate onTapButtonAtIndex:0];
}

- (void)addGroupChat {
    [self.delegate onTapButtonAtIndex:1];
}

- (void)onTapBackground {
    if ([self.delegate respondsToSelector:@selector(onTapCancel)]) {
        [self.delegate onTapCancel];
    }
}

- (void)addTopic {
    [self.delegate onTapButtonAtIndex:2];
}

- (void)addImage {
    [self.delegate onTapButtonAtIndex:3];
}

- (void)addLink {
    [self.delegate onTapButtonAtIndex:4];
}

#pragma mark - Public

- (void)removeAddMenu:(void (^) (void))completion {
    self.backgroundView.alpha = 1.0;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:5 options:3<<16 animations:^{
        self.backgroundView.alpha = 0.0;
        [self originalPosition];
        
        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(0 * M_PI/180);
        self.plusImage.transform = rotateTransform;
        self.plusImage.tintColor = [UIColor jl_plusColor];

        self.plusBackgroundView.backgroundColor = [UIColor jl_redColor];
    } completion:^(BOOL finished) {
        [self removeGestureRecognizer:self.tapBackgroundGesture];
        for (UIView *subView in self.addItemsView.subviews) {
            [subView removeFromSuperview];
        }
        [self removeFromSuperview];
        completion();
    }];
    
}

#pragma mark - Animation

- (void)originalPosition {
    [self.groupChatButton setAlpha:0];
    [self.privateChatButton setAlpha:0];
    [self.addImageButton setAlpha:0];
    [self.addTopicButton setAlpha:0];
    [self.addLinkButton setAlpha:0];
    
    CGFloat originTopOffset = -49.0/2;
    [self.groupChatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addItemsView.mas_centerX);
        make.centerY.equalTo(self.addItemsView.mas_bottom).with.offset(originTopOffset);
        make.width.mas_equalTo(50);
    }];
    [self.privateChatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addItemsView.mas_centerX);
        make.centerY.equalTo(self.addItemsView.mas_bottom).with.offset(originTopOffset);
        make.width.mas_equalTo(50);
    }];
    [self.addImageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addItemsView.mas_centerX);
        make.centerY.equalTo(self.addItemsView.mas_bottom).with.offset(originTopOffset);
        make.width.mas_equalTo(50);
    }];
    [self.addTopicButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addItemsView.mas_centerX);
        make.centerY.equalTo(self.addItemsView.mas_bottom).with.offset(originTopOffset);
        make.width.mas_equalTo(50);
    }];
    [self.addLinkButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addItemsView.mas_centerX);
        make.centerY.equalTo(self.addItemsView.mas_bottom).with.offset(originTopOffset);
        make.width.mas_equalTo(50);
    }];
    [self.groupChatButton layoutIfNeeded];
    [self.privateChatButton layoutIfNeeded];
    [self.addImageButton layoutIfNeeded];
    [self.addTopicButton layoutIfNeeded];
    [self.addLinkButton layoutIfNeeded];
}

- (void)finalPosition {
    [self.groupChatButton setAlpha:1];
    [self.privateChatButton setAlpha:1];
    [self.addImageButton setAlpha:1];
    [self.addTopicButton setAlpha:1];
    [self.addLinkButton setAlpha:1];
    [self.groupChatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addItemsView.mas_left);
        make.top.equalTo(self.addItemsView.mas_top).with.offset(62);
        make.width.mas_equalTo(50);
    }];
    [self.privateChatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addItemsView.mas_left).with.offset(36);
        make.top.equalTo(self.addItemsView.mas_top).with.offset(15);
        make.width.mas_equalTo(50);
    }];
    [self.addImageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addItemsView.mas_centerX);
        make.top.equalTo(self.addItemsView.mas_top);
        make.width.mas_equalTo(50);
    }];
    [self.addTopicButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addItemsView.mas_right).with.offset(-36);
        make.top.equalTo(self.addItemsView.mas_top).with.offset(15);;
        make.width.mas_equalTo(50);
    }];
    [self.addLinkButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addItemsView.mas_right);
        make.top.equalTo(self.addItemsView.mas_top).with.offset(62);
        make.width.mas_equalTo(50);
    }];
    [self.groupChatButton layoutIfNeeded];
    [self.privateChatButton layoutIfNeeded];
    [self.addImageButton layoutIfNeeded];
    [self.addTopicButton layoutIfNeeded];
    [self.addLinkButton layoutIfNeeded];
}

#pragma mark - Private

- (UIImage *)getSnapshotOfView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
