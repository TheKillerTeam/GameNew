//
//  ViewController.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/17.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dragImageView.h"

@class Match;

@interface ViewController : UIViewController

@property (nonatomic, strong) Match *match;
@property (nonatomic, strong) UIImage *playerImage;

@end

