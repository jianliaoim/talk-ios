//
//  AddMenuView.h
//  Talk
//
//  Created by 史丹青 on 10/13/15.
//  Copyright © 2015 jiaoliao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddMenuViewDelegate <NSObject>

- (void)onTapButtonAtIndex:(NSInteger)index;
- (void)onTapCancel;

@end

@interface AddMenuView : UIView

@property (nonatomic, weak) id<AddMenuViewDelegate> delegate;

- (void)removeAddMenu:(void (^) (void))completion;

@end
