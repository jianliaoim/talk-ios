//
//  TagsViewModel.h
//  Talk
//
//  Created by 史丹青 on 7/14/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

//#import "RVMViewModel.h"
#import "TBTag.h"
#import "ReactiveCocoa.h"

@interface TagsViewModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, strong) NSArray *searchTags;
@property (nonatomic, assign) BOOL isSearching;

- (RACSignal *)fetchAllTags;
- (RACSignal *)deleteTag:(TBTag *)tag;

@end
