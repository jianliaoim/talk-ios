//
//  TeamLoadingView.h
//  
//
//  Created by Suric on 15/7/24.
//
//

#import <UIKit/UIKit.h>
#import "Talk-Swift.h"

@interface TeamLoadingView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *teamNameImageView;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet SpringIndicator *loadingView;

@end
