//
//  TagsViewControllerTest.m
//  Talk
//
//  Created by 史丹青 on 8/4/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "TagsViewModel.h"
#import "TagsViewController.h"
#import "MSCMoreOptionTableViewCell.h"

@interface TagsViewControllerTest : XCTestCase

@property (nonatomic, strong) AppDelegate *appdelegate;
@property (nonatomic, strong) TagsViewModel *viewModel;
@property (nonatomic, strong) TagsViewController *vc;

@property BOOL isFetchAllTagsRequestSuccess;

@end

@implementation TagsViewControllerTest

- (void)setUp {
    [super setUp];
    self.viewModel = [[TagsViewModel alloc] init];
    XCTAssertNotNil(self.viewModel, @"Cannot create tags view model");
    
    self.appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kTagsStoryboard bundle:nil];
    self.vc = [storyboard instantiateViewControllerWithIdentifier:@"TagsViewController"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFetchAllTags {
    // This is an example of a functional test case.
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    self.isFetchAllTagsRequestSuccess = NO;
    
    [[self.viewModel fetchAllTags] subscribeNext:^(id x) {
        self.isFetchAllTagsRequestSuccess = YES;
        [self.vc.tableView reloadData];
        [expectation fulfill];
    } error:^(NSError *error) {
        self.isFetchAllTagsRequestSuccess = NO;
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (!self.isFetchAllTagsRequestSuccess) {
            NSAssert(NO, @"fetch all tags wrong!");
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - UITableView tests
- (void)testThatViewConformsToUITableViewDataSource
{
    XCTAssertTrue([self.vc conformsToProtocol:@protocol(UITableViewDataSource) ], @"View does not conform to UITableView datasource protocol");
}

- (void)testThatTableViewHasDataSource
{
    XCTAssertNotNil(self.vc.tableView.dataSource, @"Table datasource cannot be nil");
}

- (void)testThatViewConformsToUITableViewDelegate
{
    XCTAssertTrue([self.vc conformsToProtocol:@protocol(UITableViewDelegate) ], @"View does not conform to UITableView delegate protocol");
}

- (void)testTableViewIsConnectedToDelegate
{
    XCTAssertNotNil(self.vc.tableView.delegate, @"Table delegate cannot be nil");
}

@end
