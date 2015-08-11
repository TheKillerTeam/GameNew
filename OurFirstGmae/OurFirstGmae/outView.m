//
//  outView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/10.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "outView.h"
#import "DrawTriangleView.h"

@interface outView ()
{
    NSTimer *delayTime1;
    NSTimer *delayTime2;
    DrawTriangleView *triangle;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *outOfplayerImgView;
@end

@implementation outView
static int i = 1000;
static int j = 1021;
static int k = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    delayTime1 =[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(addView) userInfo:nil repeats:YES];
//    _outOfplayerImgView.image = [UIImage imageNamed:@"player7.jpg"];
//    [self.view addSubview:_outOfplayerImgView];
    
    
}
- (void)addView{
                    
                    
                    if (i>1021) {
                        _outOfplayerImgView.image=[UIImage imageNamed:@"play6.jpg"];
                        [delayTime1 invalidate];
                        delayTime1 = nil;
                        delayTime2=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(removeView) userInfo:nil repeats:YES];
                        
                        
                        
                    }
                    else{
                        
                        triangle = [[DrawTriangleView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2)-k/2, k, k, 2*k)];
                        NSLog(@"view wide:%d",90+2*k);
                        [self.view addSubview:triangle];
                        k = k + 10;
                        triangle.tag=i;
                        i++;
                        
                    }
                    
                    
}
                
                
-(void)removeView{
                    
                    if(j>999){
                        UIView *view = [self.view viewWithTag:j];
                        [view removeFromSuperview];
                        j--;
                        
                    }
                    if(j==1000)
                    {
                        
                        [delayTime2 invalidate];
                        delayTime2 = nil;
                    }
                    
                    
                    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


    
- (BOOL)shouldAutorotate{
    return YES;
}





@end
