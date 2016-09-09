//
//  JLShareViewController.h
//  Talk
//
//  Created by 王卫 on 15/11/25.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLShareExtensionDelegate <NSObject>

- (void)hideExtensionAfterCancel;
- (void)hideExtensionAfterPost;
- (void)updateContainerHeight:(CGFloat)height;

@end

@interface JLShareViewController : UIViewController

@end
