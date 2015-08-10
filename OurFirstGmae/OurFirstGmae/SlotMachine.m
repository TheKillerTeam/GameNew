//
//  SlotMachine.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/6.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "SlotMachine.h"
#import "SlotMachineClass.h"

#import <UIKit/UIKit.h>
@interface SlotMachine ()
{
    SlotMachineClass *slotClass;
    UIImageView *iconImageView;
    UIImageView *container;
    UILabel *jobNameLb;
    
    
}
@property (strong,nonatomic)NSArray *slotIcon;
@property (strong,nonatomic)NSArray *iconText;
@property (weak,nonatomic)UIButton *startBtn;
@property (weak,nonatomic)NSString *jobName;
@end

@implementation SlotMachine

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    // Do any additional setup after loading the view.
    
    self.slotIcon = [NSArray arrayWithObjects:[UIImage imageNamed:@"Batman"],[UIImage imageNamed:@"Mario"],[UIImage imageNamed:@"Doraemon"],[UIImage imageNamed:@"Nobi Nobita"], nil];
    self.iconText =@[@"警察",@"殺手",@"平民",@"超人"];
    
    
    _presentView= [UIView new];
    [self.presentView setFrame:CGRectMake(0, 0 , self.view.frame.size.width/2, self.view.frame.size.height/2)];
    self.presentView.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.presentView.backgroundColor =[UIColor yellowColor];
    [self.view addSubview:_presentView];
    
    
    
    
    slotClass = [[SlotMachineClass alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height/5)];


    
    slotClass.delegate=self;
    slotClass.dataSource=self;
   
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
    
    
    _startBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.startBtn.backgroundColor=[UIColor blackColor];
    
    [self.startBtn setFrame:CGRectMake(0, slotClass.frame.size.height+jobNameLb.frame.size.height, _presentView.frame.size.width, _presentView.frame.size.height-(slotClass.frame.size.height+jobNameLb.frame.size.height))];
    [self.startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    
    [_presentView insertSubview:_startBtn aboveSubview:jobNameLb];

    
    
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    NSInteger iconArrayCount = _slotIcon.count;
    NSInteger slotIndex = arc4random()%iconArrayCount;
    iconImageView.image = [_slotIcon objectAtIndex:1];  // 改變結果
    _jobName=[_iconText objectAtIndex:1];
    slotClass.slotResult = [NSArray arrayWithObject:[NSNumber numberWithInteger:slotIndex]];
    
    [slotClass startSlide];
 
    
}


-(void)start{
    [self dismissViewControllerAnimated:YES completion:nil];

    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)slotMachineWillStart:(SlotMachineClass *)slotClass{
    _startBtn.enabled=NO;
}
-(void)slotMachineDidEnd:(SlotMachineClass *)slotClass{
    _startBtn.enabled=YES;
    jobNameLb.text =_jobName;
}
-(NSArray*)iconsForMachine:(SlotMachineClass *)slotClass{
    return _slotIcon;
}
-(NSInteger)numberOfslotsInMachine:(SlotMachineClass *)slotClass{
    return 4;
}



@end
