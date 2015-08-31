//
//  cropView.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "clothCell.h"
//typedef void(^PassImage)(UIImage *image);



@interface cropView : UIView<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)IBOutlet UIImage*image;
@property(nonatomic,strong)IBOutlet UIImageView*sentView;
@property(nonatomic,strong)IBOutlet UIImageView* sendHeadImageView;



@end
