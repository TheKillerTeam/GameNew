//
//  Match.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "Match.h"

@implementation Match

- (id)initWithState:(MatchState)matchState players:(NSArray*)players {
    
    if ((self = [super init])) {
        
        self.matchState = matchState;
        self.players = players;
    }
    return self;
}

- (void)dealloc {
    
    self.players = nil;
}

@end