//
//  Player.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic, strong) UIImage *playerImage;
@property (nonatomic, strong) NSString *playerId;
@property (nonatomic, strong) NSString *alias;
@property (nonatomic, assign) int playerState;
@property (nonatomic, assign) int playerTeam;

- (id)initWithPlayerImageString:(NSString*)playerImageString playerId:(NSString*)playerId alias:(NSString*)alias playerState:(int)playerState playerTeam:(int)playerTeam;

@end