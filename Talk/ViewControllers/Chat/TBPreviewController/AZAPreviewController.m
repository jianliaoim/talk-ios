//
//  AZAPreviewController.m
//  RemoteQuickLook
//
//  Created by Alexander Zats on 2/17/13. update by zhangxiaolian 0n 2014 -10-17
//  Copyright (c) 2013 Alexander Zats and jiaoliao. All rights reserved.
//

#import "AZAPreviewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import "AZAPreviewItem.h"

#import "SVProgressHUD.h"
#import "UIColor+TBColor.h"
#import <MMMarkdown.h>
#import "Reachability.h"

static NSString *AZALocalFilePathForURL(NSURL *URL,NSString *fileKey,NSString *fileType) {
	NSString *fileExtension = fileType;
	NSString *hashedURLString = fileKey;
	NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"com.jiaoliao.RemoteQuickLook"];
	BOOL isDirectory;
	if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
															withIntermediateDirectories:YES
																			 attributes:nil
																				  error:&error];
		if (!isDirectoryCreated) {
			NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
															 reason:@"Failed to crate cache directory"
														   userInfo:@{ NSUnderlyingErrorKey : error }];
			@throw exception;
		}
	}
	NSString *temporaryFilePath = [[cacheDirectory stringByAppendingPathComponent:hashedURLString] stringByAppendingPathExtension:fileExtension];
	return temporaryFilePath;
}


@interface AZAPreviewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpClient;
@property (nonatomic, weak) id<QLPreviewControllerDataSource> actualDataSource;
@end

@implementation AZAPreviewController

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	// Base URL doesn't matter since we're
	NSURL *baseURL = [NSURL URLWithString:@"http://example.com"];
	self.httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
	return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
}

-(void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    [super viewWillDisappear:YES];
}

#pragma mark - Properties

- (void)setDataSource:(id<QLPreviewControllerDataSource>)dataSource {
	self.actualDataSource = dataSource;
	[super setDataSource:self];
}

- (id<QLPreviewControllerDataSource>)dataSource {
	return self.actualDataSource;
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
	return [self.actualDataSource numberOfPreviewItemsInPreviewController:controller];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
	AZAPreviewItem<QLPreviewItem> *originalPreviewItem = [self.actualDataSource previewController:controller previewItemAtIndex:index];
	AZAPreviewItem *previewItemCopy = [AZAPreviewItem previewItemWithURL:originalPreviewItem.previewItemURL
																   title:originalPreviewItem.previewItemTitle
                                                                fileKey:originalPreviewItem.fileKey];
    previewItemCopy.fileSize = originalPreviewItem.fileSize;
	NSURL *originalURL = previewItemCopy.previewItemURL;
	if (!originalURL || [originalURL isFileURL]) {
		return previewItemCopy;
	}
	// If it's a remote file, check cache
    NSString *fileType = [previewItemCopy.previewItemTitle componentsSeparatedByString:@"."].lastObject;
	NSString *localFilePath = AZALocalFilePathForURL(originalURL,previewItemCopy.fileKey,fileType);
	previewItemCopy.previewItemURL = [NSURL fileURLWithPath:localFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        if (![fileType isEqualToString:@"md"]) {
            return previewItemCopy;
        }
        NSString *HTMLFileType = @"html";
        NSString *localHTMLPath = AZALocalFilePathForURL(originalURL, previewItemCopy.fileKey, HTMLFileType);
        if ([[NSFileManager defaultManager] fileExistsAtPath:localHTMLPath]) {
            previewItemCopy.previewItemURL = [NSURL fileURLWithPath:localHTMLPath];
            return previewItemCopy;
        }
        NSString *markdownString = [NSString stringWithContentsOfFile:localFilePath encoding:NSUTF8StringEncoding error:nil];
        if (!markdownString) {
            return previewItemCopy;
        }
        NSString *HTMLString = [MMMarkdown HTMLStringWithMarkdown:markdownString extensions:MMMarkdownExtensionsNone error:nil];
        NSString *HTMLMeta = @"<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=1\">\n";
        NSString *finalHTMLString = [HTMLMeta stringByAppendingString:HTMLString];
        [finalHTMLString writeToFile:localHTMLPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        previewItemCopy.previewItemURL = [NSURL fileURLWithPath:localHTMLPath];
        return previewItemCopy;
    } else {
        BOOL isCellular = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN ? YES : NO;
        if (previewItemCopy.fileSize > (500 * 1024) && isCellular) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Download via cellular network?", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Download", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self loadItemWithOriginalURL:originalURL filePath:localFilePath previewController:controller originalPreviewItem:originalPreviewItem];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:sureAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:YES completion:nil];
                alertController.view.tintColor = [UIColor jl_redColor];
            });
        } else {
            [self loadItemWithOriginalURL:originalURL filePath:localFilePath previewController:controller originalPreviewItem:originalPreviewItem];
        }
    }
	return previewItemCopy;
}

- (void)loadItemWithOriginalURL:(NSURL *)originalURL filePath:(NSString *)localFilePath previewController:(QLPreviewController *)controller originalPreviewItem:(AZAPreviewItem<QLPreviewItem> *)originalPreviewItem {
    [SVProgressHUD showProgress:0 status:NSLocalizedString(@"Loading...", @"Loading...") maskType:SVProgressHUDMaskTypeNone];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:originalURL];
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    requestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:localFilePath append:NO];
    [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat progress = (totalBytesRead*1.0) / totalBytesExpectedToRead;
        [SVProgressHUD sharedView].progress = progress;
    }];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            [controller refreshCurrentPreviewItem];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:localFilePath error:NULL];
        }
        if ([self.delegate respondsToSelector:@selector(AZA_previewController:failedToLoadRemotePreviewItem:withError:)]) {
            [self.delegate AZA_previewController:self
                   failedToLoadRemotePreviewItem:originalPreviewItem
                                       withError:error];
        }
    }];
    [self.httpClient.operationQueue addOperation:requestOperation];
}

@end
