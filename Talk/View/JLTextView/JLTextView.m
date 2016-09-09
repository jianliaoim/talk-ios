//
//  JLTextView.m
//  Talk
//
//  Created by 王卫 on 15/11/13.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLTextView.h"
#import <Masonry.h>

@interface JLTextView ()

@property (strong, nonatomic) UILabel *placeHolderLabel;

@end

@implementation JLTextView

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidTextDidChange:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification
                                                        object:self];
}

- (void)textViewDidTextDidChange:(NSNotification *)aNotification {
    JLTextView *textView = aNotification.object;
    if (textView.text.length > 0) {
        self.placeHolderLabel.hidden = YES;
    } else {
        self.placeHolderLabel.hidden = NO;
    }
    
}

- (void)setPlaceHolder:(NSAttributedString *)placeHolder {
    if (!placeHolder) {
        return;
    }
    _placeHolder = placeHolder;
    self.placeHolderLabel.attributedText = placeHolder;
}

- (UILabel *)placeHolderLabel {
    if (!_placeHolderLabel) {
        _placeHolderLabel = [[UILabel alloc] init];
        [self addSubview:_placeHolderLabel];
        UIEdgeInsets insets = self.textContainerInset;
        [_placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(insets.top);
            make.leading.equalTo(self.mas_leading).with.offset(insets.left+4);
        }];
    }
    return _placeHolderLabel;
}

@end
