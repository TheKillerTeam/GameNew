//
//  clothCell.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/30.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "clothCell.h"

@implementation clothCell


-(void)layoutSubviews{
    [super layoutSubviews];
    // grab bound for contentView
    CGRect contentViewBound = self.contentView.bounds;
    // grab the frame for the imageView
    CGRect imageViewFrame = self.imageView.frame;
    // change x position
    imageViewFrame.origin.x = contentViewBound.size.width - imageViewFrame.size.width-80;
    
    imageViewFrame.size.width=120;
    // assign the new frame
    self.imageView.frame = imageViewFrame;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
