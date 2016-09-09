//
//  ContactRecommendViewController.m
//  Talk
//
//  Created by 王卫 on 16/1/27.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "ContactRecommendViewController.h"
#import "PhoneContactViewController.h"
#import <Masonry.h>

@interface ContactRecommendViewController ()

@end

@implementation ContactRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"team-switch-close"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.title = NSLocalizedString(@"Add Phone Contact", nil);
    
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_recommend_guide"]];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(viewHeight/4.0);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UILabel *label = [UILabel new];
    label.text = NSLocalizedString(@"We need to collect your contacts. We won't leak your contacts without your permission.", nil);
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor colorWithRed:15.0/255.0 green:54.0/255.0 blue:102.0/255.0 alpha:1.0];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).with.offset(20);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    
    UIButton *button = [UIButton new];
    [button addTarget:self action:@selector(addButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    button.backgroundColor = [UIColor colorWithRed:15.0/255.0 green:54.0/255.0 blue:102.0/255.0 alpha:1.0];
    button.layer.cornerRadius = 24;
    button.clipsToBounds = YES;
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).with.offset(40);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(48);
    }];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addButtonTap {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"AddMemberMethods" bundle:nil];
    PhoneContactViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"PhoneContactViewController"];
    viewController.currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Contact Recommend Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
