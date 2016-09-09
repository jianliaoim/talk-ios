//
//  TBAttachment.m
//  
//
//  Created by Suric on 15/8/4.
//
//

#import "TBAttachment.h"
#import "DictionaryToDataTransformer.h"
#import "TBMessage.h"
#import "constants.h"
#import "TBUtility.h"

@implementation TBAttachment

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    _text = [TBUtility getStringWithoutHtmlFromString:self.data[kQuoteText]];
    if (_text.length == 0 && [self.category isEqualToString:kDisplayModeSnippet]) {
        _text = self.data[kQuoteText];
    }
    
    return self;
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValuesForKeysWithDictionary:@{@"id" : @"_id"}];
    return dictionary;
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Attachment";
}

+(NSDictionary *)relationshipModelClassesByPropertyKey{
    return @{@"message" : [TBMessage class]};
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    NSDictionary *dictionary = [NSDictionary dictionary];
    return dictionary;
}

+ (NSValueTransformer *)dataEntityAttributeTransformer {
    return [[DictionaryToDataTransformer alloc] init];
}

@end
