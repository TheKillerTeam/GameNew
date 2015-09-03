//
//  Player.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)initWithPlayerImageString:(NSString*)playerImageString
          playerHeadImageString:(NSString *)playerHeadImageString
                       playerId:(NSString *)playerId
                          alias:(NSString *)alias
                    playerState:(int)playerState
                     playerTeam:(int)playerTeam {
    
    if ((self = [super init])) {
        
        NSData *playerImageData = [[NSData alloc] initWithBase64EncodedString:playerImageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *playerImage = [UIImage imageWithData:playerImageData];
        
        NSData *playerHeadImageData = [[NSData alloc] initWithBase64EncodedString:playerHeadImageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *playerHeadImage = [UIImage imageWithData:playerHeadImageData];
        
        self.playerImage = playerImage;
        self.playerHeadImage = playerHeadImage;
        
        self.playerId = playerId;
        self.alias = alias;
        self.playerState = playerState;
        self.playerTeam = playerTeam;
    }
    return self;
}

- (void)dealloc {
    
    self.playerImage = nil;
    self.playerHeadImage = nil;
    self.playerId = nil;
    self.alias = nil;
}

@end