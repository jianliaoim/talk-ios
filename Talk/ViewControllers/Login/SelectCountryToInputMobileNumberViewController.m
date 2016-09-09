//
//  SelectCountryToInputMobileNumberViewController.m
//  Teambition
//
//  Created by hongxin on 15/6/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "SelectCountryToInputMobileNumberViewController.h"
#import "libPhoneNumber-iOS/NBPhoneNumberUtil.h"
#import "libPhoneNumber-iOS/NBMetadataHelper.h"
#import "Hanzi2Pinyin.h"
#import "SelectCountryCell.h"
#import "UIColor+TBColor.h"

@interface SelectCountryToInputMobileNumberViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic) NSMutableDictionary *countryDictionary;
@property (nonatomic) NSMutableArray *searchData;
@property (nonatomic) NSMutableArray *sortedKeys;
@property (nonatomic) NSMutableArray *majorCountries;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultController;

- (void)setupUI;
- (void)setup;

@end

@implementation SelectCountryToInputMobileNumberViewController

# pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Getter

- (UITableViewController *)searchResultController {
    if (!_searchResultController) {
        _searchResultController = [[UITableViewController alloc] init];
        _searchResultController.tableView.delegate = self;
        _searchResultController.tableView.dataSource = self;
    }
    return _searchResultController;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.searchBar.delegate = self;
        
        //Customize
        _searchController.dimsBackgroundDuringPresentation = YES;
        _searchController.searchBar.placeholder = NSLocalizedString(@"Choose country", @"Choose country");
        _searchController.searchBar.tintColor = [UIColor jl_redColor];
    }
    return _searchController;
}

- (void)setupUI {
    [self.tableView setBackgroundColor:[UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1]];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.sectionIndexColor = [UIColor jl_redColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.navigationController.navigationBar.tintColor = [UIColor tb_defaultColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    self.title = NSLocalizedString(@"Choose country", @"Choose country");
}

-(void)setup {
    self.searchData = [[NSMutableArray alloc] init];
    self.majorCountries = [[NSMutableArray alloc] init];
    self.sortedKeys = [[NSMutableArray alloc] init];
    self.countryDictionary = [[NSMutableDictionary alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    
    for(NSString *countryCode in [NSLocale ISOCountryCodes]) {
        TBCountry *newCountry = [[TBCountry alloc] init];
        newCountry.countryCode = countryCode;
        newCountry.name = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        newCountry.phoneCode = [[[NBMetadataHelper alloc] init] countryCodeFromRegionCode:countryCode];
        
        if ([countryCode isEqualToString:@"CN"] || [countryCode isEqualToString:@"HK"] || [countryCode isEqualToString:@"TW"] || [countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"JP"]) {
            [self.majorCountries addObject:newCountry];
        }
        
        NSString *newCountryName = newCountry.name;
        NSString *newCountryCountryCode = newCountry.countryCode;
        NSString *key;
        
        if (newCountryName) {
            //transfer Chinese countryname to pinyin
            if ([[locale objectForKey:NSLocaleLanguageCode] isEqualToString:@"zh"]) {
                newCountryName = [Hanzi2Pinyin convertToAbbreviation:newCountryName];
            }
            
            key = [[newCountryName substringToIndex:1] uppercaseString];
        } else {
            // fix iOS 8.1 country name nil bug
            key = [[newCountryCountryCode substringToIndex:1] uppercaseString];
        }
        
        if(!self.countryDictionary[key]) {
            self.countryDictionary[key] = [[NSMutableArray alloc] init];
        }
        
        if (newCountry.phoneCode) {
            [self.countryDictionary[key] addObject:newCountry];
        }
    }
    
    [self.sortedKeys addObject:@""];
    NSArray *sortedKeysTemp = [[self.countryDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.sortedKeys addObjectsFromArray:sortedKeysTemp];
}

#pragma mark - IBActions

- (void)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger numberOfSectionsInTableView;
    if (tableView == self.searchResultController.tableView) {
        numberOfSectionsInTableView = 1;
    } else {
        numberOfSectionsInTableView = self.sortedKeys.count;
    }
    return numberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfRowsInSection = 0;
    if (tableView == self.searchResultController.tableView) {
        numberOfRowsInSection = [self.searchData count];
    } else {
        if (section == 0) {
            numberOfRowsInSection = self.majorCountries.count;
        } else {
            numberOfRowsInSection = [self.countryDictionary[self.sortedKeys[section]] count];
        }
    }
    return numberOfRowsInSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleForHeaderInSection;
    if (tableView == self.tableView) {
        if (section == 0) {
            titleForHeaderInSection = NSLocalizedString(@"Popular Countries", @"Popular Countries");
        } else {
            titleForHeaderInSection = self.sortedKeys[section];
        }
    }
    return titleForHeaderInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    SelectCountryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SelectCountryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TBCountry *country;
    if (tableView == self.searchResultController.tableView)
    {
        country = (TBCountry *)self.searchData[indexPath.row];
    } else {
        if (indexPath.section == 0) {
            country = (TBCountry *)self.majorCountries[indexPath.row];
        } else {
            NSString *key = self.sortedKeys[indexPath.section];
            country = (TBCountry *)self.countryDictionary[key][indexPath.row];
        }
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", country.name];
    if (country.phoneCode) {
        cell.phoneCodeLabel.text = [NSString stringWithFormat:@"+%@", country.phoneCode];
    } else {
        cell.phoneCodeLabel.text = @"";
    }
    
    return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *sectionIndexTitlesForTableView = [[NSArray alloc] init];
    if (tableView == self.tableView) {
        sectionIndexTitlesForTableView = self.sortedKeys;
    }
    return sectionIndexTitlesForTableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == self.searchResultController.tableView) {
        self.selectedCountry = self.searchData[indexPath.row];
    } else {
        if (indexPath.section == 0) {
            self.selectedCountry = self.majorCountries[indexPath.row];
        } else {
            NSString *key = self.sortedKeys[indexPath.section];
            self.selectedCountry = self.countryDictionary[key][indexPath.row];
        }
    }
    [self.delegate selectedCountry:self.selectedCountry];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self.searchData removeAllObjects];
    
    if(searchString.length > 0) {
        NSString *key = [[searchString substringToIndex:1] uppercaseString];
        //transfer Chinese searchString to pinyin
        if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"zh"]) {
            NSString *searchStringPinYin = [Hanzi2Pinyin convertToAbbreviation:searchString];
            key = [[searchStringPinYin substringToIndex:1] uppercaseString];
        }
        
        for(TBCountry *country in self.countryDictionary[key]) {
            NSRange range = [country.name rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if(range.location == 0) {
                [self.searchData addObject:country];
            }
        }
    }
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}

@end
