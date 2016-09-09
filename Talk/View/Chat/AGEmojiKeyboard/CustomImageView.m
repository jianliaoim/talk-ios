//
//  CustomImageView.h
//  EmojiKeyBoard
//
//  Created by WangMac on 14-7-19.
//  Copyright (c) 2014年 Meitu. All rights reserved.
//

#import "CustomImageView.h"
#import "UIColor+TBColor.h"

#define kButtonGap [UIScreen mainScreen].bounds.size.width/7
#define kSeperatorGap [UIScreen mainScreen].bounds.size.width/7
#define kLeftMargin 0
#define kButtonWidth [UIScreen mainScreen].bounds.size.width/7
#define kSeperatorWidth 0
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kImageViewOffsetX 0
#define kLeftSeperatorOffsetX 4
#define kRightSeperatorOffsetX 4

#define kTitleLableFont 14

@interface CustomImageView()

@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UIImageView *rightImageView;
@property (nonatomic,strong) NSArray *buttonNormalImages;
@property (nonatomic,strong) NSArray *buttonSelectedImages;
@property (nonatomic,strong) UIImage *leftCornerImage;
@property (nonatomic,strong) UIImage *rightCornerImage;
@property (nonatomic,assign) NSUInteger selectedIndex;

@end

@implementation CustomImageView

- (instancetype)initWithFrame:(CGRect)frame
           buttonNormalImages:(NSArray *)imageArrary
         buttonSelectedImages:(NSArray *)selectedImageArray
              leftCornerImage:(UIImage *)left
             rightCornerImage:(UIImage *)right
                     delegate:(id<ButtonIndexChangedDelegate>)indexChangedDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    _buttonNormalImages = imageArrary;
    _buttonSelectedImages = selectedImageArray;
    _leftCornerImage = left;
    _rightCornerImage = right;
    _selectedIndex = 1;
    _indexChangedDelegate = indexChangedDelegate;
    [self initButtonsWithImageArray:_buttonNormalImages];
  }
  return self;
}

- (void)initButtonsWithImageArray:(NSArray *)imageArray{
    
    for (int i = 0; i < imageArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kLeftMargin + kButtonGap * i, 0, kButtonWidth, CGRectGetHeight(self.bounds));
        if (i == 0) {
            _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kButtonGap - kImageViewOffsetX, 0, kScreenWidth - kButtonGap + kImageViewOffsetX, CGRectGetHeight(self.bounds))];
            UIEdgeInsets rightInset = UIEdgeInsetsMake(0,8,0,0);
            UIImage *iamge = [_rightCornerImage resizableImageWithCapInsets:rightInset resizingMode:UIImageResizingModeStretch];
            _rightImageView.image = iamge;
            [self addSubview:_rightImageView];
            
            _leftImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            [self addSubview:_leftImageView];
            [btn setImage:_buttonSelectedImages[0] forState:UIControlStateNormal];
            [self showSeperatorAtIndex:i + 1];
        }
        else{
            if (i == imageArray.count - 1) {
                NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:kTitleLableFont],NSForegroundColorAttributeName : [UIColor whiteColor]};
                NSAttributedString *buttonTittleStr = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"Send", @"Send") attributes:attributes];
                [btn setAttributedTitle:buttonTittleStr forState:UIControlStateNormal];
                [btn setTintColor:[UIColor jl_redColor]];
                UIImage *sendIamge = [[UIImage imageNamed:@"icon-button-highlight"]resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
                [btn setBackgroundImage:[sendIamge imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
            }else{
                [btn setImage:imageArray[i] forState:UIControlStateNormal];
            }
        }
        btn.tag = i + 1;
        if (i == imageArray.count - 1) {
            [btn addTarget:self action:@selector(backspacePressed) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(kLeftMargin + kButtonGap * i - kSeperatorWidth -1, 1, kButtonWidth + 1, CGRectGetHeight(self.bounds));
        }else{
            [btn addTarget:self action:@selector(segButtonChanged:) forControlEvents:UIControlEventTouchDown];
        }
        
        [self addSubview:btn];
    }
}

- (void)segButtonChanged:(UIButton *)sender{
    if (_selectedIndex == sender.tag) {
        return;
    }
    
    //取消上一次的选择
    [self setSegButtonAtIndex:_selectedIndex isSelected:NO];
    
    //显示这一次的选择
    _selectedIndex = sender.tag;
    [self setSegButtonAtIndex:_selectedIndex isSelected:YES];
    [self showSeperatorAtIndex:_selectedIndex];
    if ([_indexChangedDelegate respondsToSelector:@selector(segButtonDidChanged:)]) {
        [_indexChangedDelegate segButtonDidChanged:sender];
    }
}

- (void)backspacePressed{
    if ([_indexChangedDelegate respondsToSelector:@selector(backspaceButtonDidPress)]) {
        [_indexChangedDelegate backspaceButtonDidPress];
    }
}

- (void)setSegButtonAtIndex:(NSUInteger)index isSelected:(BOOL)isSelected{
    if (isSelected) {
        UIButton *btn = (UIButton *)[self viewWithTag:index];
        [btn setImage:_buttonSelectedImages[index - 1] forState:UIControlStateNormal];
        
        _leftImageView.frame = CGRectMake(0, 0, (index - 1) * kButtonGap - 1, CGRectGetHeight(self.bounds));
        UIEdgeInsets leftInset = UIEdgeInsetsMake(0,0,0,8);
        UIImage *leftIamge = [_leftCornerImage resizableImageWithCapInsets:leftInset resizingMode:UIImageResizingModeStretch];
        _leftImageView.image = leftIamge;
        
        _rightImageView.frame = CGRectMake(kButtonGap + (index - 1) * kButtonGap - kImageViewOffsetX, 0, kScreenWidth - kButtonGap + (index - 1) * kButtonGap + kImageViewOffsetX, CGRectGetHeight(self.bounds));
        UIEdgeInsets rightInset = UIEdgeInsetsMake(0,8,0,0);
        UIImage *rightIamge = [_rightCornerImage resizableImageWithCapInsets:rightInset resizingMode:UIImageResizingModeStretch];
        _rightImageView.image = rightIamge;
        if (index == 1) {
            _leftImageView.frame = CGRectZero;
        }
    }else{
        UIButton *btn = (UIButton *)[self viewWithTag:index];
        [btn setImage:_buttonNormalImages[index - 1] forState:UIControlStateNormal];
    }
}

- (void)showSeperatorAtIndex:(NSUInteger)index{
    [_rightImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_leftImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    switch (index) {
        case 1:
            //左0右5
            for (int i = 0; i < 5; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1) - kRightSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            break;
        case 2:
            //左0右4
            for (int i = 0; i < 4; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1) - kRightSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            break;
        case 3:
            //左1右3
        {
            for (int i = 0; i < 3; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1) - kRightSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap - kLeftSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
            seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
            [_leftImageView addSubview:seperator];
        }
            break;
        case 4:
            //左2右2
        {
            for (int i = 0; i < 2; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1) - kRightSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            for (int i = 0; i < 2; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1) - kLeftSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_leftImageView addSubview:seperator];
            }
        }
            break;
        case 5:
            //左3右1
        {
            for (int i = 0; i < 3; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1) - kLeftSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_leftImageView addSubview:seperator];
            }
            UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap - kRightSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
            seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
            [_rightImageView addSubview:seperator];
        }
            break;
        case 6:
            //左4右0
            for (int i = 0; i < 4; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1) - kLeftSeperatorOffsetX, 0, 8, CGRectGetHeight(self.bounds))];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_leftImageView addSubview:seperator];
            }
            break;
        default:
            break;
    }
}

@end
