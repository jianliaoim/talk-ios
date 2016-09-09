//
//  AddTagViewModel.h
//  Talk
//
//  Created by 史丹青 on 7/13/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

#import "RVMViewModel.h"
#import "ReactiveCocoa.h"

@interface AddTagViewModel : RVMViewModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *selectedTags;

- (RACSignal *)fetchAllTags;
- (RACSignal *)addNewTag:(NSString *)name;
- (RACSignal *)addTagToMessage;

@end
