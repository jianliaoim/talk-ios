//
//  MultiLanguageTableViewController.m
//  Talk
//
//  Created by 王卫 on 16/1/19.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "MultiLanguageTableViewController.h"
#import "UIColor+TBColor.h"
#import "constants.h"

//to-do: Modify to hide more detail
@interface MultiLanguageTableViewController ()

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (assign, nonatomic) JLUserLanguage currentLanguage;

@end

static NSString *const kCellIdentifier = @"CellIdentifier";

@implementation MultiLanguageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Language", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveInAppLanguageSetting)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.currentLanguage = [JLInternationalManager userLanguage];
    self.selectedIndexPath = [NSIndexPath indexPathForItem:self.currentLanguage inSection:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)saveInAppLanguageSetting {
    switch (self.selectedIndexPath.row) {
        case 0:
            [JLInternationalManager setUserLanguage:JLUserLanguageZHHans];
            break;
        case 1:
            [JLInternationalManager setUserLanguage:JLUserLanguageEN];
    }
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLanguageDidChangeNotification object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [JLInternationalManager availableLanguages].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.tintColor = [UIColor jl_redColor];
    
    NSString *languageKey = [JLInternationalManager availableLanguages][indexPath.row];
    cell.textLabel.text = [JLInternationalManager mapLanguageKeyToName:languageKey];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [self.tableView reloadData];
    if (self.currentLanguage == indexPath.row ) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

@end
