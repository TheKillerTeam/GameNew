//
//  GameOverViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/9/1.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "GameOverViewController.h"

@interface GameOverViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *winCubeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *winBackgroundView;

@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self backgroundViewAnimation:self.backgroundImage withWinnerImage:self.winnerImage];
    UIView *view =[[UIView alloc]initWithFrame:self.view.frame];
    view.backgroundColor=[UIColor blackColor];
    view.alpha = 0.5;
    [self.view insertSubview:view belowSubview:self.winBackgroundView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)backgroundViewAnimation:(UIImage*)background withWinnerImage:(UIImage*)winner{
    

    self.winBackgroundView.image = background;
    self.winCubeImageView.image = winner;
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotateAnimation.duration =1.0;
        rotateAnimation.repeatCount =HUGE_VALF;
        rotateAnimation.fillMode = kCAFillModeForwards;
        rotateAnimation.removedOnCompletion =NO;
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:2* M_PI ];
    [self.winBackgroundView.layer addAnimation:rotateAnimation forKey:@"rotate"];

    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    scaleAnimation.duration =2.0;
    scaleAnimation.repeatCount =1;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion =NO;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:3.0];
    
    
    [self.winBackgroundView.layer addAnimation:scaleAnimation forKey:@"scale"];
//    CAAnimationGroup *groupeAnimation = [CAAnimationGroup animation];
//    groupeAnimation.duration =2.0;
//    groupeAnimation.repeatCount =HUGE_VALF;
//    
//    groupeAnimation.animations = [NSArray arrayWithObjects:rotateAnimation,scaleAnimation, nil];
//    [self.winBackgroundView.layer addAnimation:groupeAnimation forKey:@"rotate-scale"];
    
    
    [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:5.0];
    
    
}

-(void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
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
