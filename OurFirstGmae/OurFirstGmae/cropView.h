//
//  cropView.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//typedef void(^PassImage)(UIImage *image);



@interface cropView : UIView<UITableViewDataSource,UITableViewDelegate>
{
//    UIImageView *mask;
    UIImageView *imageView;
    UITableView *clothFrame;
    NSArray *uniformArray ;
   
    UIImageView *mask;

}
@property(nonatomic,retain)IBOutlet UIImage*image;
@property(retain,nonatomic)UIImageView *clothImage;
@property(retain,nonatomic)UIImageView *cover;
//@property(strong,nonatomic)PassImage block;
-(void)step;
@end
