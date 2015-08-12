//
//  LoadingViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/10.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAGradientLayer.h>
#import "LoadingViewController.h"
#import "FBShimmeringView.h"

@interface LoadingViewController ()
{
    FBShimmeringView *shimmeringView;
}
@property (weak, nonatomic) IBOutlet UIImageView *loadingImg;
@property (weak, nonatomic) IBOutlet UILabel *loadingLb;

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
//    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 300)];
//    view.center=self.view.center;
//    view.backgroundColor=[UIColor blackColor];
//    view.alpha=0.5;
//    [self.view addSubview:view];
    // Do any additional setup after loading the view.
    shimmeringView.shimmeringOpacity=0.1;
    shimmeringView.shimmeringSpeed=1000;
    shimmeringView.shimmeringHighlightWidth=1.2;
    shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.view.bounds];

    [self.view addSubview:shimmeringView];


    _loadingLb.textColor = [UIColor colorWithRed:0.213 green:0.409 blue:1.000 alpha:1.000];
     _loadingLb.font = [UIFont fontWithName:@"Helvetica-Bold" size:40];
    _loadingLb.textAlignment = NSTextAlignmentCenter;
    _loadingLb.text = NSLocalizedString(@"Loading...", nil);
    shimmeringView.contentView = _loadingLb;
    
    
    
    // Start shimmering.
    shimmeringView.shimmering = YES;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
