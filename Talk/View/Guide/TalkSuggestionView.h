//
//  TalkSuggestionView.h
//  Talk
//
//  Created by 史丹青 on 7/31/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TalkSuggestionDelegate <NSObject>

- (void)suggestionMethod;

@end

@interface TalkSuggestionView : UIView

@property (weak, nonatomic) IBOutlet UIView *guideView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *suggestion;
@property (weak, nonatomic) IBOutlet UIButton *doitButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) id<TalkSuggestionDelegate> delegate;

- (void)showWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle andSuggestion:(NSString *)suggestion;

@end
