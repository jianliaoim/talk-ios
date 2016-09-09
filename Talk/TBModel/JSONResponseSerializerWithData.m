//
// Created by Shire on 9/18/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (*error != nil) {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];

            id responseObject = nil;
            NSError *serializationError = nil;
            if (data) {
                if ([data length] > 0) {
                    responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];
                    id msg = responseObject[@"message"];
                    if (msg) {
                        userInfo[NSLocalizedRecoverySuggestionErrorKey] = msg;
                    }
                } else {
                    return nil;
                }
            }

            NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
            (*error) = newError;
        }

        return (nil);
    }

    return ([super responseObjectForResponse:response data:data error:error]);
}

@end