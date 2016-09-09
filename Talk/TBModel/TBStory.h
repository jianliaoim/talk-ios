//
//  TBStory.h
//  Talk
//
//  Created by 史丹青 on 10/20/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBStory : TBModelObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *creatorID;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, copy) NSString *teamID;
@property (nonatomic, strong) NSArray *members;

@end
