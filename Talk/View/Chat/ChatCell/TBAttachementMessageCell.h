//
//  TBAttachementMessageCell.h
//  Talk
//
//  Created by Suric on 15/9/25.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "TBChatBaseCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "TBAttachment.h"

@protocol TBAttachementMessageCellDelegate <NSObject>

- (void)enterRoomWithId:(NSString *)roomId;

@end

@interface TBAttachementMessageCell : TBChatBaseCell

@property (weak, nonatomic) IBOutlet UIButton *bubbleButton;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;
@property (strong, nonatomic) TBMessage *message;
@property (strong, nonatomic) TBAttachment *attachment;
@property (assign, nonatomic) id<TBAttachementMessageCellDelegate> delegate;

- (void)setMessage:(TBMessage *)message  andAttachment:(TBAttachment *)attachment;
+ (CGFloat)calculateCellHeightForAttachment:(TBAttachment *)attachment;

@end
