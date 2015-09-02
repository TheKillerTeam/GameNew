//
//  playerCell.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/24.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "playerCell.h"

@implementation playerCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor=[UIColor colorWithWhite:1 alpha:0];
    self.playerPhoto.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
