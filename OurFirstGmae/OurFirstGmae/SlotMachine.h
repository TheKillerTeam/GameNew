//
//  SlotMachine.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/6.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlotMachineClass.h"
@interface SlotMachine : UIViewController<SlotMachineClassDataSource,SlotMachineClassDelegate>
@property(nonatomic)UIView*presentView;
@end
