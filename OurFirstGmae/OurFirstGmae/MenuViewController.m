//
//  MenuViewController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

//TODO: @結束遊戲 @結束後再重新開始 @斷線重聯 @邀請好友 @縮小App不會斷線 @追蹤是否有網路連線
//@編輯外觀時由之前的結果開始編輯 @編輯外觀新增返回按鈕 @外觀存檔

#import "MenuViewController.h"
#import "NetworkController.h"
#import "Match.h"
#import "Player.h"
#import "TestGameViewController.h"
#import "playerInfoViewController.h"
#import "ViewController.h"

#define PLAYER_IMAGE_DEFAULT @"news2.jpg"
#define MIN_PLAYER_COUNTS 2
#define MAX_PLAYER_COUNTS 16

@interface MenuViewController () <NetworkControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, playerInfoViewControllerDelegate> {
    
    Match *_match;
    int playerCounts;
    UIImage *playerImage;
}

@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UIPickerView *playerCountsPickerView;
@property (weak, nonatomic) IBOutlet UIImageView *playerImageImageView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    playerCounts = 2;
    
    //TODO:if theres a saved playerImage, load it instead of using default
    playerImage = [UIImage imageNamed:PLAYER_IMAGE_DEFAULT];
    self.playerImageImageView.image = playerImage;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(id)sender {
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game center login required" message:@"please login game center to continue" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
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

#pragma mark - NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState {
    
    switch(networkState) {
            
        case NetworkStateNotAvailable:
            
            self.debugLabel.text = @"Not Available";
            break;
            
        case NetworkStatePendingAuthentication:
            
            self.debugLabel.text = @"Pending Authentication";
            break;
            
        case NetworkStateAuthenticated:
            
            self.debugLabel.text = @"Authenticated";
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
