//
//  AZAPreviewItem.h
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13. update by zhangxiaolian 0n 2014 -10-17
//  Copyright (c) 2013 Alexander Zats and teambition. All rights reserved.
//

#import <QuickLook/QuickLook.h>

/*
 Default implementation of QLPreviewItem protocol
 */
@interface AZAPreviewItem : NSObject <QLPreviewItem>

+ (AZAPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title fileKey:(NSString *)fileKey;

@property (readwrite, nonatomic) NSURL *previewItemURL;
@property (readwrite, nonatomic) NSString *previewItemTitle;
@property (readwrite, nonatomic) NSString *fileKey;
@property (readwrite) CGFloat fileSize;

@end
