//
//  Match.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    MatchStateActive = 0,
    MatchStateGameOver
    
} MatchState;

@interface Match : NSObject

@property (nonatomic, assign) MatchState matchState;
@property (nonatomic, strong) NSArray *players;

- (id)initWithState:(MatchState)matchState players:(NSArray*)players;

@end