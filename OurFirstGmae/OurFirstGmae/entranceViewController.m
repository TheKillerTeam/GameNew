//
//  entranceViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/24.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "entranceViewController.h"

@interface entranceViewController (){
    UIImageView *gameName;
    
}
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *outfitBtn;
@property (weak, nonatomic) IBOutlet UIButton *soldierBtn;
@property (weak, nonatomic) IBOutlet UIImageView *closetBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playerInfoBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gameNameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *superManImageView;

@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UIImageView *redBtnImageView;
@property (weak, nonatomic) IBOutlet UIImageView *receiveeImageView;


@end

@implementation entranceViewController
-(void)viewDidAppear:(BOOL)animated{

}
- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self forSuperManAnimation];
    
    gameName = [UIImageView new];
    gameName.image=[UIImage imageNamed:@"gameName.png"];
    [self.view addSubview:gameName];
    CGPoint startFrame=CGPointMake(0, -260);
    self.gameNameImageView.center=startFrame;
    
    
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if([[anim valueForKey:@"animationMoving"]isEqualToString:@"moving"]){
        if(flag){
            self.superManImageView.image =[UIImage imageNamed:@"superMan2.png"];
            self.redBtnImageView.image=[UIImage imageNamed:@"superManButton1.png"];
            
            self.playBtn.hidden=NO;
            self.outfitBtn.hidden=NO;
            self.pickView.hidden=NO;
            self.soldierBtn.hidden = NO;
            
            
            
                [self forGameNameAnimation];
                [self forBtnAnimation];
        }
    }
    
    
}
-(void)forSuperManAnimation{
       CGPoint targetPoint = CGPointMake(300, 260);
    
    CGMutablePathRef path =CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 260);
    CGPathAddLineToPoint(path, NULL, 0, 260);
    CGPathAddLineToPoint(path, NULL, 100, 250);
    CGPathAddLineToPoint(path, NULL, 150, 260);
    CGPathAddLineToPoint(path, NULL, 200, 250);
    CGPathAddLineToPoint(path, NULL, 250, 260);
    CGPathAddLineToPoint(path, NULL, 300, 255);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setValue:@"moving" forKey:@"animationMoving"];
    [animation setDuration:5];
    [animation setPath:path];
    animation.delegate=self;
    [animation setAutoreverses:NO];
    
    
    animation.fillMode = kCAFillModeForwards;
    [self.superManImageView.layer addAnimation:animation forKey:nil];
    [self.superManImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.superManImageView.center=targetPoint;
    
   
    
    
}
-(void)forGameNameAnimation{
    
    
    CGRect targetFrame =CGRectMake(43, 0, 290, 250);
    
    CGMutablePathRef path1 =CGPathCreateMutable();
    CGPathMoveToPoint(path1, NULL, self.view.frame.size.width/2, -130);
    CGPathAddLineToPoint(path1, NULL, self.view.frame.size.width/2, 150);
    CGPathAddLineToPoint(path1, NULL, self.view.frame.size.width/2, targetFrame.size.height/2);
    
    
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  
    [animation1 setValue:@"moving2" forKey:@"animationMoving2"];
    [animation1 setDuration:5];
    [animation1 setPath:path1];

    
    animation1.fillMode = kCAFillModeForwards;
    [gameName.layer addAnimation:animation1 forKey:nil];
    [gameName setTranslatesAutoresizingMaskIntoConstraints:YES];

    gameName.frame=targetFrame;
    
}
-(void)forBtnAnimation{
    

    
    [UIView beginAnimations: @"Fade Out" context:nil];
    
    
    [UIView setAnimationDelay:0.2];
    
    
    [UIView setAnimationDuration:1];
    
    
    self.playBtn.alpha = 1.0;
    self.outfitBtn.alpha = 1.0;
    self.soldierBtn.alpha = 1.0;
    self.pickView.alpha = 1.0;
    self.playerInfoBackgroundImageView.alpha = 1.0;
    self.closetBackgroundImageView.alpha = 1.0;
    self.receiveeImageView.alpha = 1.0;
    
    [UIView commitAnimations];
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
- (IBAction)startBtnPressed:(id)sender {
}
- (IBAction)outfitBtnPressed:(id)sender {
}

@end
