//
//   Copyright 2014 Slack Technologies, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "SLKTextInputbar.h"
#import "SLKTextView.h"
#import "ChatViewController.h"

#import "UITextView+SLKAdditions.h"
#import "UIView+SLKAdditions.h"

#import "SLKUIConstants.h"

#import "NSString+Emoji.h"
#import "UIColor+TBColor.h"

NSString * const SCKInputAccessoryViewKeyboardFrameDidChangeNotification = @"com.slack.TextViewController.TextInputbar.FrameDidChange";

@interface SLKTextInputbar () <UITextViewDelegate>

@property (nonatomic, strong) NSLayoutConstraint *leftButtonWC;
@property (nonatomic, strong) NSLayoutConstraint *leftButtonHC;
@property (nonatomic, strong) NSLayoutConstraint *leftMarginWC;

@property (nonatomic, strong) NSLayoutConstraint *centerButtonWC;
@property (nonatomic, strong) NSLayoutConstraint *centerButtonHC;
@property (nonatomic, strong) NSLayoutConstraint *centerMarginWC;

@property (nonatomic, strong) NSLayoutConstraint *rightButtonWC;
@property (nonatomic, strong) NSLayoutConstraint *rightButtonHC;
@property (nonatomic, strong) NSLayoutConstraint *rightMarginWC;

@property (nonatomic, strong) NSLayoutConstraint *bottomMarginWC;
@property (nonatomic, strong) NSLayoutConstraint *accessoryViewHC;

@property (nonatomic) BOOL newWordInserted;

@end

@implementation SLKTextInputbar

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.contentInset = UIEdgeInsetsMake(5.0, 8.0, 5.0, 8.0);
    
    [self addSubview:self.leftButton];
    [self addSubview:self.centerButton];
    [self addSubview:self.rightButton];
    [self addSubview:self.textView];
    [self setupViewConstraints];
    [self addVoiceView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextView:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)addVoiceView {
    [self addSubview:self.speakButton];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.speakButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.speakButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.speakButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.speakButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}

#pragma mark - UIView Overrides

- (void)layoutIfNeeded
{
    if (self.constraints.count == 0) {
        return;
    }
    
    [self updateConstraintConstants];
    [super layoutIfNeeded];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0);
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}


#pragma mark - Getters

- (SLKTextView *)textView
{
    if (!_textView)
    {
        _textView = [SLKTextView new];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.font = [UIFont systemFontOfSize:15.0];
        _textView.maxNumberOfLines = [self defaultNumberOfLines];
        _textView.delegate = self;
        
        _textView.autocorrectionType = UITextAutocorrectionTypeDefault;
        _textView.spellCheckingType = UITextSpellCheckingTypeDefault;
        _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _textView.keyboardType = UIKeyboardTypeDefault;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1);
        _textView.textContainerInset = UIEdgeInsetsMake(8.0, 3.5, 8.0, 0.0);
        _textView.layer.cornerRadius = 5.0;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
        
        // Adds an aditional action to a private gesture to detect when the magnifying glass becomes visible
        for (UIGestureRecognizer *gesture in _textView.gestureRecognizers) {
            if ([gesture isKindOfClass:NSClassFromString(@"UIVariableDelayLoupeGesture")]) {
                [gesture addTarget:self action:@selector(willShowLoupe:)];
            }
        }
    }
    return _textView;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_leftButton setImage:[UIImage imageNamed:@"icon-voice" inBundle:nil compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [_leftButton setTintColor:[UIColor grayColor]];
       }
    return _leftButton;
}

- (UIButton *)centerButton {
    if (!_centerButton) {
        _centerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _centerButton.translatesAutoresizingMaskIntoConstraints = NO;
        _centerButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_centerButton setImage:[UIImage imageNamed:@"icon-emoji" inBundle:nil compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [_centerButton setTintColor:[UIColor grayColor]];
    }
    return _centerButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        _rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_rightButton setImage:[UIImage imageNamed:@"icon-camera" inBundle:nil compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [_rightButton setTintColor:[UIColor grayColor]];
    }
    return _rightButton;
}

- (UIButton *)speakButton {
    if (!_speakButton) {
        _speakButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_speakButton setTitle:NSLocalizedString(@"Tap to speak", @"Tap to speak") forState:UIControlStateNormal];
        [self.speakButton setTitle:NSLocalizedString(@"Release to end", @"Release to end") forState:UIControlStateHighlighted];
        _speakButton.translatesAutoresizingMaskIntoConstraints = NO;
        _speakButton.layer.cornerRadius = 5.0;
        _speakButton.layer.masksToBounds = YES;
        _speakButton.layer.borderWidth = 0.5;
        [_speakButton setTitleColor:[UIColor tb_tableHeaderGrayColor] forState:UIControlStateNormal];
        _speakButton.layer.borderColor = [UIColor tb_borderColor].CGColor;
        _speakButton.layer.shadowColor =[[UIColor whiteColor]colorWithAlphaComponent:0.5].CGColor;
        _speakButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        _speakButton.hidden = YES;
    }
    return _speakButton;
}

- (NSUInteger)defaultNumberOfLines
{
    if (UI_IS_IPAD) {
        return 8;
    }
    if (UI_IS_IPHONE4) {
        return 4;
    }
    else {
        return 6;
    }
}


- (CGFloat)appropriateRightButtonWidth
{
    NSString *title = [self.rightButton titleForState:UIControlStateNormal];
    CGSize rigthButtonSize = [title sizeWithAttributes:@{NSFontAttributeName: self.rightButton.titleLabel.font}];
    return rigthButtonSize.width+self.contentInset.right;
}

- (CGFloat)appropriateRightButtonMargin
{
    return self.contentInset.right;
}


#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)color
{
    self.barTintColor = color;
    self.textView.inputAccessoryView.backgroundColor = color;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, contentInset)) {
        return;
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsZero)) {
        _contentInset = contentInset;
        return;
    }
    
    _contentInset = contentInset;
    
    // Add new constraints
    [self removeConstraints:self.constraints];
    [self setupViewConstraints];
    
    // Add constant values and refresh layout
    [self updateConstraintConstants];
    [super layoutIfNeeded];
}


#pragma mark - Magnifying Glass handling

- (void)willShowLoupe:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.textView.loupeVisible = YES;
    }
    else {
        self.textView.loupeVisible = NO;
    }
    
    // We still need to notify a selection change in the textview after the magnifying class is dismissed
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self textViewDidChangeSelection:self.textView];
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   
    self.newWordInserted = ([text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound);
    
    // Records text for undo for every new word
    if (self.newWordInserted) {
        [self.textView prepareForUndo:@"Word Change"];
    }
    
    if ([text isEqualToString:@"\n"]) {
        //Detected break. Should insert new line break manually. 修改return按钮事件
        //[textView slk_insertNewLineBreak];
        NSDictionary *userInfo = @{@"text": text};
        [[NSNotificationCenter defaultCenter] postNotificationName:SLKTextViewTextDidPressReturnKey object:self.textView userInfo:userInfo];
        return NO;
    }
    else {
        NSDictionary *userInfo = @{@"text": text, @"range": [NSValue valueWithRange:range]};
        [[NSNotificationCenter defaultCenter] postNotificationName:SLKTextViewTextWillChangeNotification object:self.textView userInfo:userInfo];
        
        return YES;
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (self.textView.isLoupeVisible) {
        return;
    }
    
    NSDictionary *userInfo = @{@"range": [NSValue valueWithRange:textView.selectedRange]};
    [[NSNotificationCenter defaultCenter] postNotificationName:SLKTextViewSelectionDidChangeNotification object:self.textView userInfo:userInfo];
}

- (void)didChangeTextView:(NSNotification *)notification
{
    SLKTextView *textView = (SLKTextView *)notification.object;
    
    // Skips this it's not the expected textView.
    if (![textView isEqual:self.textView]) {
        return;
    }
}

#pragma mark - View Auto-Layout

- (void)setupViewConstraints
{
    UIImage *leftButtonImg = [self.leftButton imageForState:UIControlStateNormal];
    CGFloat leftVerMargin = (self.intrinsicContentSize.height - leftButtonImg.size.height) / 2.0;
    
    UIImage *centerButtonImg = [self.centerButton imageForState:UIControlStateNormal];
    CGFloat centerVerMargin = (self.intrinsicContentSize.height - centerButtonImg.size.height) / 2.0;
    
    UIImage *rightButtonImg = [self.rightButton imageForState:UIControlStateNormal];
    CGFloat rightVerMargin= (self.intrinsicContentSize.height - rightButtonImg.size.height) / 2.0;

    NSDictionary *views = @{@"textView": self.textView,
                            @"leftButton": self.leftButton,
                            @"centerButton": self.centerButton,
                            @"rightButton": self.rightButton,
                            };
    
    NSDictionary *metrics = @{@"top" : @(self.contentInset.top),
                              @"bottom" : @(self.contentInset.bottom),
                              @"left" : @(self.contentInset.left),
                              @"right" : @(self.contentInset.right),
                              @"leftVerMargin" : @(leftVerMargin),
                              @"centerVerMargin" :@(centerVerMargin),
                              @"rightVerMargin" : @(rightVerMargin),
                              @"minTextViewHeight" : @(self.textView.intrinsicContentSize.height),
                              };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==left)-[leftButton(30)]-(<=left)-[textView]-(==right)-[centerButton(30)]-(==right)-[rightButton(30)]-(==right)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[leftButton(30)]-(8@750)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[centerButton(30)]-(<=centerVerMargin)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[rightButton(30)]-(<=rightVerMargin)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(<=top)-[textView(==minTextViewHeight@250)]-(==bottom)-|" options:0 metrics:metrics views:views]];
    
    NSArray *heightConstraints = [self slk_constraintsForAttribute:NSLayoutAttributeHeight];
    NSArray *widthConstraints = [self slk_constraintsForAttribute:NSLayoutAttributeWidth];
    NSArray *bottomConstraints = [self slk_constraintsForAttribute:NSLayoutAttributeBottom];

   // self.accessoryViewHC = heightConstraints[1];

    self.leftButtonWC = widthConstraints[0];
    self.leftButtonHC = heightConstraints[0];
    self.leftMarginWC = [self slk_constraintsForAttribute:NSLayoutAttributeLeading][0];
    self.bottomMarginWC = bottomConstraints[0];
    
    self.centerButtonWC = widthConstraints[0];
    self.centerButtonHC = heightConstraints[1];
    self.centerMarginWC = [self slk_constraintsForAttribute:NSLayoutAttributeLeading][0];
    
    self.rightButtonHC = heightConstraints[0];
    self.rightButtonWC = widthConstraints[2];
    self.rightMarginWC = [self slk_constraintsForAttribute:NSLayoutAttributeTrailing][0];
}

- (void)updateConstraintConstants
{
    CGFloat zero = 0.0;

    self.accessoryViewHC.constant = zero;
    
    CGSize leftButtonSize = [self.leftButton imageForState:self.leftButton.state].size;
    CGSize centerButtonSize = [self.centerButton imageForState:self.centerButton.state].size;
    CGSize rightButtonSize = [self.rightButton imageForState:self.rightButton.state].size;
    if (leftButtonSize.width > 0) {
        self.leftButtonHC.constant = roundf(leftButtonSize.height);
        self.centerButtonHC.constant = roundf(centerButtonSize.height);
        self.rightButtonHC.constant = roundf(rightButtonSize.height);
        self.bottomMarginWC.constant = roundf((self.intrinsicContentSize.height - rightButtonSize.height) / 2.0);
    }
    
    self.leftButtonWC.constant = roundf(leftButtonSize.width);
    self.leftMarginWC.constant = (leftButtonSize.width > 0) ? self.contentInset.left : zero;
    
    self.centerButtonWC.constant = roundf(centerButtonSize.width);
    self.centerMarginWC.constant = (centerButtonSize.width > 0) ? self.contentInset.left : zero;
    
    self.rightButtonWC.constant = roundf(rightButtonSize.width);
    self.rightMarginWC.constant = (rightButtonSize.width > 0) ? self.contentInset.right : zero;
}

#pragma mark - Lifeterm

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SLKTextViewContentSizeDidChangeNotification object:nil];
    
    _leftButton = nil;
    _centerButton = nil;
    _rightButton = nil;
    
    _textView.delegate = nil;
    _textView = nil;
    
    _leftButtonWC = nil;
    _leftButtonHC = nil;
    _leftMarginWC = nil;
    _bottomMarginWC = nil;
    
    _centerButtonWC = nil;
    _centerButtonHC = nil;
    _centerMarginWC = nil;
    
    _rightButtonWC = nil;
    _rightButtonHC = nil;
    _rightMarginWC = nil;
    _accessoryViewHC = nil;
}

@end
