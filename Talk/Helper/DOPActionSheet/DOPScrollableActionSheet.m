//
//  DOPScrollableActionSheet.m
//  DOPScrollableActionSheet
//
//  Created by weizhou on 12/27/14.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import "DOPScrollableActionSheet.h"

static CGFloat horizontalMargin = 20.0;
static CGFloat scrollViewHeight = 100.0;

@interface DOPScrollableActionSheet ()

@property (nonatomic, assign) CGRect         screenRect;
@property (nonatomic, strong) UIWindow       *window;
@property (nonatomic, strong) UIView         *dimBackground;
@property (nonatomic, copy  ) NSArray        *actions;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *handlers;
@property (nonatomic, copy) void(^dismissHandler)(void);

@end

@implementation DOPScrollableActionSheet

- (instancetype)initWithActionArray:(NSArray *)actions {
    self = [super init];
    if (self) {
        _screenRect = [UIScreen mainScreen].bounds;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.5 &&
            UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            _screenRect = CGRectMake(0, 0, _screenRect.size.height, _screenRect.size.width);
        }
        _actions = actions;
        _buttons = [NSMutableArray array];
        _handlers = [NSMutableArray array];
        _dimBackground = [[UIView alloc] initWithFrame:_screenRect];
        //_dimBackground.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_dimBackground addGestureRecognizer:gr];
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
    
        NSInteger rowCount = _actions.count;
    
        /*calculate action sheet frame begin*/
        //row title screenwidth*40 without row title margin screenwidth*20
        //60*60 icon 60*30 icon name
        CGFloat height = 0.0;
        for (int i = 0; i < rowCount; i++) {
            if ([_actions[i] isKindOfClass:[NSString class]]) {
                if ([_actions[i] isEqualToString:@""]) {
                    height += 20;
                } else {
                    height += 40;
                }
            } else {
                height = height + scrollViewHeight;
            }
        }
        //cancel button screenwidth*60
        height += 60;
        /*calculation end*/
        self.frame = CGRectMake(0, _screenRect.size.height, _screenRect.size.width, height);
        
        //add each row
        CGFloat y = 0.0;
        for (int i = 0; i < rowCount; i++) {
            if ([_actions[i] isKindOfClass:[NSString class]]) {
                //title
                if ([_actions[i] isEqualToString:@""]) {
                    UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, 20.0)];
                    [self addSubview:marginView];
                    y+=20;
                } else {
                    UILabel *rowTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, 40.0)];
                    rowTitle.font = [UIFont systemFontOfSize:14.0];
                    rowTitle.text = _actions[i];
                    rowTitle.textAlignment = NSTextAlignmentCenter;
                    [self addSubview:rowTitle];
                    y+=40;
                }
            } else {
                NSArray *items = _actions[i];
                //actions array
                UIScrollView *rowContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, scrollViewHeight)];
                rowContainer.directionalLockEnabled = YES;
                rowContainer.showsHorizontalScrollIndicator = NO;
                rowContainer.showsVerticalScrollIndicator = NO;
                rowContainer.contentSize = CGSizeMake(items.count*80+60, scrollViewHeight);
                [self addSubview:rowContainer];
                //add each item
                CGFloat x = horizontalMargin;
                for (int j = 0; j < items.count; j++) {
                    DOPAction *action = items[j];
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(x, 0, 60, 60);
                    [button setImage:[UIImage imageNamed:action.iconName] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(handlePress:) forControlEvents:UIControlEventTouchUpInside];
                    [rowContainer addSubview:button];
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 65, 60, 20)];
                    label.text = action.actionName;
                    if ([action.actionName isEqualToString:NSLocalizedString(@"Open in safari", @"Open in safari")]) {
                        label.frame = CGRectMake(x, 65, 60, 36);
                    }
                    label.font = [UIFont systemFontOfSize:13.0];
                    label.numberOfLines = 0;
                    label.textAlignment = NSTextAlignmentCenter;
                    [rowContainer addSubview:label];
                    x = x + 60 + horizontalMargin;
                    
                    [_buttons addObject:button];
                    [_handlers addObject:action.handler];
                }
                y+=scrollViewHeight;
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, y + 10, _screenRect.size.width,0.5)];
                separator.backgroundColor = [UIColor lightGrayColor];
                [self addSubview:separator];
            }
        }
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
        cancel.frame = CGRectMake(0, y, _screenRect.size.width, 60);
        [cancel setTitle:NSLocalizedString(@"Cancel", @"cancel button name") forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancel.titleLabel.font = [UIFont systemFontOfSize:20];
        cancel.backgroundColor = [UIColor whiteColor];
        [self addSubview:cancel];
        [cancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)handlePress:(UIButton *)button {
    NSInteger index = [self.buttons indexOfObject:button];
    void(^handler)(void) = self.handlers[index];
    handler();
    [self dismiss];
}

- (void)show {
    self.dimBackground.backgroundColor = [UIColor clearColor];
    self.window = [[UIWindow alloc] initWithFrame:self.screenRect];
    self.window.windowLevel = UIWindowLevelStatusBar + 1.0;
    self.window.rootViewController = [UIViewController new];
    self.window.hidden = NO;
    [self.window makeKeyAndVisible];
    UIView *rootView = self.window.rootViewController.view;
    [rootView addSubview:self.dimBackground];
    [rootView bringSubviewToFront:self.dimBackground];
    [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.dimBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    } completion:nil];
    
    [self.dimBackground addSubview:self];
    [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = CGRectMake(0, self.screenRect.size.height-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:nil];

}

- (void)dismiss {
    [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.dimBackground.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, self.screenRect.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self.dimBackground removeFromSuperview];
        self.window.hidden = YES;
        [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
    }];
}

@end

@implementation DOPAction

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName handler:(void(^)(void))handler {
    self = [super init];
    if (self) {
        _actionName = name;
        _iconName = iconName;
        _handler = handler;
    }
    return self;
}

@end
