//
//  JLStoryView.m
//  Talk
//
//  Created by 王卫 on 15/11/9.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLStoryView.h"
#import "constants.h"
#import "MOStory.h"
#import "JLStoryEditorViewController.h"
#import "MOUser.h"
#import "NSDate+TBUtilities.h"
#import "TBUtility.h"
#import "AZAPreviewController.h"
#import "AZAPreviewItem.h"
#import "JLWebViewController.h"
#import "UIFont+TBUtilities.h"
#import "UIColor+TBColor.h"
#import "MWPhotoBrowser.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <Masonry.h>
#import <CoreData+MagicalRecord.h>
#import <NSDate+MTDates.h>

@interface JLStoryView ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate, AZAPreviewControllerDelegate, MWPhotoBrowserDelegate>
//Content View
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *expandedContentView;

//content view
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *linkLabel;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *fileButton;
//expand content view
@property (strong, nonatomic) UIButton *expandedLinkButton;
@property (strong, nonatomic) UILabel *expandedInfoLabel;
@property (strong, nonatomic) UILabel *expandedTitleLabel;
@property (strong, nonatomic) UIImageView *expandedImageView;
@property (strong, nonatomic) UITextView *detailTextView;
@property (strong, nonatomic) UIView *fileView;
@property (strong, nonatomic) UIButton *expandedFileButton;
//navigation bar
@property (strong, nonatomic) NSArray *rightBarButtonItems;
@property (strong, nonatomic) UIView *maskView;

@property (strong, nonatomic) MOStory *story;
@property (strong, nonatomic) NSDictionary *storyData;
@property (strong, nonatomic) NSMutableArray *previewItems;
@property (strong, nonatomic) NSString *imageUrl;

@property (nonatomic) CGRect fullFrame;
@property (assign, nonatomic) BOOL isExpand;
@property (assign, nonatomic) BOOL permission;
@property (assign, nonatomic) BOOL needRefresh;

@end

static CGFloat const EdgeInsetLeft = 16;
static CGFloat const DefaultSpacing = 8;
static CGFloat const JLStoryViewImageSizeLarge = 64;
static CGFloat const JLStoryViewImageSizeSmall = 40;

static CGFloat const JLStoryViewExpandImageDefaultHeight = 158;

@implementation JLStoryView

- (instancetype)initWithFrame:(CGRect)frame story:(MOStory *)story {
    self.story = story;
    self.storyData = story.data;
    self.fullFrame = frame;
    
    CGRect newFrame = frame;
    newFrame.size.height = [self heightForContentViewWithStory:story];
    self = [super initWithFrame:newFrame];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.contentView];
    [self layoutSubviewsWithStory:story];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToExpand:)];
    [self addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyUpdateNotification:) name:kEditStoryNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tapToExpand:(id)sender {
    if (self.isExpand) {
        return;
    }
    
    [TBUtility sendAnalyticsEventWithCategory:kAnalyticsCategoryPageElements action:kAnalyticsActionShowStoryDetail label:@"" value:nil];
    self.isExpand = YES;
    self.scrollEnabled = YES;
    
    //Insert dark layer
    if (!self.maskView) {
        UIView *layerView = [[UIView alloc] initWithFrame:self.fullFrame];
        layerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        layerView.alpha = 0;
        self.maskView = layerView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrink:)];
        [self.maskView addGestureRecognizer:tap];
    }
    [self.superview insertSubview:self.self.maskView belowSubview:self];
    
    CGFloat heightAfterExpand = [self calculateHeightOfContents];
    CGRect scrollViewFrame = self.frame;
    scrollViewFrame.size.height= MIN(heightAfterExpand, CGRectGetHeight(self.fullFrame) - 64);
    
    CGRect newFrame = self.contentView.frame;
    newFrame.size.height = heightAfterExpand;
    
    self.expandedContentView.alpha = 0;
    [self addSubview:self.expandedContentView];
    
    self.parentViewController.navigationItem.hidesBackButton = YES;
    self.parentViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(shrink:)];
    self.rightBarButtonItems = self.parentViewController.navigationItem.rightBarButtonItems;
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    if (self.permission) {
        self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editStory:)];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = scrollViewFrame;
        self.contentView.alpha = 0;
        self.expandedContentView.alpha = 1;
        self.maskView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.contentSize = self.expandedContentView.frame.size;
    }];
}

- (void)editStory:(id)sender {
    JLStoryEditorViewController *storyEditorViewController = [[JLStoryEditorViewController alloc] initWithStory:self.story];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:storyEditorViewController];
    storyEditorViewController.delegate = self;
    [self.parentViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)shrink:(id)sender {
    if (!self.isExpand) {
        return;
    }
    self.scrollEnabled = NO;
    
    CGRect newFrame = self.frame;
    newFrame.size.height = [self heightForContentViewWithStory:self.story];;
    
    self.parentViewController.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.expandedContentView.alpha = 0;
        self.contentView.alpha = 1;
        self.frame = newFrame;
        self.maskView.alpha = 0;
        self.parentViewController.navigationItem.hidesBackButton = NO;
        self.parentViewController.navigationItem.leftBarButtonItem = nil;
    } completion:^(BOOL finished) {
        self.isExpand = NO;
        [self.maskView removeFromSuperview];
        self.contentSize = self.contentView.frame.size;
    }];
}

- (void)previewFile:(id)sender {
    
    UIGestureRecognizer *recognizer = (UIGestureRecognizer *)sender;
    //Preview Image
    if ([recognizer.view isKindOfClass:[UIImageView class]]) {
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayNavArrows = NO;
        browser.enableGrid = NO;
        browser.displaySelectionButtons = NO;
        [self.parentViewController.navigationController pushViewController:browser animated:YES];
    } else {
        NSURL *filePreviewItemUrl = [NSURL URLWithString:self.storyData[@"downloadUrl"]];
        if (!filePreviewItemUrl) {
            return;
        }
        NSString *fileName = self.storyData[@"fileName"];
        if (![fileName hasSuffix:self.storyData[@"fileType"]]) {
            fileName = [fileName stringByAppendingFormat:@".%@",self.storyData[@"fileType"]];
        }
        NSString *fileKey = self.storyData[@"fileKey"];
        if (!self.previewItems) {
            self.previewItems = [NSMutableArray new];
        }
        AZAPreviewItem *previewItem = [AZAPreviewItem previewItemWithURL:filePreviewItemUrl title:fileName fileKey:fileKey];
        if (self.storyData[@"fileSize"]) {
            previewItem.fileSize = [self.storyData[@"fileSize"] floatValue];
        }
        [self.previewItems removeAllObjects];
        [self.previewItems addObject:previewItem];
        AZAPreviewController *previewController = [[AZAPreviewController alloc] init];
        previewController.dataSource = self;
        previewController.delegate = self;
        [self.parentViewController.navigationController pushViewController:previewController animated:YES];
    }
}

#pragma mark - AZAPreviewController data source & delegate

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return [self.previewItems count];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.previewItems[index];
}

#pragma mark - WMPhotoBrowser delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:self.imageUrl]];
    return photo;
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    return self.story.title;
}

- (void)displayLink:(id)sender {
    NSURL *url = [NSURL URLWithString:self.storyData[@"url"]];
    if (url) {
        NSString *urlString = nil;
        if (url.scheme) {
            urlString = url.absoluteString;
        } else {
            urlString = [NSString stringWithFormat:@"http://%@", url.absoluteString];
        }
        JLWebViewController *webViewController = [[JLWebViewController alloc] init];
        webViewController.urlString = urlString;
        [self.parentViewController.navigationController pushViewController:webViewController animated:YES];
    }
}

- (CGFloat)calculateHeightOfContents {
    NSDictionary *storyData = self.story.data;
    CGFloat finalHeight = 16;
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    if ([self.story.category isEqualToString:kStoryCategoryFile]) {
        if ([self.story.data[@"fileCategory"] isEqualToString:@"image"]) {
            CGFloat imageHeight = [storyData[@"imageHeight"] floatValue];
            CGFloat imageWidth = [storyData[@"imageWidth"] floatValue];
            CGFloat height = imageHeight* MIN(1, (CGRectGetWidth(self.frame)/imageWidth));
            finalHeight += (height+DefaultSpacing-16);
        } else {
            finalHeight += (JLStoryViewExpandImageDefaultHeight + DefaultSpacing);
        }
    } else if ([self.story.category isEqualToString:kStoryCategoryLink]) {
        CGSize sizeThatFitsLabel = [self.expandedLinkButton sizeThatFits:CGSizeMake(viewWidth-2*EdgeInsetLeft, MAXFLOAT)];
        finalHeight += (sizeThatFitsLabel.height + DefaultSpacing);
        if (self.story.data[@"imageUrl"]) {
            finalHeight += (JLStoryViewExpandImageDefaultHeight + DefaultSpacing);
        }
    }
    if (self.story.title.length > 0) {
        CGSize sizeThatFitsLabel = [self.expandedTitleLabel sizeThatFits:CGSizeMake(viewWidth-2*EdgeInsetLeft, MAXFLOAT)];
        finalHeight += (sizeThatFitsLabel.height + DefaultSpacing);
    }
    if (self.expandedInfoLabel) {
        CGSize sizeThatFitsLabel = [self.expandedInfoLabel sizeThatFits:CGSizeMake(viewWidth-2*EdgeInsetLeft, MAXFLOAT)];
        finalHeight += (sizeThatFitsLabel.height + DefaultSpacing);
    }
    if ([storyData[@"text"] length] > 0) {
        CGSize sizeThatFitsTextView = [self.detailTextView sizeThatFits:CGSizeMake(viewWidth-2*EdgeInsetLeft, MAXFLOAT)];
        finalHeight += (sizeThatFitsTextView.height + DefaultSpacing);
    }
    CGFloat heightBeforeExpand = CGRectGetHeight(self.frame);
    return MAX(heightBeforeExpand, finalHeight);
}

- (void)layoutSubviewsWithStory:(MOStory *)story {
    CGFloat contentViewWidth = CGRectGetWidth(self.fullFrame);
    CGFloat contentViewHeiht = [self heightForContentViewWithStory:story];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.leading.equalTo(self.mas_leading);
        make.width.mas_equalTo(contentViewWidth);
        make.height.mas_equalTo(contentViewHeiht);
    }];
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *storyData = story.data;
    CGFloat labelWidth = CGRectGetWidth(self.frame) - 2*EdgeInsetLeft;
    UIView *anchorView = nil;
    if ([story.category isEqualToString:kStoryCategoryTopic]) {
        if (self.titleLabel) {
            [self.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).with.offset(16);
                make.leading.equalTo(self.contentView.mas_leading).with.offset(EdgeInsetLeft);
                make.width.mas_equalTo(labelWidth);
            }];
            anchorView = self.titleLabel;
        }
        if (self.detailLabel) {
            [self.contentView addSubview:self.detailLabel];
            [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
                make.left.equalTo(anchorView.mas_left);
                make.width.mas_equalTo(labelWidth);
            }];
            anchorView = self.detailLabel;
        }
        if (self.infoLabel) {
            [self.contentView addSubview:self.infoLabel];
            [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
                make.left.equalTo(anchorView.mas_left);
                make.width.mas_equalTo(labelWidth);
            }];
        }
        
    } else if ([story.category isEqualToString:kStoryCategoryFile]) {
        
        CGFloat imageViewHeight = [self.story.data[@"text"] length] > 0 ?JLStoryViewImageSizeLarge:JLStoryViewImageSizeSmall;
        UIView *fileView = nil;
        if (self.imageView) {
            [self.contentView addSubview:self.imageView];
            [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).with.offset(-EdgeInsetLeft);
                make.height.mas_equalTo(imageViewHeight);
                make.width.mas_equalTo(imageViewHeight);
            }];
            fileView = self.imageView;
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:storyData[@"downloadUrl"]]];
        } else if (self.fileButton) {
            [self.contentView addSubview:self.fileButton];
            [self.fileButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).with.offset(-EdgeInsetLeft);
                make.height.mas_equalTo(imageViewHeight);
                make.width.mas_equalTo(imageViewHeight);
            }];
            fileView = self.fileButton;
        }
        
        if (self.titleLabel) {
            [self.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(fileView);
                make.leading.equalTo(self.contentView.mas_leading).with.offset(EdgeInsetLeft);
                make.trailing.lessThanOrEqualTo(fileView.mas_leading).with.offset(-EdgeInsetLeft);
            }];
            anchorView = self.titleLabel;
        }
        
        if (self.detailLabel) {
            [self.contentView addSubview:self.detailLabel];
            [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
                make.left.equalTo(anchorView.mas_left);
                make.trailing.lessThanOrEqualTo(fileView.mas_leading).with.offset(-EdgeInsetLeft);
            }];
            anchorView = self.detailLabel;
        }
        
        if (self.infoLabel) {
            [self.contentView addSubview:self.infoLabel];
            [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
                make.left.equalTo(anchorView.mas_left);
                make.trailing.lessThanOrEqualTo(fileView.mas_leading).with.offset(-EdgeInsetLeft);
            }];
            anchorView = self.infoLabel;
        }
        
    } else if ([story.category isEqualToString:kStoryCategoryLink]) {
        if (self.linkLabel) {
            [self.contentView addSubview:self.linkLabel];
            [self.linkLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).offset(16);
                make.leading.equalTo(self.contentView.mas_leading).with.offset(EdgeInsetLeft);
                make.width.mas_equalTo(labelWidth);
            }];
        }
        if (self.titleLabel) {
            [self.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.linkLabel.mas_bottom).with.offset(DefaultSpacing);
                make.leading.equalTo(self.contentView.mas_leading).with.offset(EdgeInsetLeft);
                make.width.mas_equalTo(labelWidth);
            }];
        }
        if (self.infoLabel) {
            [self.contentView addSubview:self.infoLabel];
            [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.titleLabel.mas_bottom).with.offset(DefaultSpacing);
                make.left.equalTo(self.linkLabel.mas_left);
                make.width.mas_equalTo(labelWidth);
            }];
        }
    }
}

- (void)expandSubviewsWithStory:(MOStory *)story {
    
    CGFloat labelWidth = CGRectGetWidth(self.frame) - 2*EdgeInsetLeft;
    
    UIView *anchorView = nil;
    
    if (self.expandedLinkButton) {
        [self.expandedContentView addSubview:self.expandedLinkButton];
        [self.expandedLinkButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.expandedContentView.mas_top).with.offset(16);
            make.left.equalTo(self.expandedContentView.mas_left).with.offset(16);
            make.width.mas_equalTo(labelWidth);
        }];
        anchorView = self.expandedLinkButton;
    }
    
    if (self.expandedImageView) {
        [self.expandedContentView addSubview:self.expandedImageView];
        [self.expandedImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (anchorView) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
            } else {
                make.top.equalTo(self.expandedContentView.mas_top);
            }
            CGFloat originalImageWidth = self.storyData[@"imageWidth"] ? [self.storyData[@"imageWidth"] floatValue ]: labelWidth;
            CGFloat originalImageHeight = self.storyData[@"imageHeight"] ? [self.storyData[@"imageHeight"] floatValue]: JLStoryViewExpandImageDefaultHeight;
            make.centerX.equalTo(self.expandedContentView.mas_centerX);
            CGFloat viewWidth = MIN(originalImageWidth, CGRectGetWidth(self.fullFrame));
            CGFloat viewHeight = originalImageHeight*(viewWidth/originalImageWidth);
            make.width.mas_equalTo(viewWidth);
            make.height.mas_equalTo(viewHeight);
        }];
        anchorView = self.expandedImageView;
    } else if (self.fileView) {
        [self.expandedContentView addSubview:self.fileView];
        [self.fileView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (anchorView) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
            } else {
                make.top.equalTo(self.expandedContentView.mas_top).with.offset(16);
            }
            make.left.equalTo(self.expandedContentView.mas_left).with.offset(16);
            make.right.equalTo(self.expandedContentView.mas_right).with.offset(-16);
            make.height.mas_equalTo(JLStoryViewExpandImageDefaultHeight);
        }];
        anchorView = self.fileView;
    }
    
    if (self.expandedTitleLabel) {
        [self.expandedContentView addSubview:self.expandedTitleLabel];
        [self.expandedTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (anchorView) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
            } else {
                make.top.equalTo(self.expandedContentView.mas_top).with.offset(16);
            }
            make.left.equalTo(self.expandedContentView.mas_left).with.offset(16);
            make.width.mas_equalTo(labelWidth);
        }];
        anchorView = self.expandedTitleLabel;
    }
    
    if (self.detailTextView) {
        [self.expandedContentView addSubview:self.detailTextView];
        NSString *text = self.storyData[@"text"];
        self.detailTextView.attributedText = [self detailAttributedString:text];
        CGSize sizeThatFitsTextView = [self.detailTextView sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
        [self.detailTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (anchorView) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
            } else {
                make.top.equalTo(self.expandedContentView.mas_top).with.offset(DefaultSpacing);
            }
            make.left.equalTo(self.expandedContentView.mas_left).with.offset(16);
            make.width.mas_equalTo(sizeThatFitsTextView.width);
            make.height.mas_equalTo(sizeThatFitsTextView.height);
        }];
        anchorView = self.detailTextView;
    }
    
    if (self.expandedInfoLabel) {
        [self.expandedContentView addSubview:self.expandedInfoLabel];
        [self.expandedInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (anchorView) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(DefaultSpacing);
            } else {
                make.top.equalTo(self.expandedContentView.mas_top).with.offset(DefaultSpacing);
            }
            make.left.equalTo(self.expandedContentView.mas_left).with.offset(16);
            make.width.mas_equalTo(labelWidth);
        }];
        anchorView = self.expandedInfoLabel;
    }
}

- (NSAttributedString *)storyInfoAttributedStringWithCreator:(NSString *)creator createAt:(NSDate *)createAt {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    NSDictionary *creatorAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:57/255.0
                                                                                       green:60/255.0
                                                                                        blue:64/255.0
                                                                                       alpha:1.0],
                                        NSFontAttributeName:[UIFont systemFontOfSize:12]};
    NSMutableAttributedString *creatorString = [[NSMutableAttributedString alloc] initWithString:creator attributes:creatorAttributes];
    
    NSString *createAtString = [createAt mt_stringFromDateWithFormat:@"yyyy/MM/dd HH:mm" localized:NO];
    NSDictionary *createAtAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:161/255.0
                                                                                                     green:161/255.0
                                                                                                      blue:161/255.0
                                                                                                     alpha:1.0],
                                         NSFontAttributeName:[UIFont systemFontOfSize:12]};
    NSString *postAt = [NSString stringWithFormat:@" %@ ",NSLocalizedString(@"Post At", @"Post At")];
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:[postAt stringByAppendingFormat:@" %@", createAtString] attributes:createAtAttributes];
    [attributedString appendAttributedString:creatorString];
    [attributedString appendAttributedString:dateString];
    
    return attributedString;
}

- (void)storyEditorDidUpdate:(MOStory *)story {
    self.parentViewController.title = story.title;
    
    self.story = story;
    self.storyData = story.data;
    [self refreshDataWithStory:story];
}

- (void)storyUpdateNotification:(NSNotification *)aNotificaton {
    NSDictionary *storyObject = (NSDictionary *)(aNotificaton.object);
    NSString *storyId = storyObject[@"_id"];
    if ([storyId isEqualToString:self.story.id]) {
        self.storyData = self.story.data;
        [self refreshDataWithStory:self.story];
    }
}

- (void)refreshDataWithStory:(MOStory *)story {
    //layout expanded view
    [self.expandedImageView removeFromSuperview];
    self.expandedImageView = nil;
    [self.expandedLinkButton removeFromSuperview];
    self.expandedLinkButton = nil;
    [self.expandedTitleLabel removeFromSuperview];
    self.expandedTitleLabel = nil;
    [self.detailTextView removeFromSuperview];
    self.detailTextView = nil;
    [self expandSubviewsWithStory:story];
    //layout content view
    self.titleLabel = nil;
    self.linkLabel = nil;
    self.detailLabel = nil;
    self.infoLabel = nil;
    [self layoutSubviewsWithStory:story];
    if (self.isExpand) {
        CGFloat heightAfterExpand = [self calculateHeightOfContents];
        CGRect scrollViewFrame = self.frame;
        scrollViewFrame.size.height= MIN(heightAfterExpand, CGRectGetHeight(self.fullFrame) - 64);
        CGRect expandedContentViewFrame = self.expandedContentView.frame;
        expandedContentViewFrame.size.height = heightAfterExpand;
        self.expandedContentView.frame = expandedContentViewFrame;
        self.frame = scrollViewFrame;
        self.contentSize = expandedContentViewFrame.size;
    } else {
        CGRect newFrame = self.frame;
        newFrame.size.height = [self heightForContentViewWithStory:self.story];
        self.frame = newFrame;
    }
}

- (NSAttributedString *)titleAttributedString:(NSString *)text {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor tb_storyTitleColor],
                                 NSFontAttributeName:[UIFont boldFontWithFont:[UIFont systemFontOfSize:17]]};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    return attributedString;
}

- (NSAttributedString *)detailAttributedString:(NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor tb_storyDetailColor],
                                     NSFontAttributeName:[UIFont systemFontOfSize:14]}
                             range:NSMakeRange(0, text.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    if (!self.isExpand) {
        style.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    return attributedString;
}

- (NSAttributedString *)linkAttributedString:(NSString *)text {
    if (!text) {
        return nil;
    }
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor tb_storyLinkColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:17]};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    return attributedString;
}

- (CGFloat)heightForContentViewWithStory:(MOStory *)story {
    if ([story.category isEqualToString:kStoryCategoryFile] || [story.category isEqualToString:kStoryCategoryTopic]) {
        if ([story.data[@"text"] length] > 0) {
            return 96;
        } else {
            return 72;
        }
    } else if ([story.category isEqualToString:kStoryCategoryLink]) {
        return 96;
    }
    return 96;
}

- (BOOL)permission {
    if (!_permission) {
        NSString *currentUserKey = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if ([self.story.creatorID isEqualToString:currentUserKey] || [TBUtility isManagerForCurrentAccount]) {
            return YES;
        }
        _permission = NO;
    }
    return _permission;
}

- (UITextView *)detailTextView {
    if (!_detailTextView) {
        if ([self.storyData[@"text"] length] > 0) {
            _detailTextView = [[UITextView alloc] init];
            [_detailTextView setTextContainerInset:UIEdgeInsetsMake(0, -5, 0, 0)];
            _detailTextView.editable = NO;
            _detailTextView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber | UIDataDetectorTypeAddress;
            _detailTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor jl_redColor]};
            _detailTextView.scrollEnabled = NO;
            NSString *text = self.storyData[@"text"];
            _detailTextView.attributedText = [self detailAttributedString:text];
        }
    }
    return _detailTextView;
}

- (UIView *)expandedContentView {
    if (!_expandedContentView) {
        CGRect frame = self.contentView.frame;
        frame.size.height = [self calculateHeightOfContents];
        _expandedContentView = [[UIView alloc] initWithFrame:frame];
        [self expandSubviewsWithStory:self.story];
    }
    return _expandedContentView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        if (([self.story.category isEqualToString:kStoryCategoryFile] && [self.storyData[@"fileCategory"] isEqualToString:@"image"]) || ([self.story.category isEqualToString:kStoryCategoryLink] && self.storyData[@"imageUrl"])) {
            _imageView = [[UIImageView alloc] init];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.clipsToBounds = YES;
            _imageView.backgroundColor = [UIColor lightGrayColor];
        }
    }
    return _imageView;
}

- (UIButton *)fileButton {
    if (!_fileButton) {
        if ([self.story.category isEqualToString:kStoryCategoryFile] && ![self.storyData[@"fileCategory"] isEqualToString:@"image"]) {
            _fileButton = [[UIButton alloc] init];
            _fileButton.enabled = NO;
            UIImage *bubbleImage = [UIImage imageNamed:@"icon-search-file"];
            [_fileButton setBackgroundImage:bubbleImage forState:UIControlStateDisabled];
            [_fileButton setTitle:self.storyData[@"fileType"] forState:UIControlStateNormal];
        }
    }
    return _fileButton;
}

#pragma mark - Expanded

- (UIView *)fileView {
    if (!_fileView) {
        if ([self.story.category isEqualToString:kStoryCategoryFile] && ![self.storyData[@"fileCategory"] isEqualToString:@"image"]) {
            _fileView = [[UIView alloc] init];
            _fileView.backgroundColor = [UIColor tb_storyFileBackgroundColor];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewFile:)];
            [_fileView addGestureRecognizer:tap];
            _fileView.userInteractionEnabled = YES;
            [_fileView addSubview:self.expandedFileButton];
            [self.expandedFileButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_fileView.mas_centerX);
                make.centerY.equalTo(_fileView.mas_centerY);
                make.width.mas_equalTo(JLStoryViewImageSizeLarge);
                make.height.mas_equalTo(JLStoryViewImageSizeLarge);
            }];
        }
    }
    return _fileView;
}

- (UIButton *)expandedFileButton {
    if (!_expandedFileButton) {
        if ([self.story.category isEqualToString:kStoryCategoryFile] && ![self.storyData[@"fileCategory"] isEqualToString:@"image"]) {
            _expandedFileButton = [[UIButton alloc] init];
            _expandedFileButton.enabled = NO;
            UIImage *bubbleImage = [UIImage imageNamed:@"icon-search-file"];
            [_expandedFileButton setBackgroundImage:bubbleImage forState:UIControlStateDisabled];
            [_expandedFileButton setTitle:self.storyData[@"fileType"] forState:UIControlStateNormal];
        }
    }
    return _expandedFileButton;
}

- (UIImageView *)expandedImageView {
    if (!_expandedImageView) {
        NSString *imageUrl = nil;
        if (self.storyData[@"imageUrl"]) {
            imageUrl = self.storyData[@"imageUrl"];
        } else if ([self.story.category isEqualToString:kStoryCategoryFile] && [self.story.data[@"fileCategory"] isEqualToString:@"image"] && self.story.data[@"downloadUrl"]) {
            imageUrl = self.story.data[@"downloadUrl"];
        }
        if (imageUrl) {
            self.imageUrl = imageUrl;
            _expandedImageView = [UIImageView new];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewFile:)];
            [_expandedImageView addGestureRecognizer:tap];
            _expandedImageView.userInteractionEnabled = YES;
            _expandedImageView.contentMode = UIViewContentModeScaleAspectFit;
            [_expandedImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
        }
    }
    return _expandedImageView;
}

- (UILabel *)expandedTitleLabel {
    if (!_expandedTitleLabel) {
        _expandedTitleLabel = [[UILabel alloc] init];
        _expandedTitleLabel.numberOfLines = 0;
        _expandedTitleLabel.attributedText = [self titleAttributedString:self.story.title];
    }
    return _expandedTitleLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        NSString *title;
        if (self.storyData[@"title"]) {
            title = self.storyData[@"title"];
        } else if (self.storyData[@"fileName"]) {
            title = self.storyData[@"fileName"];
        }
        _titleLabel.attributedText = [self titleAttributedString:title?:self.story.title];
    }
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        MOUser *user = [MOUser findFirstWithId:self.story.creatorID];
        NSString *userName = [TBUtility getFinalUserNameWithMOUser:user];
        _infoLabel.attributedText = [self storyInfoAttributedStringWithCreator:userName createAt:self.story.updatedAt];
    }
    return _infoLabel;
}

- (UILabel *)expandedInfoLabel {
    if (!_expandedInfoLabel) {
        _expandedInfoLabel = [[UILabel alloc] init];
        MOUser *user = [MOUser findFirstWithId:self.story.creatorID];
        NSString *userName = [TBUtility getFinalUserNameWithMOUser:user];
        _expandedInfoLabel.attributedText = [self storyInfoAttributedStringWithCreator:userName createAt:self.story.updatedAt];
    }
    return _expandedInfoLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        if ([self.storyData[@"text"] length] > 0) {
            _detailLabel = [[UILabel alloc] init];
            NSString *text = self.storyData[@"text"];
            _detailLabel.text = text;
            _detailLabel.textColor = [UIColor tb_storyDetailColor];
            _detailLabel.font = [UIFont systemFontOfSize:14];
        }
    }
    return _detailLabel;
}

- (UILabel *)linkLabel {
    if (!_linkLabel) {
        if ([self.story.category isEqualToString:kStoryCategoryLink]) {
            _linkLabel = [[UILabel alloc] init];
            NSString *url = self.storyData[@"url"];
            _linkLabel.attributedText = [self linkAttributedString:url];
            _linkLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
    }
    return _linkLabel;
}

- (UIButton *)expandedLinkButton {
    if (!_expandedLinkButton) {
        if ([self.story.category isEqualToString:kStoryCategoryLink]) {
            _expandedLinkButton = [[UIButton alloc] init];
            _expandedLinkButton.contentEdgeInsets = UIEdgeInsetsZero;
            _expandedLinkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [_expandedLinkButton setTitleColor:[UIColor tb_storyLinkBlueColor] forState:UIControlStateNormal];
            NSString *url = self.storyData[@"url"];
            [_expandedLinkButton setTitle:url forState:UIControlStateNormal];
            _expandedLinkButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [_expandedLinkButton addTarget:self action:@selector(displayLink:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _expandedLinkButton;
}

@end
