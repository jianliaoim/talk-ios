//
//  TeamLoadingView.m
//  
//
//  Created by Suric on 15/7/24.
//
//

#import "TeamLoadingView.h"

@implementation TeamLoadingView

- (void)awakeFromNib {
    self.loadingView.lineWidth = 4.0;
    self.loadingView.lotateDuration = 1.0;
    self.loadingView.strokeDuration = 1.0;
    self.loadingView.lineColor = [UIColor jl_redColor];
    self.loadingView.backgroundColor = [UIColor clearColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
