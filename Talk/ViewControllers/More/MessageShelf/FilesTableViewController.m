//
//  FilesTableViewController.m
//  Talk
//
//  Created by 史丹青 on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "FilesTableViewController.h"
#import "TBMessage.h"
#import "TBFile.h"
#import "TBUser.h"
#import "NSDate+TBUtilities.h"
#import "MORoom.h"
#import "CoreData+MagicalRecord.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+TBColor.h"
#import "TBUtility.h"
#import "AZAPreviewItem.h"
#import "AZAPreviewController.h"
#import "TBHTTPSessionManager.h"
#import "MJRefresh.h"
#import "MWPhotoBrowser.h"
#import "SVProgressHUD.h"
#import "MOMessage.h"
#import "TBMenuItem.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "WelcomeView.h"
#import "PlaceHolderView.h"
#import "MOUser.h"
#import "AddTagViewController.h"
#import "TBTag.h"
#import "TBAttachment.h"
#import "ShareToTableViewController.h"

@interface FilesTableViewController () <QLPreviewControllerDelegate,QLPreviewControllerDataSource, AZAPreviewControllerDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic) NSMutableArray *previewItems;       //for preview file
@property (nonatomic) int photosCountInFilesArray;
@property (strong, nonatomic) MWPhotoBrowser *browser;

@end

@implementation FilesTableViewController

- (void)viewDidLoad {
    
    _photos = [[NSMutableArray alloc]init];
    
    //preview related
    _previewItems = [[NSMutableArray alloc]init];
    _photosCountInFilesArray = 0;
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setAlpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (void)filterDataWith:(NSDictionary *)newFilterDictionary {
    self.pageNumber = 1;
    self.photosCountInFilesArray = 0;
    self.filterDictionary = newFilterDictionary;
    [self.messagesArray removeAllObjects];
    [self.photos removeAllObjects];
    
    [self syncData];
}

#pragma mark - SyncData

- (void)syncData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    
    NSMutableDictionary *parasDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            teamID,@"_teamId",
                                            @"file",@"type",
                                            [[NSString alloc] initWithFormat:@"%d",self.pageNumber],@"page",
                                            [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"desc",@"order", nil],@"createdAt", nil],@"sort",
                                            nil];
    [parasDictionary addEntriesFromDictionary:self.filterDictionary];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kSearchURLString parameters:parasDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"response data: %@", responseObject);
        [self processFileData:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
    }];
}

- (void)processFileData:(NSDictionary *)responseObject {
    NSArray *responseFileArray = (NSArray *)[responseObject objectForKey:@"messages"];
    for (int i = 0; i < responseFileArray.count; i++) {
        TBMessage *fileMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                           fromJSONDictionary:responseFileArray[i]
                                                        error:NULL];
        fileMessage.searchCellHeight = [TBSearchMessageCell calculateCellHeightWithMessage:fileMessage];
        [self.messagesArray addObject:fileMessage];
        
        // Create array of MWPhoto objects
        for (TBAttachment *tempAttchment in fileMessage.attachments) {
            NSString *tempFileCategory =  tempAttchment.data[kFileCategory];
            if ([tempFileCategory isEqualToString:kFileCategoryImage]) {
                self.photosCountInFilesArray++;
                if (self.photosCountInFilesArray > self.photos.count) {
                    NSString *fileName = (NSString *)tempAttchment.data[kFileName];
                    NSString *fileDownloadUrlString = (NSString *)tempAttchment.data[kFileDownloadUrl];
                    NSURL *attachmentURL = [NSURL URLWithString:fileDownloadUrlString];
                    MWPhoto *photo = [MWPhoto photoWithURL:attachmentURL];
                    photo.caption = fileName;
                    photo.messageID = fileMessage.id;
                    photo.tagsArray = fileMessage.tags;
                    [self.photos addObject:photo];
                }
            }
        }
    }
    
    self.messagesTotal = [(NSNumber *)[responseObject objectForKey:@"total"] integerValue];
    
    [self setMJRefresh];
    if (self.messagesTotal/10 < self.pageNumber) {
        [self.tableView.footer noticeNoMoreData];
    }

    self.pageNumber++;
    [self.tableView reloadData];
    
    if (self.messagesArray.count == 0) {
        self.tableView.tableFooterView = self.noItemsplaceHolder;
        [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
    } else {
        self.tableView.tableFooterView = [[UIView alloc]init];
        [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
    }
}

- (void)loadMoreImage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    unsigned long photosPage = self.photos.count/10 + 1;
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kSearchURLString parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                              teamID,@"_teamId",
                                              @"file",@"type",
                                              @"image",@"fileCategory",
                                              [[NSString alloc] initWithFormat:@"%lul",photosPage],@"page",
                                              [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"desc",@"order", nil],@"createdAt", nil],@"sort",
                                              nil] success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"response data: %@", responseObject);
        [self processImageData:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
    }];
}

- (void) processImageData:(NSDictionary *)responseObject {
    self.photosTotal = [(NSNumber *)[responseObject objectForKey:@"total"] integerValue];
    NSArray *responseFileArray = (NSArray *)[responseObject objectForKey:@"messages"];
    for (int i = self.photos.count%10; i < responseFileArray.count; i++) {
        TBMessage *fileMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                           fromJSONDictionary:responseFileArray[i]
                                                        error:NULL];
        for (TBAttachment *tempAttchment in fileMessage.attachments) {
            NSString *fileName = (NSString *)tempAttchment.data[kFileName];
            NSString *fileDownloadUrlString = (NSString *)tempAttchment.data[kFileDownloadUrl];
            NSURL *attachmentURL = [NSURL URLWithString:fileDownloadUrlString];
            MWPhoto *photo = [MWPhoto photoWithURL:attachmentURL];
            photo.messageID = fileMessage.id;
            photo.creatorID = fileMessage.creatorID;
            photo.caption = fileName;
            photo.tagsArray = fileMessage.tags;
            [self.photos addObject:photo];
        }
    }
    [self.browser setContenSizeWithNumber:self.photos.count];
    //[self.browser reloadData];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TBMessage *model = self.messagesArray[indexPath.row];
    TBAttachment *attachment = model.attachments.firstObject;
    NSString *fileCategory =  attachment.data[kFileCategory];
    if ([fileCategory isEqualToString:kFileCategoryImage]) {
        // Create browser (must be done each time photo browser is
        // displayed. Photo browser objects cannot be re-used)
        self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        // Set options
        self.browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
        self.browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        self.browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
        self.browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
        self.browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
        self.browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        self.browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        //browser.wantsFullScreenLayout = YES;// iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
        
        // Optionally set the current visible photo before displaying
        int currentPhotoIndex = -1;
        for (int i = 0; i <= indexPath.row; i++) {
            TBMessage *fileMessage = self.messagesArray[i];
            for (TBAttachment *tempAttchment in fileMessage.attachments) {
                NSString *tempFileCategory =  tempAttchment.data[kFileCategory];
                if ([tempFileCategory isEqualToString:kFileCategoryImage]) {
                    currentPhotoIndex++;
                }
            }
        }
        [self.browser setCurrentPhotoIndex:currentPhotoIndex];
        // Present
        [self.navigationController pushViewController:self.browser animated:YES];
        
        // Manipulate
        [self.browser showNextPhotoAnimated:YES];
        [self.browser showPreviousPhotoAnimated:YES];
        
    } else {
        // Remote files
        NSURL *filePreviewItemURL = [NSURL URLWithString:attachment.data[kFileDownloadUrl]];
        NSString *fileName = attachment.data[kFileName];
        NSString *filekey = attachment.data[kFileKey];
        CGFloat fileSize = [attachment.data[kFileSize] floatValue];
        AZAPreviewItem *filePreviewItem = [AZAPreviewItem previewItemWithURL:filePreviewItemURL
                                                                       title:fileName
                                                                     fileKey:filekey];
        filePreviewItem.fileSize = fileSize;
        [_previewItems removeAllObjects];
        [_previewItems addObjectsFromArray:[NSArray arrayWithObjects:filePreviewItem, nil]];
        // preview controller
        AZAPreviewController *previewController = [[AZAPreviewController alloc] init];
        previewController.navigationController.navigationBar.translucent = NO;
        previewController.dataSource = self;
        previewController.delegate = self;
        [self.navigationController pushViewController:previewController animated:YES];
    }
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [self.previewItems count];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.previewItems[index];
}

#pragma mark - AZAPreviewControllerDelegate

- (void)AZA_previewController:(AZAPreviewController *)controller failedToLoadRemotePreviewItem:(id<QLPreviewItem>)previewItem withError:(NSError *)error
{
    NSString *alertTitle = NSLocalizedString(@"Failed to load", @"Failed to load");
    NSString *alertMessage = [error localizedDescription];
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] show];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    return nil;
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    MWPhoto *photo =[self.photos  objectAtIndex:index];
    return photo.caption;
}

// star and delete action
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser starPhotoAtIndex:(NSUInteger)index {
    MWPhoto *photo =[self.photos  objectAtIndex:index];
    [self favoriteMessageWithID:photo.messageID];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser tagPhotoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [self.photos  objectAtIndex:index];
    [self addTagWithID:photo.messageID withArray:photo.tagsArray];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser forwardPhototAtIndex:(NSUInteger)index {
    MWPhoto *photo = [self.photos  objectAtIndex:index];
    [self forwardMessageWithMessageIdArray:[NSArray arrayWithObject:photo.messageID]];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deletePhototAtIndex:(NSUInteger)index {
    MWPhoto *photo =[self.photos  objectAtIndex:index];
    [self deleteMessageWithMessageID:photo.messageID andPhotoBrowser:photoBrowser];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
    if (index == self.photos.count - 1 && self.photosTotal != self.photos.count) {
        [self loadMoreImage];
        self.browser.needToReload = YES;
    }
}

@end
