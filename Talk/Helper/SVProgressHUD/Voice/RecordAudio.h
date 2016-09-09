//
//  RecordAudio.h
//  Talk
//
//  Created by Suric on 15/5/29.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "amrFileCodec.h"

@protocol RecordAudioDelegate <NSObject>
-(void)RecordStatus:(int)status; //0 播放 1 播放完成 2出错
@end

@interface RecordAudio : NSObject <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    //Variables setup for access in the class:
	NSURL * recordedTmpFile;
	NSError * error;
}
@property (assign,nonatomic)id<RecordAudioDelegate> delegate;
@property (strong, nonatomic)AVAudioRecorder *recorder;
@property (strong, nonatomic)AVAudioPlayer *avPlayer;

- (void)startRecord;
- (NSURL *)stopRecord;
- (void)cancelRecord;

-(void)play:(NSData *)data;
-(void)stopPlay;

+(NSTimeInterval) getAudioTime:(NSData *) data;

@end
