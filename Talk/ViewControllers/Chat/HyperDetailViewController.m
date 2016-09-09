//
//  HyperDetailViewController.m
//  Talk
//
//  Created by teambition-ios on 15/2/28.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "HyperDetailViewController.h"
#import "TBUtility.h"

@interface HyperDetailViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation HyperDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.loadingView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"style" withExtension:@"css"];
    NSString *html = [NSString stringWithFormat:@"<link rel=\"stylesheet\" href=\"%@\"/>", url];
    NSString *htmlString = [html stringByAppendingString:[TBUtility dealForNilWithString:self.hyperString]];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.webView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backAction:(UIBarButtonItem *)backItem
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark-UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loadingView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingView stopAnimating];
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.loadingView stopAnimating];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
