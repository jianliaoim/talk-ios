//
//  TBTimeCell.h
//  
//
//  Created by Suric on 15/8/6.
//
//

#import <UIKit/UIKit.h>
#import "TBChatBaseCell.h"
#import "TBMessage.h"

@interface TBTimeCell : TBChatBaseCell

@property (weak, nonatomic) IBOutlet UILabel *userNameAndTimeLbl;
@property (strong, nonatomic) TBMessage *message;

+ (CGFloat)calculateCellHeight;

@end
