//
//  JLStoryEditorViewController.h
//  Talk
//
//  Created by 王卫 on 15/11/11.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
@class MOStory;

@protocol JLStoryEditorViewControllerDelegate <NSObject>

@optional
- (void)storyEditorDidUpdate:(MOStory *)story;
- (void)hasCreateStoryWithCategory:(NSString *)category StoryData:(NSDictionary *)topicData;

@end

@interface JLStoryEditorViewController : UIViewController

@property (copy, nonatomic) NSString *category;
@property (weak, nonatomic) id<JLStoryEditorViewControllerDelegate> delegate;

- (instancetype)initWithStory:(MOStory *)story;

@end
