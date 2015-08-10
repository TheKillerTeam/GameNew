//
//  SlotMachineClass.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/6.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "SlotMachineClass.h"
#import <QuartzCore/QuartzCore.h>
static const NSUInteger minTurn =3;
static BOOL isSlide =NO;


@implementation SlotMachineClass
{
    NSMutableArray *scrollLayerArray; //圖層陣列
    CALayer *scrollLayer;
    NSArray *currentResults;
}
//
//@property(strong,nonatomic)UIImageView *backgroundImageView;//背景
//@property(strong,nonatomic)UIImageView *coverImageView;//遮罩
//@property(strong,nonatomic)UIView *contentView;// 底層圖
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        self.backgroundImageView =[[UIImageView alloc]initWithFrame:frame];
        self.backgroundImageView.contentMode=UIViewContentModeCenter;
        [self addSubview:_backgroundImageView];//背景
        
        self.contentView=[[UIView alloc]initWithFrame:frame];
        self.contentView.backgroundColor=[UIColor blueColor];
        [self addSubview:_contentView];//底層
        
        self.coverImageView =[[UIImageView alloc]initWithFrame:frame];
        self.coverImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_contentView];//遮罩
        
        scrollLayerArray = [NSMutableArray array];//圖層陣列
        self.singleUnitDuration = 0.8f;
        
    }
    return self;
    
}

-(void)setSlotResult:(NSArray *)slotResult{
    if(!isSlide){
        _slotResult=slotResult;
        if(!currentResults){
            NSMutableArray *currentResult = [NSMutableArray array];
            for(int i =0 ; i<[slotResult count] ;i++){
                 [currentResult addObject:[NSNumber numberWithUnsignedInteger:0]];
            }
            currentResults=[NSArray arrayWithArray:currentResult];
        }
    }
    
    
    
}

-(void)setDataSource:(id<SlotMachineClassDataSource>)dataSource{
    _dataSource = dataSource;
    [self reload];
    
}


-(void)reload{
    
    if(self.dataSource){
        for(CALayer *containerLayer  in _contentView.layer.sublayers){
            [containerLayer removeFromSuperlayer];
        }
    }
    scrollLayerArray=[NSMutableArray array];
   
    

        CALayer *containLayer =[CALayer new];
        containLayer.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
        containLayer.masksToBounds = YES;
    containLayer.backgroundColor=[UIColor clearColor].CGColor;
    
        
        
        scrollLayer = [CALayer new];
        scrollLayer.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
    scrollLayer.backgroundColor=[UIColor blueColor].CGColor;
        [containLayer addSublayer:scrollLayer];
        [_contentView.layer addSublayer:containLayer];
//        [scrollLayerArray addObject:scrollLayer];

    
    
//    CGFloat iconUnitHeight =_contentView.frame.size.height; //每個圖的高
     NSInteger numOfSlot = [self.dataSource numberOfslotsInMachine:self];
     NSArray *imageBox = [self.dataSource iconsForMachine:self];
     NSInteger imageNum = imageBox.count;
     NSInteger scrollIndex =-40*imageNum;
    for(int j = 0 ; j>scrollIndex ;j--){
        UIImage *iconImage = [imageBox objectAtIndex:abs(j)%numOfSlot];
        CALayer *iconLayer  = [CALayer new];
        NSInteger offset =j*scrollLayer.frame.size.height;
        iconLayer.frame=CGRectMake(0,offset, scrollLayer.frame.size.width, scrollLayer.frame.size.height);

        iconLayer.contents =(id)iconImage.CGImage;
//        iconLayer.contentsScale =iconImage.scale; //圖大小
        iconLayer.contentsGravity=kCAGravityCenter;
        [scrollLayer addSublayer:iconLayer];
        
    }
    
}



-(void)startSlide{
    if(isSlide)
    {
        return;
    }
    else
    {
        isSlide = YES;
        if([self.delegate respondsToSelector:@selector(slotMachineWillStart:)])
        {
            [self.delegate slotMachineWillStart:self];
        }
        
    }
    
    NSArray *slotIcon = [self.dataSource iconsForMachine:self];
    NSInteger iconNum =[slotIcon count];
  
       __block NSMutableArray *positionArray = [NSMutableArray array];
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [CATransaction setDisableActions:NO];
    [CATransaction setCompletionBlock:^{
        isSlide = NO;
        if ([self.delegate respondsToSelector:@selector(slotMachineDidEnd:)]){
            [self.delegate slotMachineDidEnd:self];
        }
     
        
//              NSLog(@"positionArray %@",positionArray.description);
        scrollLayer.position = CGPointMake(scrollLayer.position.x, ((NSNumber *)[positionArray objectAtIndex:0]).floatValue);
       
        NSMutableArray *toBeDeletedLayerArray = [NSMutableArray array];
        
        NSUInteger resultIndex = [[self.slotResult objectAtIndex:0] unsignedIntegerValue];
   
        
        NSUInteger currentIndex = [[currentResults objectAtIndex:0] unsignedIntegerValue];
        
        
        for (int j = 0; j < iconNum * minTurn + resultIndex - currentIndex; j++) {
         
            
            
            
            CALayer *iconLayer = [scrollLayer.sublayers objectAtIndex:j];
            
            
            [toBeDeletedLayerArray addObject:iconLayer];
            
        }
        
        
        for (CALayer *toBeDeletedLayer in toBeDeletedLayerArray) {

            CALayer *toBeAddedLayer = [CALayer layer];
            toBeAddedLayer.frame = toBeDeletedLayer.frame;
            toBeAddedLayer.contents = toBeDeletedLayer.contents;
            toBeAddedLayer.contentsScale = toBeDeletedLayer.contentsScale;
            toBeAddedLayer.contentsGravity = toBeDeletedLayer.contentsGravity;
            
            CGFloat shiftY = iconNum * toBeAddedLayer.frame.size.height * (minTurn+ 3);
            toBeAddedLayer.position = CGPointMake(toBeAddedLayer.position.x, toBeAddedLayer.position.y - shiftY);
            
            [toBeDeletedLayer removeFromSuperlayer];
            [scrollLayer addSublayer:toBeAddedLayer];
        }
        toBeDeletedLayerArray = [NSMutableArray array];
    
     
     currentResults = self.slotResult;
     positionArray = [NSMutableArray array];
     
     
     
     
     
    }];
    
    
    static NSString *const keyPath = @"position.y";
//    NSLog(@"_slotResult %@",_slotResult.description);

    for(int i= 0 ; i<_slotResult.count ; i++){
       
        NSUInteger resultIndex = [[_slotResult objectAtIndex:i]unsignedIntegerValue];
        NSUInteger currentIndex =[[currentResults objectAtIndex:i]unsignedIntegerValue];
        NSUInteger howManyUnit =  minTurn * iconNum + resultIndex - currentIndex;
        CGFloat slideY = howManyUnit * scrollLayer.frame.size.height;
        
        CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
        slideAnimation.fillMode = kCAFillModeForwards;//
        slideAnimation.duration = self.singleUnitDuration;//動畫時間
        slideAnimation.toValue = [NSNumber numberWithFloat:scrollLayer.position.y + slideY];
        //最後位移
        slideAnimation.removedOnCompletion = NO;
        
        [scrollLayer addAnimation:slideAnimation forKey:@"slideAnimation"];
        
        [positionArray addObject:slideAnimation.toValue];
  
    }
    
    [CATransaction commit];
}







@end
