//
//  outView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/10.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "outView.h"

#define DEAD_PLAYER_IMAGE @"cubeNightOut.png"

@interface outView () {

    NSTimer *delayTime1;
    NSTimer *delayTime2;
    CABasicAnimation* shake;
    UIView *addView;
    UIView *addView2;    
}

@property (weak, nonatomic) IBOutlet UIImageView *outOfplayerImgView;

@end

@implementation outView
static int i = 1000;
static int l = 1000;
static int j = 1011;
static int k = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _outOfplayerImgView.image = self.playerImage;
    
    UIView *view =[[UIView alloc]initWithFrame:self.view.frame];
    view.backgroundColor=[UIColor blackColor];
    view.alpha=0.5;
    [self.view insertSubview:view belowSubview:_outOfplayerImgView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(showLaser) withObject:nil afterDelay:1.0f];
}

- (void)showLaser {
    
    delayTime1 =[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addView) userInfo:nil repeats:YES];
}

- (void)addView{
    
    if (i>1011) {
        
        [delayTime1 invalidate];
        delayTime1 = nil;

         shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        
        //设置抖动幅度
        shake.fromValue = [NSNumber numberWithFloat:-20];
        
        shake.toValue = [NSNumber numberWithFloat:+20];
        
        shake.duration = 0.1;
        
        shake.autoreverses = YES; //是否重复
        
        shake.repeatCount = 6;
        shake.delegate =self;
        [shake setValue:@"shake" forKey:@"animationShake"];
         [addView.layer addAnimation:shake forKey:@"view"];
        [addView2.layer addAnimation:shake forKey:@"view"];
        
    }else {
        
        addView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, -k+10, self.view.frame.size.height)];
        addView2 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, k-10, self.view.frame.size.height)];
        addView.backgroundColor=[UIColor blackColor];
        addView2.backgroundColor=[UIColor blackColor];
        [self.view addSubview:addView2];
        [self.view addSubview:addView];
        
        k = k + 10;
        addView.tag=i;
        addView2.tag=l;
        i++;
        l++;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if([[anim valueForKey:@"animationShake"]isEqualToString:@"shake"]){
        
        if (flag) {
            
            _outOfplayerImgView.image=[UIImage imageNamed:DEAD_PLAYER_IMAGE];
            delayTime2=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(removeView) userInfo:nil repeats:YES];
        }
    }
}

-(void)removeView {
                    
    if(j>999 || l>999) {
        
        UIView *view = [self.view viewWithTag:j];
        [view removeFromSuperview];
        j--;
        UIView *view1 = [self.view viewWithTag:l];
        [view1 removeFromSuperview];
        l--;
    }
    
    if(j==1000) {
        
        [delayTime2 invalidate];
        delayTime2 = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

@end
