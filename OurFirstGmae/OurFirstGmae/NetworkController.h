//
//  NetworkController.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef enum {
    
    NetworkStateNotAvailable = 0,
    NetworkStatePendingAuthentication = 1,
    NetworkStateAuthenticated = 2,
    NetworkStateConnectingToServer = 3,
    NetworkStateConnected = 4,
    NetworkStatePendingMatchStatus = 5,
    NetworkStateReceivedMatchStatus = 6,
    NetworkStatePendingMatch = 7,
    NetworkStatePendingMatchStart = 8,
    NetworkStateMatchActive = 9,
    
} NetworkState;


typedef enum {
    
    ChatToAll = 0,
    ChatToTeam = 1,
    
} ChatType;

@class Match;

@protocol NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState;
- (void)matchStarted:(Match *)match;
- (void)updateChat:(NSString *)chat withPlayerId:(NSString *)playerId;
- (void)updateVoteFor:(int)voteFor fromVotedFor:(int)votedFor withPlayerId:(NSString *)playerId;

@end

@interface NetworkController : NSObject

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (assign) id <NetworkControllerDelegate> delegate;
@property (assign, readonly) NetworkState networkState;

+ (NetworkController *)sharedInstance;
- (void)authenticateLocalUser;
- (void)connect;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController;
- (void)sendUpdatePlayerImage:(UIImage *)image;
- (void)sendChat:(NSString *)chat withChatType:(ChatType)chatType;
- (void)sendVoteFor:(int)playerIndex;


@end