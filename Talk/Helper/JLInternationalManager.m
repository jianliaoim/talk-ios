//
//  JLInternationalManager.m
//  Talk
//
//  Created by 王卫 on 16/1/19.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "JLInternationalManager.h"

static NSBundle *bundle = nil;
static NSString *const kZHHans = @"zh-Hans";
static NSString *const kEn = @"en";

@implementation JLInternationalManager

+ (NSBundle *)currentLanguageBundle {
    if (!bundle) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *systemLanguage = [NSBundle preferredLocalizationsFromArray:[JLInternationalManager availableLanguages]].firstObject;
        if (!systemLanguage) {
            systemLanguage = kEn;
        }
        NSString *userLanguage = [userDefaults valueForKey:kUserLanguage];
        
        if (!userLanguage) {
            userLanguage = systemLanguage;
        }
        [userDefaults setValue:userLanguage forKey:kUserLanguage];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:userLanguage ofType:@"lproj"];
        bundle = [NSBundle bundleWithPath:path] ?: [NSBundle mainBundle];
    }
    return bundle;
}

+ (NSArray *)availableLanguages {
    return @[kZHHans, kEn];
}

+ (NSString *)mapLanguageKeyToName:(NSString *)key {
    NSDictionary *mapDict = @{kZHHans:@"简体中文",
             kEn:@"English"};
    return mapDict[key];
}

+ (JLUserLanguage)userLanguage {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *systemLanguage = [NSBundle preferredLocalizationsFromArray:[JLInternationalManager availableLanguages]].firstObject;
    NSString *userLanguage = [userDefaults valueForKey:kUserLanguage];
    if (!systemLanguage) {
        systemLanguage = kEn;
    }
    
    if (!userLanguage) {
        userLanguage = systemLanguage;
    }
    return [[JLInternationalManager availableLanguages] indexOfObject:userLanguage];
}

+ (NSString *)userLanguageString {
    JLUserLanguage userLanguage = [JLInternationalManager userLanguage];
    NSString *languageKey = [[JLInternationalManager availableLanguages] objectAtIndex:userLanguage];
    return [JLInternationalManager mapLanguageKeyToName:languageKey];
}

+ (void)setUserLanguage:(JLUserLanguage)userLanguage {
    bundle = nil;
    NSString *language = nil;
    switch (userLanguage) {
        case JLUserLanguageZHHans:
            language = [JLInternationalManager availableLanguages].firstObject;
            break;
        case JLUserLanguageEN:
            language = [[JLInternationalManager availableLanguages] objectAtIndex:1];
            break;
    }
    if (language) {
        [[NSUserDefaults standardUserDefaults] setValue:language forKey:kUserLanguage];
    }
}

@end
