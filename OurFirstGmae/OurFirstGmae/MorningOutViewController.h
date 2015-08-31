//
//  MorningOutViewController.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/11.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MorningOutViewControllerDelegate <NSObject>

- (void)swiped;

@end

@interface MorningOutViewController : UIViewController

@property (nonatomic, strong) UIImage *playerImage;

@property (nonatomic, assign) BOOL autoSwipe;
@property (assign) id <MorningOutViewControllerDelegate> delegate;

@end
