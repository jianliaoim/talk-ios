//
//  AZAPreviewItem.m
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13. update by zhangxiaolian 0n 2014 -10-17
//  Copyright (c) 2013 Alexander Zats and teambition. All rights reserved.//

#import "AZAPreviewItem.h"

@interface AZAPreviewItem () {
	BOOL _loadingItem;
}
@end

@implementation AZAPreviewItem
@synthesize previewItemURL = _previewItemURL;

+ (AZAPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title fileKey:(NSString *)fileKey
{
	AZAPreviewItem *instance = [[AZAPreviewItem alloc] init];
	instance.previewItemURL = URL;
	instance.previewItemTitle = title;
    instance.fileKey = fileKey;
    instance.fileSize = 0;
	return instance;
}

@end
