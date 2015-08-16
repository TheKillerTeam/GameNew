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

typedef enum {
    
    GameStateNotInGame = 0,
    GameStateGameStart = 1,
    GameStateNightStart = 2,
    GameStateNightDiscussion = 3,
    GameStateNightVote = 4,
    GameStateDayStart = 5,
    GameStateDayDiscussion = 6,
    GameStateDayVote = 7,
    GameStateJudgementDiscussion = 8,
    GameStateJudgementVote = 9,
    GameStateGameOver = 10,
    
} GameState;

@class Match;

@protocol NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState;
- (void)matchStarted:(Match *)match;
- (void)updateChat:(NSString *)chat withPlayerId:(NSString *)playerId;
- (void)updateVoteFor:(int)voteFor fromVotedFor:(int)votedFor withPlayerId:(NSString *)playerId;

- (void)gameStateChanged:(GameState)gameState;

@end

@interface NetworkController : NSObject

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (assign) id <NetworkControllerDelegate> delegate;
@property (assign, readonly) NetworkState networkState;

@property (assign, readonly) GameState gameState;

+ (NetworkController *)sharedInstance;
- (void)authenticateLocalUser;
- (void)connect;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController;
- (void)sendUpdatePlayerImage:(UIImage *)image;
- (void)sendChat:(NSString *)chat withChatType:(ChatType)chatType;
- (void)sendVoteFor:(int)playerIndex;
- (void)setGameState:(GameState)gameState;


@end