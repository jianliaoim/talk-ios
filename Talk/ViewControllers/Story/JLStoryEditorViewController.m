//
//  JLStoryEditorViewController.m
//  Talk
//
//  Created by 王卫 on 15/11/11.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLStoryEditorViewController.h"
#import "MOStory.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "JLTextView.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <Masonry.h>
#import <CoreData+MagicalRecord.h>
#import "TBUtility.h"
#import "Coredata+MagicalRecord.h"
#import "RootViewController.h"
#import "TWPhotoPickerController.h"
#import "TBFileSessionManager.h"
#import "NSString+TBUtilities.h"
#import <ReactiveCocoa.h>

@interface JLStoryEditorViewController ()<UITextViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) JLTextView *linkTextView;
@property (strong, nonatomic) JLTextView *titleTextView;
@property (strong, nonatomic) JLTextView *textTextView;
@property (strong, nonatomic) UIView *fileView;
@property (strong, nonatomic) UIButton *fileButton;
@property (strong, nonatomic) UIView *discoverLinkView;
@property (strong, nonatomic) UITextField *linkTextField;
@property (strong, nonatomic) UIButton *discoverLinkButton;
@property (strong, nonatomic) UIActivityIndicatorView *discoveringIndicatorView;

@property (assign, nonatomic) CGFloat keyboardHeight;
@property (assign, nonatomic) CGFloat keyboardAnimationDuration;
@property (assign, nonatomic) BOOL hasDiscovered;
@property (assign, nonatomic) BOOL isDiscovering;
@property (assign, nonatomic) BOOL isFileChanged;

@property (strong, nonatomic) MOStory *story;
@property (strong, nonatomic) NSMutableDictionary *storyData;

@end

static CGFloat const DefaultImageHeight = 158;
static NSInteger const SeperatorLineTag = 0;
static NSInteger const FileViewTag = 1;
static NSInteger const DiscoverLinkViewTag = 2;

@implementation JLStoryEditorViewController

- (instancetype)initWithStory:(MOStory *)story {
    self = [super init];
    if (self) {
        if (story) {
            self.story = story;
            self.category = story.category;
            self.storyData = [story.data mutableCopy];
            if (self.story.title) {
                [self.storyData setObject:self.story.title forKey:@"title"];
            }
        }
        if (!self.storyData) {
            self.storyData = [NSMutableDictionary new];
        }
    }
    return self;
}

//Convenient init method
- (instancetype)init {
    return [self initWithStory:nil];
}

- (void)loadView {
    [super loadView];
    [self setupNavigationBar];
    [self setupScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self registerForKeyboardNotifications];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Check UIPasteBoard

- (void)checkPasteboardForLink {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSURL *urlInPasteboard = pasteboard.URL;
    if (urlInPasteboard) {
        self.linkTextField.text = [NSString stringWithFormat:@"%@", urlInPasteboard];
    }
}

#pragma mark - Set RACObserve

- (void)setupRACObserve {
    UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    @weakify(self)
    [self.linkTextView.rac_textSignal subscribeNext:^(id x) {
        @strongify(self)
        [self rac_textViewDidChange:self.linkTextView];
    }];
    [self.titleTextView.rac_textSignal subscribeNext:^(id x) {
        @strongify(self)
        [self rac_textViewDidChange:self.titleTextView];
    }];
    [self.textTextView.rac_textSignal subscribeNext:^(id x) {
        @strongify(self)
        [self rac_textViewDidChange:self.textTextView];
    }];
    if (!self.story) {
        if ([self.category isEqualToString:kStoryCategoryLink]) {
            RAC(rightBarButtonItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, hasDiscovered), self.linkTextField.rac_textSignal]
                                                                 reduce:^id(NSNumber *hasDiscovered, NSString *text){
                                                                     return @(hasDiscovered.boolValue && text.length > 0);
                                                                 }];
            RAC(self.discoverLinkButton, enabled) = [RACSignal combineLatest:@[RACObserve(self, isDiscovering), self.linkTextField.rac_textSignal] reduce:^id(NSNumber *isDiscovering, NSString *text){
                return @(!isDiscovering.boolValue && text.length > 0);
            }];
        } else if ([self.category isEqualToString:kStoryCategoryTopic]) {
            RAC(rightBarButtonItem, enabled) = [self.titleTextView.rac_textSignal map:^id(NSString *text) {
                return @(text.length > 0);
            }];
        }
    } else {
        RACSignal *isContentModifiedSignal = [RACSignal combineLatest:@[self.linkTextView.rac_textSignal, self.titleTextView.rac_textSignal, self.textTextView.rac_textSignal] reduce:^id(NSString *link, NSString *title, NSString *text){
            BOOL isContentModified = NO;
            if (!self.storyData[@"link"]) {
                isContentModified = isContentModified || link.length > 0;
            } else {
                isContentModified = isContentModified || ![link isEqualToString:self.storyData[@"url"]];
            }
            if (!self.storyData[@"title"]) {
                isContentModified = isContentModified || title.length > 0;
            } else {
                isContentModified = isContentModified || ![title isEqualToString:self.storyData[@"title"]];
            }
            if (!self.storyData[@"text"]) {
                isContentModified = isContentModified || text.length > 0;
            } else {
                isContentModified = isContentModified || ![text isEqualToString:self.storyData[@"text"]];
            }
            return @(isContentModified);
        }];
        if ([self.category isEqualToString:kStoryCategoryTopic]) {
            RAC(rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.titleTextView.rac_textSignal, isContentModifiedSignal]
                                                                 reduce:^id(NSString *title, NSNumber *isContentModified){
                                                                     return @(title.length > 0 && isContentModified.boolValue);
                                                                 }];
        } else if ([self.category isEqualToString:kStoryCategoryLink]) {
            RAC(rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.linkTextView.rac_textSignal, isContentModifiedSignal]
                                                                 reduce:^id(NSString *link, NSNumber *isContentModified){
                                                                     return @(link.length > 0 && isContentModified.boolValue);
                                                                 }];
        } else if ([self.category isEqualToString:kStoryCategoryFile]) {
            RAC(rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.titleTextView.rac_textSignal, isContentModifiedSignal, RACObserve(self, isFileChanged)]
                                                                 reduce:^id(NSString *title, NSNumber *isContentModified, NSNumber *isFileChanged){
                                                                     return @(title.length > 0 && (isContentModified.boolValue || isFileChanged.boolValue));
                                                                 }];
        }
    }
    if ((!self.story) && [self.category isEqualToString:kStoryCategoryLink]) {
        [self checkPasteboardForLink];
    }
}

#pragma mark - Navigation bar

- (void)setupNavigationBar {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(dismissEditor:)];
    UIBarButtonItem *rightBarButtonItem = nil;
    if (self.story) {
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(saveEditor:)];
    } else {
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next") style:UIBarButtonItemStylePlain target:self action:@selector(saveEditor:)];
    }
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    rightBarButtonItem.enabled = NO;
    if (self.story) {
        if ([self.category isEqualToString:kStoryCategoryLink]) {
            self.navigationItem.title = NSLocalizedString(@"Edit Link", @"Edit Link");
        } else if ([self.category isEqualToString:kStoryCategoryTopic]) {
            self.navigationItem.title = NSLocalizedString(@"Edit Idea", @"Edit Idea");
        } else if ([self.category isEqualToString:kStoryCategoryFile]) {
            self.navigationItem.title = NSLocalizedString(@"Edit File", @"Edit File");
        }
    } else {
        if ([self.category isEqualToString:kStoryCategoryTopic]) {
            self.navigationItem.title = NSLocalizedString(@"Share Idea", @"Share Idea");
        } else if ([self.category isEqualToString:kStoryCategoryLink]) {
            self.navigationItem.title = NSLocalizedString(@"Share Link", @"Share Link");
        }
    }
    [self setupRACObserve];
}

#pragma mark - Actions

- (void)dismissEditor:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveEditor:(id)sender {
    //Add save action here
    [self.storyData removeObjectForKey:@"title"];
    if ([self.category isEqualToString:kStoryCategoryLink]) {
        if (self.linkTextView) {
            self.storyData[@"url"] = self.linkTextView.text?:@"";
        }
        if (self.linkTextField) {
            self.storyData[@"url"] = self.linkTextField.text?:@"";
        }
    }
    if (self.titleTextView) {
        if ([self.category isEqualToString:kStoryCategoryFile]) {
            self.storyData[@"fileName"] = self.titleTextView.text?:@"";
        } else {
            self.storyData[@"title"] = self.titleTextView.text?:@"";
        }
    }
    if (self.textTextView) {
        self.storyData[@"text"] = self.textTextView.text?:@"";
    }
    if (self.story) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving", @"Saving")];
        NSDictionary *originStoryData = self.story.data;
        NSMutableDictionary *dataChanged = [NSMutableDictionary new];
        for (NSString *key in self.storyData) {
            NSString *value = [self.storyData valueForKey:key];
            NSString *originValue = [originStoryData valueForKey:key];
            if (!originValue && value.length == 0) {
                continue;
            }
            if (![value isEqual:originValue]) {
                [dataChanged setObject:value forKey:key];
            }
        }
        self.story.data = self.storyData.copy;
        NSDictionary *parameter = @{@"category":self.category,
                                    @"data":dataChanged.copy};
        [[TBHTTPSessionManager sharedManager] PUT:[NSString stringWithFormat:kStoryUpdateURLString, self.story.id] parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
            //Save story to database
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MOStory *localStory = [self.story MR_inContext:localContext];
                if (responseObject[@"title"]) {
                    localStory.title = responseObject[@"title"];
                }
            } completion:^(BOOL success, NSError *error) {
                [SVProgressHUD dismiss];
                if ([self.delegate respondsToSelector:@selector(storyEditorDidUpdate:)]) {
                    [self.delegate storyEditorDidUpdate:self.story];
                }
                [self dismissEditor:nil];
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }];
    } else {
        //create
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate hasCreateStoryWithCategory:self.category StoryData:self.storyData];
    }
}

- (void)tapOnImage:(id)sender {
    if (![self.category isEqualToString:kStoryCategoryFile]) {
        return;
    }
    [self changeImage];
}

- (void)discoverLinkButtonTapped:(id)sender {
    //To-Do: add validate
    [self discoverLink:self.linkTextField.text];
}

#pragma mark - add subviews

- (void)setupScrollView {
    if (!self.scrollView) {
        self.scrollView = [UIScrollView new];
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.scrollView.bounces = YES;
        [self.view addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        self.container = [UIView new];
        [self.scrollView addSubview:self.container];
        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.width.equalTo(self.scrollView);
        }];
    }
    
    NSMutableArray *subviews = [NSMutableArray new];
    
    UIView *seperatorLine = [[UIView alloc] init];
    seperatorLine.tag = SeperatorLineTag;
    seperatorLine.backgroundColor = [UIColor tb_storyFileBackgroundColor];
    if (self.storyData) {
        NSString *imageUrl = nil;
        if (self.storyData[@"imageUrl"]) {
            imageUrl = self.storyData[@"imageUrl"];
        }
        
        if ([self.story.category isEqualToString:kStoryCategoryFile] && [self.story.data[@"fileCategory"] isEqualToString:@"image"] && self.story.data[@"downloadUrl"]) {
            imageUrl = self.story.data[@"downloadUrl"];
        }
        
        
        if (imageUrl) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.backgroundColor = [UIColor lightGrayColor];
            self.imageView = imageView;
            if ([self.storyData[@"fileCategory"] isEqualToString:@"image"]) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImage:)];
                [self.imageView addGestureRecognizer:tap];
                self.imageView.userInteractionEnabled = YES;
            }
            @weakify(self)
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                @strongify(self)
                if (image) {
                    [self updateImageViewLayout:self.imageView];
                }
            }];
        }
    }
    
    if ([self.category isEqualToString:kStoryCategoryTopic]) {
        if (!self.story) {
            [self.titleTextView becomeFirstResponder];
        }
        [subviews addObjectsFromArray:@[self.titleTextView, seperatorLine, self.textTextView]];
    } else if ([self.category isEqualToString:kStoryCategoryLink]) {
        if (!self.story) {
            [subviews addObject:self.discoverLinkView];
            [self.linkTextField becomeFirstResponder];
        } else {
            [subviews addObject:self.linkTextView];
        }
        [subviews addObject:seperatorLine];
        if (self.story || self.hasDiscovered) {
            [subviews addObject:self.titleTextView];
            if (self.imageView) {
                [subviews addObject:self.imageView];
            }
            [subviews addObject:self.textTextView];
        }
    } else if ([self.category isEqualToString:kStoryCategoryFile]) {
        [subviews addObjectsFromArray:@[self.titleTextView, seperatorLine, self.textTextView]];
        if (self.imageView) {
            [subviews insertObject:self.imageView atIndex:0];
        } else if (self.fileView) {
            [subviews insertObject:self.fileView atIndex:0];
        }
    }
    
    [self container:self.container layoutSubviews:subviews inFrame:self.view.frame];
}


- (void)container:(UIView *)container layoutSubviews:(NSArray *)subviews inFrame:(CGRect)frame {
    
    for (UIView *view in container.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat textViewWidth = CGRectGetWidth(frame) - 2*16;
    
    UIView *anchorView = nil;
    for (UIView *view in subviews) {
        [container addSubview:view];
        
        CGFloat viewHeight = 0;
        CGFloat viewWidth = 0;
        BOOL isImageView = NO;
        if ([view isKindOfClass:[UITextView class]]) {
            CGSize sizeThatFitsTextView = [view sizeThatFits:CGSizeMake(textViewWidth, MAXFLOAT)];
            viewWidth = textViewWidth;
            viewHeight = sizeThatFitsTextView.height;
        } else if ([view isKindOfClass:[UIImageView class]]) {
            isImageView = YES;
            UIImage *image = ((UIImageView *)view).image;
            CGFloat originalImageWidth = image.size.width > 0 ? image.size.width: textViewWidth;
            CGFloat originalImageHeight = image.size.height > 0 ? image.size.height: DefaultImageHeight;
            viewWidth = MIN(originalImageWidth, (CGRectGetWidth(frame) - 2*16));
            viewHeight = originalImageHeight*(viewWidth/originalImageWidth);
        } else {
            viewWidth = textViewWidth;
            if (view.tag == SeperatorLineTag) {
                viewHeight = 2*(1/[UIScreen mainScreen].scale);
            } else if (view.tag == FileViewTag) {
                viewHeight = DefaultImageHeight;
            } else if (view.tag == DiscoverLinkViewTag) {
                viewHeight = 30;
            }
        }
        
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            if (anchorView) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(10);
            } else {
                make.top.equalTo(container.mas_top).with.offset(15);
            }
            if (isImageView) {
                make.centerX.equalTo(container.mas_centerX);
            } else {
                make.leading.equalTo(container.mas_leading).with.offset(16);
            }
            
            make.width.mas_equalTo(viewWidth);
            make.height.mas_equalTo(viewHeight);
        }];
        anchorView = view;
    }
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(anchorView.mas_bottom).with.offset(30);
    }];
    
    
}

- (void)updateImageViewLayout:(UIImageView *)imageView {
    UIImage *image = imageView.image;
    if (!image) {
        return;
    }
    CGFloat viewWidth = CGRectGetWidth(self.view.frame) - 32;
    CGFloat originalImageHeight = image.size.height > 0 ?image.size.height:DefaultImageHeight;
    CGFloat originalImageWidth = image.size.width > 0 ?image.size.width:viewWidth;
    CGFloat imageWidth = MIN(originalImageWidth, viewWidth);
    CGFloat imageHeight = originalImageHeight*(imageWidth/originalImageWidth);
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
    }];
}



#pragma mark - textView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.titleTextView && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (self.textTextView) {
            [self.textTextView becomeFirstResponder];
        }
        return NO;
    }
    if (textView == self.linkTextView && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (!self.story) {
            [self discoverLink:textView.text];
        }
        return NO;
    }
    return YES;
}

- (void)rac_textViewDidChange:(UITextView *)textView {
    CGSize sizeThatFitsTextView = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.frame), MAXFLOAT)];
    CGFloat originalHeight = CGRectGetHeight(textView.frame);
    if (sizeThatFitsTextView.height != originalHeight) {
        [textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(sizeThatFitsTextView.height);
        }];
    }
}


- (void)textViewDidChangeSelection:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    if (line.origin.x == INFINITY) return;
    CGFloat lineHeight = CGRectGetHeight(line);
    
    CGRect textViewFrame = [self.view convertRect:textView.frame fromView:self.scrollView];
    CGFloat originY = textViewFrame.origin.y;
    CGFloat cursorY = originY + line.origin.y;
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    if ((viewHeight - cursorY) < (self.keyboardHeight + 3 * lineHeight)) {
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.y += (cursorY - (viewHeight - (self.keyboardHeight + 3 * lineHeight)));
        [UIView animateWithDuration:self.keyboardAnimationDuration delay:0 options:7<<16 animations:^{
            [self.scrollView setContentOffset:contentOffset];
        } completion:nil];
    }
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.linkTextField) {
        [self discoverLink:textField.text];
    }
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - handle keyboard

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.keyboardHeight = keyboardSize.height;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    
    self.scrollView.scrollIndicatorInsets = contentInsets;
    self.scrollView.contentInset = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = UIEdgeInsetsZero;
}


#pragma mark - attributes

- (NSAttributedString *)titleAttributedString:(NSString *)text {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor tb_storyTitleColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:17]};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    return attributedString;
}

- (NSAttributedString *)textAttributedString:(NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor tb_storyDetailColor],
                                      NSFontAttributeName:[UIFont systemFontOfSize:14]}
                              range:NSMakeRange(0, text.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    return attributedString;
}

- (NSAttributedString *)linkAttributedString:(NSString *)text {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor tb_storyLinkColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:17]};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    return attributedString;
}

- (NSAttributedString *)placeholderAttributedString:(NSString *)text size:(NSInteger)size {
    NSInteger fontSize = size?:17;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor tb_storyEditorPlaceholdColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    return attributedString;
}

#pragma mark - restful api

- (void)changeImage {
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    @weakify(self)
    photoPicker.cropBlock = ^(UIImage *image) {
        @strongify(self)
        self.imageView.image = image;
        [self updateImageViewLayout:self.imageView];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading", @"Uploading")];
        [[TBFileSessionManager sharedManager] POST:kUploadURLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData name:@"file" fileName:NSLocalizedString(@"Share Image", @"Share Image") mimeType:@"image/jpg"];
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            //Change url only
            [SVProgressHUD dismiss];
            NSMutableDictionary *newStoryData = [responseObject mutableCopy];
            newStoryData[@"title"] = newStoryData[@"fileName"] = self.storyData[@"title"];
            self.storyData = newStoryData;
            self.isFileChanged = YES;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }];
    };
    [self presentViewController:photoPicker animated:YES completion:nil];
}

- (void)discoverLink:(NSString *)urlString {
    if (![urlString isValidUrl]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Invalid Link", @"Invalid Link")];
        return;
    }
    self.isDiscovering = YES;
    NSDictionary *parameter = @{@"url":urlString};
    @weakify(self)
    [[TBHTTPSessionManager sharedManager] GET:kDiscoverLinkURLString parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        @strongify(self)
        self.hasDiscovered = YES;
        self.isDiscovering = NO;
        self.storyData = [responseObject mutableCopy];
        [self.storyData setValue:urlString forKey:@"url"];
        self.titleTextView.text = self.storyData[@"title"];
        self.textTextView.text = self.storyData[@"text"];
        [self setupScrollView];
        //reload stact view
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        @strongify(self)
        self.hasDiscovered = YES;
        self.isDiscovering = NO;
        [self setupScrollView];
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - Getter

- (UIView *)fileView {
    if (!_fileView) {
        if ([self.story.category isEqualToString:kStoryCategoryFile] && ![self.storyData[@"fileCategory"] isEqualToString:@"image"]) {
            _fileView = [[UIView alloc] init];
            _fileView.tag = FileViewTag;
            _fileView.backgroundColor = [UIColor tb_storyFileBackgroundColor];
            UIButton *fileButton = [[UIButton alloc] init];
            fileButton.enabled = NO;
            UIImage *bubbleImage = [[UIImage imageNamed:@"icon-search-file"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [fileButton setBackgroundImage:bubbleImage forState:UIControlStateNormal];
            [fileButton setTitle:self.storyData[@"fileType"] forState:UIControlStateNormal];
            [_fileView addSubview:fileButton];
            [fileButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_fileView.mas_centerX);
                make.centerY.equalTo(_fileView.mas_centerY);
                make.width.mas_equalTo(64);
                make.height.mas_equalTo(64);
            }];
        }
    }
    return _fileView;
}

- (JLTextView *)linkTextView {
    if (!_linkTextView) {
        if (self.story) {
            _linkTextView = [[JLTextView alloc] init];
            _linkTextView.textColor = [UIColor tb_storyLinkColor];
            _linkTextView.font = [UIFont systemFontOfSize:17];
            self.linkTextView.placeHolder = [self placeholderAttributedString:NSLocalizedString(@"Share Link", @"Share Link") size:14];
            NSString *url = self.storyData[@"url"];
            _linkTextView.scrollEnabled = NO;
            _linkTextView.text = url;
            _linkTextView.delegate = self;
            _linkTextView.returnKeyType = UIReturnKeyDone;
        }
    }
    return _linkTextView;
}

- (UITextField *)linkTextField {
    if (!_linkTextField) {
        if (!self.story) {
            _linkTextField = [UITextField new];
            _linkTextField.textColor = [UIColor tb_storyLinkColor];
            _linkTextField.font = [UIFont systemFontOfSize:17];
            _linkTextField.placeholder = NSLocalizedString(@"Enter or paste a link", @"Enter or paste a link");
            _linkTextField.returnKeyType = UIReturnKeyDone;
            _linkTextField.delegate = self;
            _linkTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _linkTextField.keyboardType = UIKeyboardTypeURL;
        }
    }
    return _linkTextField;
}

- (UIButton *)discoverLinkButton {
    if (!_discoverLinkButton) {
        _discoverLinkButton = [UIButton new];
        [_discoverLinkButton setImage:[UIImage imageNamed:@"DiscoverLink"] forState:UIControlStateNormal];
        [_discoverLinkButton setImage:nil forState:UIControlStateDisabled];
        [_discoverLinkButton addTarget:self action:@selector(discoverLinkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.discoveringIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.discoveringIndicatorView.hidesWhenStopped = YES;
        [_discoverLinkButton addSubview:self.discoveringIndicatorView];
        [self.discoveringIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.and.centerY.equalTo(_discoverLinkButton);
        }];
        
        [RACObserve(self, isDiscovering) subscribeNext:^(id x) {
            if ([x boolValue]) {
                [self.discoveringIndicatorView startAnimating];
            } else {
                [self.discoveringIndicatorView stopAnimating];
            }
        }];
    }
    return _discoverLinkButton;
}

- (UIView *)discoverLinkView {
    if (!_discoverLinkView) {
        _discoverLinkView = [UIView new];
        _discoverLinkView.tag = DiscoverLinkViewTag;
        [_discoverLinkView addSubview:self.linkTextField];
        [_discoverLinkView addSubview:self.discoverLinkButton];
        [self.linkTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_discoverLinkView.mas_centerY);
            make.left.equalTo(_discoverLinkView.mas_left).with.offset(8);
            make.right.equalTo(self.discoverLinkButton.mas_left).with.offset(-8);
        }];
        [self.discoverLinkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_discoverLinkView.mas_centerY);
            make.right.equalTo(_discoverLinkView.mas_right).with.offset(-8);
            make.width.and.height.mas_equalTo(24);
        }];
    }
    return _discoverLinkView;
}


- (JLTextView *)titleTextView {
    if (!_titleTextView) {
        _titleTextView = [[JLTextView alloc] init];
        _titleTextView.textColor = [UIColor tb_storyTitleColor];
        _titleTextView.font = [UIFont systemFontOfSize:17];
        _titleTextView.scrollEnabled = NO;
        self.titleTextView.placeHolder = [self placeholderAttributedString:NSLocalizedString(@"I have an idea to share", @"I have an idea to share") size:17];
        NSString *title = self.storyData[@"title"];
        _titleTextView.text = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        _titleTextView.delegate = self;
        _titleTextView.returnKeyType = UIReturnKeyNext;
    }
    return _titleTextView;
}

- (JLTextView *)textTextView {
    if (!_textTextView) {
        _textTextView = [[JLTextView alloc] init];
        _textTextView.textColor = [UIColor tb_storyDetailColor];
        _textTextView.font = [UIFont systemFontOfSize:14];
        self.textTextView.placeHolder = [self placeholderAttributedString:NSLocalizedString(@"Detailed description", @"Detailed description") size:14];
        NSString *text = self.storyData[@"text"];
        _textTextView.scrollEnabled = NO;
        _textTextView.text = text;
        _textTextView.delegate = self;
    }
    return _textTextView;
}

@end
