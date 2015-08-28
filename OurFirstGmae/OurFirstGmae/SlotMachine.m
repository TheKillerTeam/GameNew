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

@interface SlotMachine () {
    
    SlotMachineClass *slotClass;
    UIImageView *iconImageView;
    UIImageView *container;
    UILabel *jobNameLb;
    UIButton *startBtn;
    ViewController*vc;
    NSInteger slotIndex;
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
    
    self.iconText =@[PLAYER_TEAM_CIVILIAN_STRING,
                     PLAYER_TEAM_SHERIFF_STRING,
                     PLAYER_TEAM_MAFIA_STRING];
    
    _presentView= [UIView new];
    [self.presentView setFrame:CGRectMake(0, 0 , self.view.frame.size.width/2, self.view.frame.size.height/2)];
    self.presentView.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.presentView.backgroundColor =[UIColor yellowColor];
    [self.view addSubview:_presentView];

    slotClass = [[SlotMachineClass alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height/5)];
    
    slotClass.delegate=self;
    slotClass.dataSource=self;
    
    UIView *view =[[UIView alloc]initWithFrame:self.view.frame];
    view.backgroundColor=[UIColor blackColor];
    view.alpha=0.5;
    view.tag=2000;
    [self.view insertSubview:view belowSubview:_presentView];
    [_presentView addSubview:slotClass];
    
    ////解答圖
//////////////////////////////
    
//    container= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, slotClass.frame.size.width, slotClass.frame.size.height)];
//    container.center=CGPointMake(_presentView.frame.size.width/2, _presentView.frame.size.height/2+100);
//    container.backgroundColor=[UIColor redColor];
//    
//    [_presentView addSubview:container];
//    
//    
//    
//    iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, container.frame.size.width           , container.frame.size.height)];
//    [container addSubview:iconImageView];
    
//////////////////////////////
    
    jobNameLb = [[UILabel alloc]initWithFrame:CGRectMake(0, slotClass.frame.size.height,_presentView.frame.size.width, slotClass.frame.size.height-50)];

    jobNameLb.backgroundColor=[UIColor redColor];
    [jobNameLb setTextAlignment:NSTextAlignmentCenter];

    [_presentView addSubview:jobNameLb];
    
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
    
//    NSInteger iconArrayCount = _slotIcon.count;
//    slotIndex = arc4random()%iconArrayCount;
    iconImageView.image = [_slotIcon objectAtIndex:slotIndex];  // 改變結果
    _jobName=[_iconText objectAtIndex:slotIndex];
    slotClass.slotResult = [NSArray arrayWithObject:[NSNumber numberWithInteger:slotIndex]];
    
    [slotClass startSlide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)slotMachineWillStart:(SlotMachineClass *)slotClass{
    
    startBtn.enabled=NO;
}

-(void)slotMachineDidEnd:(SlotMachineClass *)slotClass{
    
    startBtn.enabled=YES;
    jobNameLb.text =_jobName;
}

-(NSArray*)iconsForMachine:(SlotMachineClass *)slotClass{
    
    return _slotIcon;
}

-(NSInteger)numberOfslotsInMachine:(SlotMachineClass *)slotClass{
    
    return self.iconText.count;
}
//
@end
