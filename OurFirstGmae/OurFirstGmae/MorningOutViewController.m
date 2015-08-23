//
//  MorningOutViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/11.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "MorningOutViewController.h"

@interface MorningOutViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *morningOutImgView;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swip;

@end

@implementation MorningOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *view =[[UIView alloc]initWithFrame:self.view.frame];
    view.backgroundColor=[UIColor blackColor];
    view.alpha=0.5;
    [self.view insertSubview:view belowSubview:_morningOutImgView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swipeUp:(id)sender {
    
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    shake.fromValue = [NSNumber numberWithFloat:-10];
    
    shake.toValue = [NSNumber numberWithFloat:+10];
    
    shake.duration = 1;
    
    shake.autoreverses = NO;
    shake.repeatCount = 0;
    
    [self.morningOutImgView.layer addAnimation:shake forKey:@"imageView"];
    

    [UIView animateWithDuration:2.0 delay:2.0 options:UIViewAnimationOptionCurveEaseIn animations:nil completion:nil];
    
    
    [UIView beginAnimations:@"go" context:nil];
    [UIView setAnimationDuration:1];
    
    CGPoint center = [_morningOutImgView center];
    
    center.x=self.view.frame.size.width/2;
    center.y=0;
    [_morningOutImgView setCenter:center];
    
    [UIView commitAnimations];
    
    _morningOutImgView.alpha=1;
    
    
    [UIView beginAnimations: @"Fade Out" context:nil];
    
    
    [UIView setAnimationDelay:0.2];
    
    
    [UIView setAnimationDuration:1];
    
    
    _morningOutImgView.alpha = 0.0;
    
    [UIView commitAnimations];
    _swip.enabled=NO;
}

@end
