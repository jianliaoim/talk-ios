//
//  RecordAudio.m
//  Talk
//
//  Created by Suric on 15/5/29.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "RecordAudio.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"
#import <UIKit/UIKit.h>

@implementation RecordAudio

-(id)init {
    self = [super init];
    if (self) {
        //Instanciate an instance of the AVAudioSession object.
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        //Setup the audioSession for playback and record. 
        //We could just use record and then switch it to playback leter, but
        //since we are going to do both lets set it up once
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        //Activate the session
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        
        NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                       [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       nil];
        recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
        self.recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:nil];
        [self.recorder setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    self.recorder = nil;
    recordedTmpFile = nil;
    [self.avPlayer stop];
    self.avPlayer = nil;
}

#pragma mark - Public Methods

+(NSTimeInterval)getAudioTime:(NSData *) data {
    NSError * error;
    AVAudioPlayer*play = [[AVAudioPlayer alloc] initWithData:data error:&error];
    NSTimeInterval n = [play duration];
    return n;
}

-(NSData *)decodeAmr:(NSData *)data{
    if (!data) {
        return data;
    }
    return DecodeAMRToWAVE(data);
}

-(void)play:(NSData*) data{
    //Setup the AVAudioPlayer to play the file that we just recorded.
    //在播放时，只停止
    if (self.avPlayer!=nil) {
        [self stopPlay];
        return;
    }
    DDLogDebug(@"start decode");
    NSData *voiceData  = [self decodeAmr:data];
    DDLogDebug(@"end decode");
    self.avPlayer = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
    self.avPlayer.delegate = self;
    [self handleNotification:YES];
    [self.avPlayer prepareToPlay];
    [self.avPlayer setVolume:1.0];
    if(![self.avPlayer play]){
        [self sendStatus:1];
    } else {
        [self sendStatus:0];
    }
}

-(void)stopPlay {
    if (self.avPlayer!=nil) {
        [self handleNotification:NO];
        [self.avPlayer stop];
        self.avPlayer = nil;
        [self sendStatus:1];
    }
}

-(void)startRecord {
    [self.recorder record];
    [self.recorder recordForDuration:(NSTimeInterval) 60];
}

- (NSURL *)stopRecord {
    NSURL *url = [[NSURL alloc]initWithString:self.recorder.url.absoluteString];
    [self.recorder stop];
    //self.recorder =nil;
    return url;
}

- (void)cancelRecord {
    [self.recorder stop];
    [self.recorder deleteRecording];
}

#pragma mark - Private Methods

//0 播放 1 播放完成 2出错
-(void)sendStatus:(int)status {
    
    if ([self.delegate respondsToSelector:@selector(RecordStatus:)]) {
        [self.delegate RecordStatus:status];
    }
    
    if (status!=0) {
        if (self.avPlayer!=nil) {
            [self.avPlayer stop];
            self.avPlayer = nil;
        }
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
}

#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        DDLogDebug(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        DDLogDebug(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self handleNotification:NO];
    [self sendStatus:1];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [self handleNotification:NO];
    [self sendStatus:2];
}

#pragma mark - AVAudioRecorderDelegate

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    DDLogDebug(@"Recorder Finish");
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    DDLogDebug(@"Recorder Error");
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
