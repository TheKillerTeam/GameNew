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
    ChatToDead = 2,
    
} ChatType;

typedef enum {
    
    GameStateNotInGame = 0,
    GameStateGameStart = 1,
    GameStateNightStart = 2,
    GameStateNightDiscussion = 3,
    GameStateNightVote = 4,
    GameStateShowNightResults = 5,
    GameStateDayStart = 6,
    GameStateDayDiscussion = 7,
    GameStateDayVote = 8,
    GameStateShowDayResults = 9,
    GameStateJudgementDiscussion = 10,
    GameStateJudgementVote = 11,
    GameStateShowJudgementResults = 12,
    GameStateGameOver = 13,
    
} GameState;

@class Match;

@protocol NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState;
- (void)matchStarted:(Match *)match;
- (void)updateChat:(NSString *)chat withPlayerId:(NSString *)playerId;
- (void)updateVoteFor:(int)voteFor fromVotedFor:(int)votedFor withPlayerId:(NSString *)playerId;
- (void)updateJudgeFor:(int)judgeFor fromJudgedFor:(int)judgedFor withPlayerId:(NSString *)playerId;
- (void)allowVote;
- (void)playerDied:(NSString *)playerId;
- (void)judgePlayer:(NSString *)playerId;
- (void)playerHasLastWords:(NSString *)lastWords withPlayerId:(NSString *)playerId;
- (void)playerDisconnected:(NSString *)playerId willShutDown:(int)willShutDown;
- (void)gameOver:(int)whoWins;

- (void)gameStateChanged:(GameState)gameState;

@end

@interface NetworkController : NSObject

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (assign) id <NetworkControllerDelegate> delegate;
@property (assign, readonly) NetworkState networkState;

@property (assign, readonly) GameState gameState;

@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;

+ (NetworkController *)sharedInstance;
- (void)authenticateLocalUser;
- (void)connect;
- (void)reconnect;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController;
- (void)sendUpdatePlayerImage:(UIImage *)playerImage withPlayerHeadImage:(UIImage *)playerHeadImage;
- (void)sendUpdatePlayerAlias:(NSString *)playerAlias;
- (void)sendChat:(NSString *)chat withChatType:(ChatType)chatType;
- (void)sendVoteFor:(int)playerIndex;
- (void)sendJudgeFor:(int)judge;
- (void)setGameState:(GameState)gameState;
- (void)sendStartDiscussion;
- (void)sendResetVote;
- (void)sendNightConfirmVote;
- (void)sendDayConfirmVote;
- (void)sendJudgementConfirmVote;
- (void)sendLastWords:(NSString *)lastWords;

@end