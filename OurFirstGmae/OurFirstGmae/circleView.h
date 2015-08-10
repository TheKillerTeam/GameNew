//
//  circleView.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/26.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface circleView : UIView<UIGestureRecognizerDelegate>
{
    CGFloat radius;
    CGFloat avg_radina;
    CGPoint dra_point;
    NSInteger step;
    CGPoint center;
}
@property(weak,nonatomic)NSMutableArray *ImgArray;


-(void)loadView;
@end