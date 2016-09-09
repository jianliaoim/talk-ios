//
//  JLGuideViewController.m
//  Talk
//
//  Created by 史丹青 on 1/18/16.
//  Copyright © 2016 Teambition. All rights reserved.
//

#import "JLGuideViewController.h"
#import "StyledPageControl.h"
#import "UIColor+TBColor.h"
#import "constants.h"

#define NUMBER_OF_PAGES 2

#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))

@interface JLGuideViewController ()

@property (nonatomic) NSInteger currentPageIndex;

//pageControl
@property (strong, nonatomic) StyledPageControl *pageControl;

//page1
@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UILabel *titleText1;
@property (strong, nonatomic) UIView *backgroundView1;

//page2
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UILabel *titleView2;
@property (strong, nonatomic) UIView *backgroundView2;
@property (strong, nonatomic) UIButton *startButton;

@end

@implementation JLGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //hide the status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    //set scrollview
    self.scrollView.contentSize = CGSizeMake(NUMBER_OF_PAGES * CGRectGetWidth(self.view.frame),
                                             CGRectGetHeight(self.view.frame));
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.accessibilityLabel = @"Intro";
    self.scrollView.accessibilityIdentifier = @"Talk";
    
    [self initPageControl];
    
    [self placeViews];
    //[self configureAnimation];
    
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - pageControl

- (void)initPageControl
{
    //init pagecontrol
    StyledPageControl *pageControl = [[StyledPageControl alloc] init];
    pageControl.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 14);
    pageControl.numberOfPages = NUMBER_OF_PAGES;
    pageControl.currentPage = 0;
    [pageControl setPageControlStyle:PageControlStyleDefault];
    [pageControl setCoreNormalColor:[UIColor colorWithRed:217/255.f green:217/255.f blue:217/255.f alpha:217/255.f]];
    [pageControl setCoreSelectedColor:[UIColor jl_guideBlueColor]];
    [pageControl setGapWidth:23];
    [pageControl setDiameter:14];
    self.pageControl = pageControl;
    [self.view addSubview:pageControl];
}

#pragma mark - placeViews

- (void)placeViews
{
    [self placeViewsOnPage1];
    [self placeViewsOnPage2];
}

- (void)placeViewsOnPage1
{
    self.backgroundView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.scrollView addSubview:self.backgroundView1];
    self.backgroundView1.backgroundColor = [UIColor jl_guideRedColor];
    
    self.imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide-page1"]];
    [self.scrollView addSubview:self.imageView1];
    [self.imageView1 setFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    [self.imageView1 setCenter:CGPointMake(self.view.center.x, self.view.center.y - kScreenHeight/8)];
    
    self.titleText1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    [self.scrollView addSubview:self.titleText1];
    [self.titleText1 setText:NSLocalizedString(@"Awesome design never stop", @"Awesome design never stop")];
    [self.titleText1 setFont:[UIFont fontWithName:@"Arial" size:20]];
    [self.titleText1 setTextAlignment:NSTextAlignmentCenter];
    [self.titleText1 setTextColor:[UIColor jl_guideBlueColor]];
    [self.titleText1 setCenter:CGPointMake(self.view.center.x, self.view.center.y + kScreenHeight/6)];
}

- (void)placeViewsOnPage2
{
    self.backgroundView2 = [[UIView alloc] initWithFrame:CGRectMake(timeForPage(2), 0, kScreenWidth, kScreenHeight)];
    [self.scrollView addSubview:self.backgroundView2];
    self.backgroundView2.backgroundColor = [UIColor jl_guideYellowColor];
    
    self.imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide-page2"]];
    [self.scrollView addSubview:self.imageView2];
    [self.imageView2 setFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    [self.imageView2 setCenter:CGPointMake(self.view.center.x + timeForPage(2), self.view.center.y - kScreenHeight/8)];
    
    self.titleView2 = [[UILabel alloc] initWithFrame:CGRectMake(timeForPage(2), 0, kScreenWidth, 30)];
    [self.scrollView addSubview:self.titleView2];
    [self.titleView2 setText:NSLocalizedString(@"Share everything on Talk", @"Share everything on Talk")];
    [self.titleView2 setFont:[UIFont fontWithName:@"Arial" size:20]];
    [self.titleView2 setTextAlignment:NSTextAlignmentCenter];
    [self.titleView2 setTextColor:[UIColor jl_guideBlueColor]];
    [self.titleView2 setCenter:CGPointMake(self.view.center.x + timeForPage(2), self.view.center.y + kScreenHeight/6)];
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    [self.scrollView addSubview:self.startButton];
    [self.startButton setTitle:NSLocalizedString(@"Begin Talk", @"Begin Talk") forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor jl_guideBlueColor] forState:UIControlStateNormal];
    self.startButton.layer.cornerRadius = self.startButton.frame.size.height/2;
    self.startButton.layer.masksToBounds = YES;
    self.startButton.layer.borderColor = [UIColor jl_guideBlueColor].CGColor;
    self.startButton.layer.borderWidth = 2;
    [self.startButton addTarget:self action:@selector(appStart) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.startButton];
    [self.startButton setCenter:CGPointMake(self.view.center.x + timeForPage(2), self.view.center.y + kScreenHeight/3)];
}

#pragma mark - click the start button

- (void)appStart
{
    NSLog(@"app starting...");
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - hide the status bar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    [super scrollViewDidScroll:self.scrollView];
    
    //set pageControl
    int pageIndex = 0;
    CGFloat pageWidth = self.scrollView.frame.size.width;
    pageIndex = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self.pageControl setHidden:NO];
    [self.pageControl setCoreSelectedColor:[UIColor jl_guideBlueColor]];
    
    [self.pageControl setCurrentPage:pageIndex];
}

#pragma mark - IFTTTAnimatedScrollViewControllerDelegate

- (void)animatedScrollViewControllerDidScrollToEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController
{
    NSLog(@"Scrolled to end of scrollview!");
}

- (void)animatedScrollViewControllerDidEndDraggingAtEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController
{
    NSLog(@"Ended dragging at end of scrollview!");
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
