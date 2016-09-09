//
//  AGEmojiKeyboardView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13, updated by zhangxiaolian from jiaoliao on 2014-10-16
//  Copyright (c) 2013 Ayush and zhangxiaolian. All rights reserved.
//
#import "AGEmojiKeyBoardView.h"
#import "AGEmojiPageView.h"
#import "CustomImageView.h"

#define kBarHeight  35

static const NSUInteger DefaultRecentEmojisMaintainedCount = 50;
static const CGFloat RecentLabelWidth = 150;
static const CGFloat RecentLabelFontSize = 12.0;

static NSString *const segmentRecentName = @"Recent";
NSString *const RecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";


@interface AGEmojiKeyboardView () <UIScrollViewDelegate, AGEmojiPageViewDelegate ,ButtonIndexChangedDelegate>

@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSDictionary *emojis;
@property (nonatomic) NSMutableArray *pageViews;
@property (nonatomic) NSString *category;

@property (nonatomic,strong)UILabel *recentLabel;
@property (nonatomic,strong) CustomImageView *segmentImageView;

@end

@implementation AGEmojiKeyboardView

#pragma mark - View Related Methods

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<AGEmojiKeyboardViewDataSource>)dataSource {
  self = [super initWithFrame:frame];
  if (self) {
      self.clipsToBounds = NO;
      _dataSource = dataSource;
    self.category = [self categoryNameAtIndex:self.defaultSelectedCategory];
    self.backgroundColor = [UIColor colorWithRed:(float)248/255 green:(float)248/255 blue:(float)248/255 alpha:1.0];
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                  inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kBarHeight - pageControlSize.height)];
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    //重设frame,使其为整数避免产生模糊效果
    self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,0,
                                                       pageControlSize.width,
                                                       pageControlSize.height));
    [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
      
    [self addSubview:_pageControl];
      
    UIImage *leftCornerImage = [UIImage imageNamed:@"corner_left"];
    UIImage *rightCornerImage = [UIImage imageNamed:@"corner_right"];
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.bounds) - kBarHeight, CGRectGetWidth(self.bounds), kBarHeight);
    _segmentImageView = [[CustomImageView alloc] initWithFrame:frame
                                            buttonNormalImages:[self imagesForNonSelectedSegments]
                                          buttonSelectedImages:[self imagesForSelectedSegments]
                                               leftCornerImage:leftCornerImage
                                              rightCornerImage:rightCornerImage
                                                      delegate:self];
    
    _segmentImageView.image = [UIImage imageNamed:@"tab_bg"];
    _segmentImageView.userInteractionEnabled = YES;
    _segmentImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_segmentImageView];
      
      
      _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                   CGRectGetHeight(self.pageControl.bounds),
                                                                   CGRectGetWidth(self.bounds),
                                                                   CGRectGetHeight(self.bounds)  - (pageControlSize.height) - kBarHeight)];
      self.scrollView.pagingEnabled = YES;
      self.scrollView.showsHorizontalScrollIndicator = YES;
      self.scrollView.showsVerticalScrollIndicator = YES;
      self.scrollView.delegate = self;
      self.scrollView.clipsToBounds = YES;
      [self addSubview:self.scrollView];
  }
    
  return self;
}

- (void)layoutSubviews {
    
  [super layoutSubviews];
  CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
  NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                              inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentImageView.bounds) - pageControlSize.height)];

  NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;
  self.pageControl.numberOfPages = numberOfPages;
  pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
  self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,0,
                                                   pageControlSize.width,
                                                   pageControlSize.height));

  self.scrollView.frame = CGRectMake(0,CGRectGetHeight(self.pageControl.bounds),CGRectGetWidth(self.bounds),
                                   CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentImageView.bounds) - pageControlSize.height);
  [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * currentPage, 0);
  self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
  [self purgePageViews];
  self.pageViews = [NSMutableArray array];
  [self setPage:currentPage];
}

#pragma mark - Setter And Getter Methods

- (NSDictionary *)emojis {
  if (!_emojis) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    _emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
  }
  return _emojis;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
  NSArray *categoryList = @[segmentRecentName, @"People", @"Objects", @"Nature", @"Places", @"Symbols"];
  return categoryList[index];
}

- (AGEmojiKeyboardViewCategoryImage)defaultSelectedCategory {
  if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
    return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
  }
  return AGEmojiKeyboardViewCategoryImageRecent;
}

- (NSUInteger)recentEmojisMaintainedCount {
  if ([self.dataSource respondsToSelector:@selector(recentEmojisMaintainedCountForEmojiKeyboardView:)]) {
    return [self.dataSource recentEmojisMaintainedCountForEmojiKeyboardView:self];
  }
  return DefaultRecentEmojisMaintainedCount;
}

- (NSArray *)imagesForSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (AGEmojiKeyboardViewCategoryImage i = AGEmojiKeyboardViewCategoryImageRecent;
         i <= AGEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForSelectedCategory:i]];
    }
  });
  return array;
}

- (NSArray *)imagesForNonSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (AGEmojiKeyboardViewCategoryImage i = AGEmojiKeyboardViewCategoryImageRecent;
         i <= AGEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForNonSelectedCategory:i]];
    }
    [array addObject:[UIImage imageNamed:@"backspace_n"]];
  });
  return array;
}

- (NSMutableArray *)recentEmojis {
  NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentUsedEmojiCharactersKey];
  NSMutableArray *recentEmojis = [emojis mutableCopy];
  if (recentEmojis == nil) {
    recentEmojis = [NSMutableArray array];
  }
  return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
  if ([recentEmojis count] > self.recentEmojisMaintainedCount) {
    NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.recentEmojisMaintainedCount, [recentEmojis count] - self.recentEmojisMaintainedCount)];
    [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
  }
  [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:RecentUsedEmojiCharactersKey];
}

#pragma mark event handlers

- (void)pageControlTouched:(UIPageControl *)sender {
  CGRect bounds = self.scrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  [self.scrollView scrollRectToVisible:bounds animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

  CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
  NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  if (self.pageControl.currentPage == newPageNumber) {
    return;
  }
  self.pageControl.currentPage = newPageNumber;
  [self setPage:self.pageControl.currentPage];
}

#pragma mark - ButtonIndexChanged Delegate

- (void)segButtonDidChanged:(UIButton *)sender{
    self.category = [self categoryNameAtIndex:sender.tag - 1];
    self.pageControl.currentPage = 0;
    [self setNeedsLayout];
}

//change this to send message or emoji
- (void)backspaceButtonDidPress{
    [self.delegate emojiKeyBoardViewDidPressSend:self];
}

#pragma mark change a page on scrollView

- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
  if (index >= self.pageControl.numberOfPages) {
    return NO;
  }
  for (AGEmojiPageView *page in self.pageViews) {
    if ((page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds)) == index) {
      return NO;
    }
  }
  return YES;
}

- (AGEmojiPageView *)synthesizeEmojiPageView {
  NSUInteger rows = [self numberOfRowsForFrameSize:self.scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:self.scrollView.bounds.size];
  AGEmojiPageView *pageView = [[AGEmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds),CGRectGetHeight(self.scrollView.bounds))
                                                          buttonSize:CGSizeMake(ButtonWidth, ButtonHeight)
                                                                rows:rows
                                                             columns:columns];
  pageView.delegate = self;
  [self.pageViews addObject:pageView];
  [self.scrollView addSubview:pageView];
  return pageView;
}

- (AGEmojiPageView *)usableEmojiPageView {
  AGEmojiPageView *pageView = nil;
  for (AGEmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds);
    if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self synthesizeEmojiPageView];
  }
  return pageView;
}

- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {
  
  if (![self requireToSetPageViewForIndex:index]) {
    return;
  }
  
  AGEmojiPageView *pageView = [self usableEmojiPageView];
    
  NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
  NSUInteger startingIndex = index * rows * columns;
  NSUInteger endingIndex = (index + 1) * rows * columns -1 ;
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                  fromIndex:startingIndex
                                                    toIndex:endingIndex];
  [pageView setButtonTexts:buttonTexts];
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds), 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
}

- (void)setPage:(NSInteger)page {
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page - 1];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page + 1];
}

- (void)purgePageViews {
  for (AGEmojiPageView *page in self.pageViews) {
    page.delegate = nil;
  }
  self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / ButtonWidth);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.height / ButtonHeight);
}

- (NSArray *)emojiListForCategory:(NSString *)category {
  if ([category isEqualToString:segmentRecentName]) {
    return [self recentEmojis];
  }
  return [self.emojis objectForKey:category];
}

- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _recentLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - RecentLabelWidth)/2, 0, RecentLabelWidth,37)];
    _recentLabel.backgroundColor = [UIColor clearColor];
    _recentLabel.font = [UIFont systemFontOfSize:RecentLabelFontSize];
    _recentLabel.textColor = [UIColor lightGrayColor];
    _recentLabel.textAlignment = NSTextAlignmentCenter;
    _recentLabel.text = NSLocalizedString(@"recent use", @"recent use");
    [self addSubview:_recentLabel];
  });
  
  if ([category isEqualToString:segmentRecentName]) {
    _recentLabel.hidden = NO;
    return 1;
    }
  
  _recentLabel.hidden = YES;

  NSUInteger emojiCount = [[self emojiListForCategory:category] count];
  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = numberOfRows * numberOfColumns;
  NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);

  return numberOfPages;
}


- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
  NSArray *emojis = [self emojiListForCategory:category];
  end = ([emojis count] > end)? end : [emojis count];
  NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)setInRecentsEmoji:(NSString *)emoji {
  NSAssert(emoji != nil, @"Emoji can't be nil");
  
  NSMutableArray *recentEmojis = [self recentEmojis];
  for (int i = 0; i < [recentEmojis count]; ++i) {
    if ([recentEmojis[i] isEqualToString:emoji]) {
      [recentEmojis removeObjectAtIndex:i];
    }
  }
  [recentEmojis insertObject:emoji atIndex:0];
  [self setRecentEmojis:recentEmojis];
}

- (void)emojiPageView:(AGEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
  [self setInRecentsEmoji:emoji];
  [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(AGEmojiPageView *)emojiPageView {
  [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
}

@end