//
//  SlotMachineClass.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/6.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SlotMachineClass;
@protocol SlotMachineClassDelegate <NSObject>
-(void)slotMachineWillStart:(SlotMachineClass*)slotClass;
-(void)slotMachineDidEnd:(SlotMachineClass *)slotClass;

@end

@protocol SlotMachineClassDataSource<NSObject>

-(NSInteger)numberOfslotsInMachine:(SlotMachineClass*)slotClass;
-(NSArray*)iconsForMachine:(SlotMachineClass*)slotClass;

@end



@interface SlotMachineClass : UIView

@property(weak,nonatomic)id<SlotMachineClassDelegate>delegate;
@property(weak,nonatomic)id<SlotMachineClassDataSource>dataSource;
@property(strong,nonatomic)UIImageView *backgroundImageView;//背景
@property(strong,nonatomic)UIImageView *coverImageView;//遮罩
@property(strong,nonatomic)UIView *contentView;// 底層圖
@property(strong,nonatomic)NSArray *slotResult;//得到的亂數值
@property(nonatomic)CGFloat singleUnitDuration;

-(void)startSlide;

@end
