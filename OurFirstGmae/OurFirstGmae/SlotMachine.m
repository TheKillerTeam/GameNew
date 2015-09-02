//
//  SlotMachine.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/6.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "SlotMachine.h"
#import "SlotMachineClass.h"
#import "ViewController.h"
#import <UIKit/UIKit.h>

#define PLAYER_TEAM_CIVILIAN_STRING @"平民"
#define PLAYER_TEAM_SHERIFF_STRING  @"警察"
#define PLAYER_TEAM_MAFIA_STRING    @"殺手"

#define PLAYER_TEAM_CIVILIAN_IMAGE  @"cubeCivilian.png"
#define PLAYER_TEAM_SHERIFF_IMAGE   @"cubeSheriff.png"
#define PLAYER_TEAM_MAFIA_IMAGE     @"cubeMafia.png"

#define PLAYER_TEAM_PEACE @"soltJobPeace.png"
#define PLAYER_TEAM_RUIN @"soltJobRuin.png"
#define PLAYER_TEAM_DISCOVER @"soltJobDiscover.png"

@interface SlotMachine () {
    
    SlotMachineClass *slotClass;
    ViewController*vc;
    UIImageView *iconImageView;
    NSInteger slotIndex;
    UIImageView *jobImageView;
//    UIButton *startBtn;
}
@property (strong,nonatomic)NSArray *slotIcon;
@property (strong,nonatomic)NSArray *iconText;
@property (weak,nonatomic)NSString *jobName;

@end

@implementation SlotMachine

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.slotIcon = [NSArray arrayWithObjects:
                     [UIImage imageNamed:PLAYER_TEAM_CIVILIAN_IMAGE],
                     [UIImage imageNamed:PLAYER_TEAM_SHERIFF_IMAGE],
                     [UIImage imageNamed:PLAYER_TEAM_MAFIA_IMAGE], nil];
    
    self.iconText =@[[UIImage imageNamed:PLAYER_TEAM_PEACE],
                     [UIImage imageNamed:PLAYER_TEAM_DISCOVER],
                     [UIImage imageNamed:PLAYER_TEAM_RUIN]];
    
    _presentView= [UIView new];
    [self.presentView setFrame:CGRectMake(0, 0 , 220, 200)];
    self.presentView.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.presentView.backgroundColor =[UIColor clearColor];
    [self.view addSubview:_presentView];

    slotClass = [[SlotMachineClass alloc]initWithFrame:CGRectMake(0, 0, self.presentView.frame.size.width, self.presentView.frame.size.width-70)];
    slotClass.backgroundImageView.image = [UIImage imageNamed:@"slotBackground.png"];

    slotClass.coverImageView.image =[UIImage imageNamed:@"slotCover.png"];
    
    slotClass.delegate=self;
    slotClass.dataSource=self;
    
    UIView *view =[[UIView alloc]initWithFrame:self.view.frame];
    view.backgroundColor=[UIColor blackColor];
    view.alpha=0.5;
    view.tag=2000;
    [self.view insertSubview:view belowSubview:_presentView];
    [_presentView addSubview:slotClass];
    
    
    jobImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, slotClass.frame.size.height,self.presentView.frame.size.width, self.presentView.frame.size.height-slotClass.frame.size.height)];
    
    jobImageView.contentMode = UIViewContentModeScaleToFill;
    

    [self.presentView addSubview:jobImageView];
    

    /*
    startBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    
    [startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    startBtn.backgroundColor=[UIColor blackColor];
    
    [startBtn setFrame:CGRectMake(0, slotClass.frame.size.height+jobNameLb.frame.size.height, _presentView.frame.size.width, _presentView.frame.size.height-(slotClass.frame.size.height+jobNameLb.frame.size.height))];
    [startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    
    [_presentView addSubview:startBtn];
    */
}

- (void)setOutputIndex:(NSInteger)outputIndex {
    
    slotIndex = outputIndex;
}

-(void)viewDidAppear:(BOOL)animated{
    

    iconImageView.image = [_slotIcon objectAtIndex:slotIndex];  // 改變結果
    slotClass.slotResult = [NSArray arrayWithObject:[NSNumber numberWithInteger:slotIndex]];
    
    [slotClass startSlide];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)slotMachineWillStart:(SlotMachineClass *)slotClass{
    
//    startBtn.enabled=NO;
}

-(void)slotMachineDidEnd:(SlotMachineClass *)slotClass{
   
//    startBtn.enabled=YES;

    jobImageView.image =[self.iconText objectAtIndex:slotIndex];
}

-(NSArray*)iconsForMachine:(SlotMachineClass *)slotClass{
    
    return _slotIcon;
}

-(NSInteger)numberOfslotsInMachine:(SlotMachineClass *)slotClass{
    
    return self.iconText.count;
}
//

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

@end
