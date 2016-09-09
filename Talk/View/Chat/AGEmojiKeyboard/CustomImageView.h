//
//  CustomImageView.h
//  EmojiKeyBoard
//
//  Created by WangMac on 14-7-19.
//  Copyright (c) 2014年 Meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ButtonIndexChangedDelegate <NSObject>
@optional
- (void)segButtonDidChanged:(UIButton *)sender;
- (void)backspaceButtonDidPress;

@end

@interface CustomImageView : UIImageView

@property (nonatomic,strong) UIImage *seperatorImage;
@property (nonatomic,weak) id<ButtonIndexChangedDelegate>indexChangedDelegate;

- (instancetype)initWithFrame:(CGRect)frame
           buttonNormalImages:(NSArray *)imageArrary
         buttonSelectedImages:(NSArray *)selectedImageArray
              leftCornerImage:(UIImage *)left
             rightCornerImage:(UIImage *)right
                     delegate:(id<ButtonIndexChangedDelegate>)indexChangedDelegate;

@end
