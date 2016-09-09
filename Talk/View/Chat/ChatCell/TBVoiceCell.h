//
//  TBVoiceCell.h
//  Talk
//
//  Created by Suric on 15/5/11.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TbChatTableViewCell.h"
#import "TWRProgressView.h"

static  CGFloat const cornerRadius = 18;
static  CGFloat const voiceMinLength = 98;
static  CGFloat const voiceMaxLength = 190;

@protocol TBVoiceCellDelegate <NSObject>

- (void)playVoiceWithMessage:(TBMessage *)message;
- (void)stopVoicePlay;

@end

@interface TBVoiceCell : TbChatTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet TWRProgressView *playProgressView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unreadDotIamgeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceLengthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLengthConstraint;

@property (assign ,nonatomic) id<TBVoiceCellDelegate> delegate;
@property (strong,nonatomic) NSTimer *timer;
@property (nonatomic) CGFloat currentPlaySecond;
@property (nonatomic) BOOL isPlay;

- (IBAction)playMessage:(id)sender;
+ (CGFloat)calculateCellHeight;

@end
