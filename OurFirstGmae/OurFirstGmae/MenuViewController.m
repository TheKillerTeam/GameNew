//
//  MenuViewController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

//TODO: @邀請好友 @縮小App不會斷線

#import "MenuViewController.h"
#import "NetworkController.h"
#import "Match.h"
#import "Player.h"
#import "playerInfoViewController.h"
#import "ViewController.h"

#define PLAYER_IMAGE_DEFAULT @"news2.jpg"
#define MIN_PLAYER_COUNTS 2
#define MAX_PLAYER_COUNTS 16

#define PLAYER_ALIAS_FONT_SIZE @20.0f

@interface MenuViewController () <NetworkControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, playerInfoViewControllerDelegate> {
    
    Match *_match;
    int playerCounts;
    UIImage *playerImage;
    NSString *playerAlias;
    
    UIAlertAction *secureTextAlertAction;
}

@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UIButton *playerAliasButton;
@property (weak, nonatomic) IBOutlet UIPickerView *playerCountsPickerView;
@property (weak, nonatomic) IBOutlet UIImageView *playerImageImageView;
@property (weak, nonatomic) IBOutlet UILabel *gameStateLabel;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //stop auto lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    playerCounts = 2;
    
    //TODO:if theres a saved playerImage, load it instead of using default
    playerImage = [UIImage imageNamed:PLAYER_IMAGE_DEFAULT];
    _playerImageImageView.backgroundColor=[UIColor clearColor];
    self.playerImageImageView.image = playerImage;
    
    playerAlias = @"玩家暱稱";
}

- (void)viewDidAppear:(BOOL)animated {
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
    [self gameStateChanged:[NetworkController sharedInstance].gameState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(id)sender {
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"請登入 Game Center" message:@"登入後方能開始遊戲" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootVC presentViewController:alert animated:YES completion:nil];
        
    }else if ([NetworkController sharedInstance].networkState == NetworkStateReceivedMatchStatus) {

        [[NetworkController sharedInstance] findMatchWithMinPlayers:playerCounts maxPlayers:playerCounts viewController:self];
    }
}

- (IBAction)editCharacterButtonPressed:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    playerInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"playerSetView"];
    
    vc.delegate = self;
    
    [self presentViewController:vc animated:true completion:nil];
}

- (IBAction)playerAliasButtonPressed:(id)sender {
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"請登入 Game Center" message:@"登入後方能更改暱稱" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootVC presentViewController:alert animated:YES completion:nil];
        
    }else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更改你的暱稱" message:@"請輸入你想讓其他玩家看見的的暱稱" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
            playerAlias = [alert.textFields[0] text];
            [self.playerAliasButton setTitle:playerAlias forState:UIControlStateNormal];
            [[NetworkController sharedInstance]sendUpdatePlayerAlias:playerAlias];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];

        [alert addAction:done];
        done.enabled = false;
        secureTextAlertAction = done;
        [alert addAction:cancel];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
            textField.placeholder = @"暱稱長度不能大於6個中文字長度";
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
            
            textField.returnKeyType = UIReturnKeyDone;
        }];
        UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {

    NSString *text = [notification.object text];
    
    NSNumber *n = PLAYER_ALIAS_FONT_SIZE;
    
    CGFloat fontSize = [n floatValue];
    CGRect r = [text boundingRectWithSize:CGSizeMake(10000, 0)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                  context:nil];

    if (text.length != 0 && r.size.width <= 120) {
        
        secureTextAlertAction.enabled = true;
        
    }else {
    
        secureTextAlertAction.enabled = false;
    }
    
    NSLog(@"%f", r.size.width);
}

#pragma mark - NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState {
    
    switch(networkState) {
            
        case NetworkStateNotAvailable:
            
            self.debugLabel.text = @"Not Available";
            
            [self.playerAliasButton setTitle:playerAlias forState:UIControlStateNormal];

            break;
            
        case NetworkStatePendingAuthentication:
            
            self.debugLabel.text = @"Pending Authentication";
            break;
            
        case NetworkStateAuthenticated:
            
            self.debugLabel.text = @"Authenticated";
            
            playerAlias = [GKLocalPlayer localPlayer].alias;
            [self.playerAliasButton setTitle:playerAlias forState:UIControlStateNormal];
            
            break;
            
        case NetworkStateConnectingToServer:
            
            self.debugLabel.text = @"Connecting to Server";
            break;
            
        case NetworkStateConnected:
            
            self.debugLabel.text = @"Connected";
            break;
            
        case NetworkStatePendingMatchStatus:
            
            self.debugLabel.text = @"Pending Match Status";
            break;
            
        case NetworkStateReceivedMatchStatus:
            
            self.debugLabel.text = @"Received Match Status,\nReady to Look for a Match";
            
            [[NetworkController sharedInstance]sendUpdatePlayerImage:playerImage];
            [[NetworkController sharedInstance]sendUpdatePlayerAlias:playerAlias];
            
            break;
            
        case NetworkStatePendingMatch:
            
            self.debugLabel.text = @"Pending Match";
            break;
            
        case NetworkStatePendingMatchStart:
            
            self.debugLabel.text = @"Pending Start";
            break;
            
        case NetworkStateMatchActive:
            
            self.debugLabel.text = @"Match Active";
            break;
    }
}

- (void)matchStarted:(Match *)match {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"mainView"];
    
    vc.match = match;
    
    vc.playerImage = playerImage;
    
    [self presentViewController:vc animated:true completion:nil];
}

- (void)updateChat:(NSString *)chat withPlayerId:(NSString *)playerId {
    
}

- (void)updateVoteFor:(int)voteFor fromVotedFor:(int)votedFor withPlayerId:(NSString *)playerId {
    
}

- (void)allowVote {
    
}

- (void)playerDied:(NSString *)playerId {
    
}

- (void)gameStateChanged:(GameState)gameState {
    
    switch(gameState) {
            
        case GameStateNotInGame:
            
            self.gameStateLabel.text = @"NotInGame";
            break;
            
        case GameStateGameStart:
            
            self.gameStateLabel.text = @"GameStart";
            break;
            
        case GameStateNightStart:
            
            self.gameStateLabel.text = @"NightStart";
            break;
            
        case GameStateNightDiscussion:
            
            self.gameStateLabel.text = @"NightDiscussion";
            break;
            
        case GameStateNightVote:
            
            self.gameStateLabel.text = @"NightVote";
            break;
            
        case GameStateShowNightResults:
            
            self.gameStateLabel.text = @"ShowNightResults";
            break;
            
        case GameStateDayStart:
            
            self.gameStateLabel.text = @"DayStart";
            break;
            
        case GameStateDayDiscussion:
            
            self.gameStateLabel.text = @"DayDiscussion";
            break;
            
        case GameStateDayVote:
            
            self.gameStateLabel.text = @"DayVote";
            break;
            
        case GameStateShowDayResults:
            
            self.gameStateLabel.text = @"ShowDayResults";
            break;
            
        case GameStateJudgementDiscussion:
            
            self.gameStateLabel.text = @"JudgementDiscussion";
            break;
            
        case GameStateJudgementVote:
            
            self.gameStateLabel.text = @"JudgementVote";
            break;
            
        case GameStateShowJudgementResults:
            
            self.gameStateLabel.text = @"ShowJudgementResults";
            break;
            
        case GameStateGameOver:
            
            self.gameStateLabel.text = @"GameOver";
            break;
    }
}

- (void)judgePlayer:(NSString *)playerId {
    
}

- (void)updateJudgeFor:(int)judgeFor fromJudgedFor:(int)judgedFor withPlayerId:(NSString *)playerId {
    
}

- (void)playerHasLastWords:(NSString *)lastWords withPlayerId:(NSString *)playerId {
    
}

- (void)gameOver:(int)whoWins {
    
    
}

#pragma mark - playerInfoViewControllerDelegate

- (void)transImage:(UIImage *)image {
    
    playerImage = image;
    
    self.playerImageImageView.image = playerImage;
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return MAX_PLAYER_COUNTS - MIN_PLAYER_COUNTS +1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [NSString stringWithFormat:@"%ld", MIN_PLAYER_COUNTS +row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    playerCounts = (int)(MIN_PLAYER_COUNTS +row);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
