//
//  TBAddTagCell.h
//  Talk
//
//  Created by 史丹青 on 7/16/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBAddTagCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tagName;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

- (void)setupCellWithTagName:(NSString *)name isSelected:(BOOL)isSelected;

- (void)changeStatus:(BOOL)isSelected;

@end
