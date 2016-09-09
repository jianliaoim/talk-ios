//
//  VoicePlayViewController.m
//  Talk
//
//  Created by Suric on 15/6/3.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "VoicePlayViewController.h"
#import "TBVoiceCell.h"
#import "UIColor+TBColor.h"
#import "RecordAudio.h"
#import "TBUtility.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "TBAttachment.h"

static NSString * const cellIdentifier = @"TBVoiceCell";

@interface VoicePlayViewController ()<TBVoiceCellDelegate,RecordAudioDelegate> {
    RecordAudio *recordAudio;
}
@end

@implementation VoicePlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 80;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.backgroundColor = [UIColor tb_BackgroundColor];
    
    recordAudio = [[RecordAudio alloc]init];
    recordAudio.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [recordAudio stopPlay];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBVoiceCell *voiceCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    voiceCell.bubbleTintColor = [UIColor jl_redColor];
    voiceCell.message = self.message;
    voiceCell.delegate = self;
    return voiceCell;
}

#pragma mark - TBVoiceCellDelegate
- (void)stopVoicePlay {
    [recordAudio stopPlay];
}

- (void)playVoiceWithMessage:(TBMessage *)messageModel {
    TBAttachment *attachment = [messageModel.attachments firstObject];
    NSString *fileKey = attachment.data[kFileKey];
    NSURL *downloadURL = [NSURL URLWithString:attachment.data[kFileDownloadUrl]];
    NSString *localVoicePath = [TBUtility getVoiceLocalPathWithFileKey:fileKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localVoicePath]) {
        NSData *voiceData = [NSData dataWithContentsOfFile:localVoicePath];
        [recordAudio play:voiceData];
        return;
    }
    // If it's not a local file, put a placeholder instead
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    
    AFHTTPRequestOperation * tempRequest = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    tempRequest.outputStream = [NSOutputStream outputStreamToFileAtPath:localVoicePath append:NO];
    [tempRequest setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat progress = (totalBytesRead*1.0) / totalBytesExpectedToRead;
        DDLogDebug(@"voice downloading:%2f",progress);
    }];
    
    [tempRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *voiceData = [NSData dataWithContentsOfFile:localVoicePath];
            [recordAudio play:voiceData];
        });
    }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       }];
    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:tempRequest];
}

#pragma - mark RecordAudioDelegate

-(void)RecordStatus:(int)status {
    if (status==0){
        //playing
    } else if(status==1){
        //done
        DDLogDebug(@"播放完成");
    }else if(status==2){
        //failed
        DDLogDebug(@"播放出错");
    }
}

@end
