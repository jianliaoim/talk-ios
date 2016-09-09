//
//  AGEmojiPageView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13, updated by zhangxiaolian from jiaoliao on 2014-10-16
//  Copyright (c) 2013 Ayush and zhangxiaolian. All rights reserved.
//

#import "AGEmojiPageView.h"
#import "AGEmojiKeyBoardView.h"

#define BUTTON_FONT_SIZE 32
#define DELETE_LABEL_TAG 1000001

@interface AGEmojiPageView ()

@property (nonatomic) CGSize buttonSize;
@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) NSUInteger columns;
@property (nonatomic) NSUInteger rows;

@property (nonatomic,strong) NSArray *emojiArray;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) UIImageView *zoomImageView;
@property (nonatomic,strong) UILabel *emojiLabel;

@end

@implementation AGEmojiPageView

- (id)initWithFrame:(CGRect)frame
         buttonSize:(CGSize)buttonSize
               rows:(NSUInteger)rows
            columns:(NSUInteger)columns {
    self = [super initWithFrame:frame];
    if (self) {
        _buttonSize = buttonSize;
        _columns = columns;
        _rows = rows;
        _buttons = [[NSMutableArray alloc] initWithCapacity:rows * columns];
    }
    return self;
}

- (void)setButtonTexts:(NSMutableArray *)buttonTexts {
    
    NSAssert(buttonTexts != nil, @"Array containing texts to be set on buttons is nil");
    _emojiArray = buttonTexts;
    
    if (([self.buttons count] - 1) == [buttonTexts count]) {
        // just reset text on each button
        for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
            [self.buttons[i] setText:buttonTexts[i]];
        }
    } else {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.buttons = nil;
        self.buttons = [NSMutableArray arrayWithCapacity:self.rows * self.columns];
        for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
            UILabel *button = [self createButtonAtIndex:i];
            button.text = buttonTexts[i];
            [self addToViewButton:button];
        }
    }
    //add delete button to every page
    UILabel *deleteLabel = [self createButtonAtIndex:[self.buttons count]];
    
   if ([[[UIDevice currentDevice]systemVersion ]intValue] >= 8.0)
    {
      deleteLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"emoji-delete"]];
    }
    else
    {
        deleteLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"emoji-delete-ios7"]];
    }
    deleteLabel.tag = DELETE_LABEL_TAG;
    [self addToViewButton:deleteLabel];
}

- (void)addToViewButton:(UILabel *)button {
    NSAssert(button != nil, @"Button to be added is nil");
    
    [self.buttons addObject:button];
    [self addSubview:button];
}

- (CGFloat)XMarginForButtonInColumn:(NSInteger)column {
    CGFloat padding = ((CGRectGetWidth(self.bounds) - self.columns * self.buttonSize.width) / self.columns);
    return (padding / 2 + column * (padding + self.buttonSize.width));
}

- (CGFloat)YMarginForButtonInRow:(NSInteger)rowNumber {
    CGFloat padding = ((CGRectGetHeight(self.bounds) - self.rows * self.buttonSize.height) / self.rows);
    return (padding / 2 + rowNumber * (padding + self.buttonSize.height))-8;
}

- (UILabel *)createButtonAtIndex:(NSUInteger)index {
    UILabel *button = [[UILabel alloc]init];
    button.userInteractionEnabled = YES;
    button.font = [UIFont fontWithName:@"Apple color emoji" size:BUTTON_FONT_SIZE];
    NSInteger row = (NSInteger)(index / self.columns);
    NSInteger column = (NSInteger)(index % self.columns);
    button.frame = CGRectIntegral(CGRectMake([self XMarginForButtonInColumn:column],
                                             [self YMarginForButtonInRow:row],
                                             self.buttonSize.width,
                                             self.buttonSize.height));
    button.textAlignment = NSTextAlignmentCenter;
    //[button addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tempTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emojiButtonPressed:)];
    
    [button addGestureRecognizer:tempTap];
    
    return button;
}

-(void)deleteEmojiPressed:(id)sender
{
     [self.delegate emojiPageViewDidPressBackSpace:nil];
}

- (void)emojiButtonPressed:(UITapGestureRecognizer *)tapGesture {
    
    UILabel *tempLable = (UILabel *)tapGesture.view;
    
    if (tempLable.tag == DELETE_LABEL_TAG) {
        DDLogDebug(@"deleting emoji");
        [self.delegate emojiPageViewDidPressBackSpace:nil];
    } else {
        [self.delegate emojiPageView:self didUseEmoji:tempLable.text];
    }
}

- (void)showImageViewWithAtXIndex:(NSUInteger)xIndex yIndex:(NSUInteger)yIndex image:(UIImage *)image {
    if (_index >= 0 && _index < _emojiArray.count) {
        if (_zoomImageView == nil) {
            _zoomImageView = [[UIImageView alloc] initWithImage:image];
            _zoomImageView.frame = CGRectZero;
            _emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 50, 50)];
            _emojiLabel.font = [UIFont fontWithName:@"Apple color emoji" size:40];
            _emojiLabel.textAlignment = NSTextAlignmentCenter;
            [_zoomImageView addSubview:_emojiLabel];
            _zoomImageView.hidden = YES;
            self.clipsToBounds = NO;
        }
        if (![self.subviews containsObject:_zoomImageView]) {
            [self addSubview:_zoomImageView];
        }
        _zoomImageView.frame = CGRectMake([self XMarginForButtonInColumn:xIndex] - 15, [self YMarginForButtonInRow:yIndex - 1] - 20, 77, 111);
        _zoomImageView.hidden = NO;
        _emojiLabel.text = _emojiArray[xIndex + yIndex * _columns];
    }
}

@end
