//
//  GuideHelper.h
//  Talk
//
//  Created by 史丹青 on 7/30/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGuideInit                              @"GuideInit"
#define kGuideWelcome                           @"GuideWelcome"
#define kGuideMessageShelf                      @"GuideMessageShelf"
#define kGuideMessageShelfButtonInChat          @"GuideMessageShelfButtonInChat"

@interface GuideHelper : NSObject

+ (BOOL)checkIsNeedGuideByKey:(NSString *)key;

@end
