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
    imageViewFrame.origin.x =0;
    imageViewFrame.origin.y =0;
    imageViewFrame.size.width=self.contentView.frame.size.width;
    imageViewFrame.size.height=self.contentView.frame.size.height;
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
