//
//  JLInternationalManager.h
//  Talk
//
//  Created by 王卫 on 16/1/19.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserLanguage @"userLanguage"

typedef NS_ENUM(NSUInteger, JLUserLanguage) {
    JLUserLanguageEN,
    JLUserLanguageZHHans,
};

@interface JLInternationalManager : NSObject

+ (NSBundle *)currentLanguageBundle;
+ (JLUserLanguage)userLanguage;
+ (NSString *)userLanguageString;
+ (void)setUserLanguage:(JLUserLanguage)userLanguage;
+ (NSArray *)availableLanguages;
+ (NSString *)mapLanguageKeyToName:(NSString *)key;

@end
