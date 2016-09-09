//
//  GuideHelper.m
//  Talk
//
//  Created by 史丹青 on 7/30/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "GuideHelper.h"

@implementation GuideHelper

+ (BOOL)checkIsNeedGuideByKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShown = [defaults boolForKey:key];
    if (hasShown) {
        return NO;
    } else {
        [defaults setBool:YES forKey:key];
        return YES;
    }
}

@end
