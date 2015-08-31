//
//  MenuViewController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

//TODO: @邀請好友

#import "MenuViewController.h"
#import "NetworkController.h"
#import "Match.h"
#import "Player.h"
#import "playerInfoViewController.h"
#import "ViewController.h"

#define PLAYER_IMAGE_DEFAULT @"NPCPlayer.png"

#define MIN_PLAYER_COUNTS 2
#define MAX_PLAYER_COUNTS 16

#define PLAYER_ALIAS_FONT_SIZE 18.0f
#define PLAYER_ALIAS_MAXIMUM_COUNT 6

@interface MenuViewController () <NetworkControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, playerInfoViewControllerDelegate> {
    
    Match *_match;
    int playerCounts;
    UIImage *playerImage;
    NSString *playerAlias;
    
    UIAlertAction *secureTextAlertAction;
    
    UIImageView *gameNameImageView;
}

@property (weak, nonatomic) IBOutlet UIButton *networkStateButton;
//@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UIButton *playerAliasButton;
@property (weak, nonatomic) IBOutlet UIPickerView *playerCountsPickerView;
@property (weak, nonatomic) IBOutlet UIImageView *playerImageImageView;

@property (weak, nonatomic) IBOutlet UIImageView *superManImageView;
@property (weak, nonatomic) IBOutlet UIImageView *redBtnImageView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *outfitBtn;
@property (weak, nonatomic) IBOutlet UIButton *soldierBtn;
@property (weak, nonatomic) IBOutlet UIImageView *closetBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playerInfoBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //stop auto lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    playerCounts = MIN_PLAYER_COUNTS;
    
    //TODO:if theres a saved playerImage, load it instead of using default
    playerImage = [UIImage imageNamed:PLAYER_IMAGE_DEFAULT];
    _playerImageImageView.backgroundColor=[UIColor clearColor];
    self.playerImageImageView.image = playerImage;
    
    playerAlias = @"玩家暱稱";
    
    [self forSuperManAnimation];
    
    gameNameImageView = [UIImageView new];
    gameNameImageView.image=[UIImage imageNamed:@"gameName.png"];
    [self.view addSubview:gameNameImageView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
    [self gameStateChanged:[NetworkController sharedInstance].gameState];
}

- (void)forSuperManAnimation{
    
    CGPoint targetPoint = CGPointMake(300, 260);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 260);
    CGPathAddLineToPoint(path, NULL, 0, 260);
    CGPathAddLineToPoint(path, NULL, 100, 250);
    CGPathAddLineToPoint(path, NULL, 150, 260);
    CGPathAddLineToPoint(path, NULL, 200, 250);
    CGPathAddLineToPoint(path, NULL, 250, 260);
    CGPathAddLineToPoint(path, NULL, 300, 255);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setValue:@"moving" forKey:@"animationMoving"];
    [animation setDuration:3];
    [animation setPath:path];
    animation.delegate=self;
    [animation setAutoreverses:NO];
    
    animation.fillMode = kCAFillModeForwards;
    [self.superManImageView.layer addAnimation:animation forKey:nil];
    [self.superManImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.superManImageView.center = targetPoint;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    if([[anim valueForKey:@"animationMoving"]isEqualToString:@"moving"]){
        
        if(flag){
            
            self.superManImageView.image =[UIImage imageNamed:@"superMan2.png"];
            self.redBtnImageView.image=[UIImage imageNamed:@"superManButton1.png"];
            
            self.playBtn.hidden = NO;
            self.outfitBtn.hidden = NO;
            self.soldierBtn.hidden = NO;
            self.playerCountsPickerView.hidden = NO;
            self.playerAliasButton.hidden = NO;
            
            [self forGameNameAnimation];
            [self forBtnAnimation];
        }
    }
    if ([[anim valueForKey:@"animationMoving2"]isEqualToString:@"moving2"]){
     
        if(flag){
            //登入gamecenter
            [[NetworkController sharedInstance] authenticateLocalUser];
        }
    }
}

- (void)forBtnAnimation{
    
    [UIView beginAnimations: @"Fade Out" context:nil];
    
    [UIView setAnimationDelay:1];
    
    [UIView setAnimationDuration:2];
    
    self.playBtn.alpha = 1.0;
    self.outfitBtn.alpha = 1.0;
    self.soldierBtn.alpha = 1.0;
    self.playerCountsPickerView.alpha = 1.0;
    self.playerInfoBackgroundImageView.alpha = 1.0;
    self.closetBackgroundImageView.alpha = 1.0;
    self.playerImageImageView.alpha = 1.0;
    self.playerAliasButton.alpha = 1.0;
    self.networkStateButton.alpha = 1.0;
    
    [UIView commitAnimations];
}

- (void)forGameNameAnimation{
    
    CGRect targetFrame = CGRectMake(43, 0, 290, 250);
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, NULL, self.view.frame.size.width/2, -300);
    CGPathAddLineToPoint(path1, NULL, self.view.frame.size.width/2, targetFrame.size.height/2 +10);
    CGPathAddLineToPoint(path1, NULL, self.view.frame.size.width/2, targetFrame.size.height/2);
    
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    [animation1 setValue:@"moving2" forKey:@"animationMoving2"];
    [animation1 setDuration:3];
    [animation1 setPath:path1];
    
    animation1.fillMode = kCAFillModeForwards;
    animation1.delegate=self;
    [gameNameImageView.layer addAnimation:animation1 forKey:nil];
    [gameNameImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    gameNameImageView.frame = targetFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(id)sender {
    
    [[NetworkController sharedInstance] findMatchWithMinPlayers:playerCounts maxPlayers:playerCounts viewController:self];
}

- (IBAction)editCharacterButtonPressed:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    playerInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"playerSetView"];
    
    vc.delegate = self;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
    [self presentViewController:vc animated:true completion:nil];
}

- (IBAction)playerAliasButtonPressed:(id)sender {
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"請登入Game Center" message:@"登入後方能更改暱稱" preferredStyle:UIAlertControllerStyleAlert];
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
            
            textField.placeholder = [NSString stringWithFormat:@"暱稱長度不能大於%d個中文字長度", PLAYER_ALIAS_MAXIMUM_COUNT];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
            
            textField.returnKeyType = UIReturnKeyDone;
        }];
        UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {

    NSString *text = [notification.object text];
    
    NSNumber *n = [NSNumber numberWithFloat:PLAYER_ALIAS_FONT_SIZE];
    
    CGFloat fontSize = [n floatValue];
    CGRect r = [text boundingRectWithSize:CGSizeMake(10000, 0)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                  context:nil];

    if (text.length != 0 && r.size.width <= PLAYER_ALIAS_FONT_SIZE*PLAYER_ALIAS_MAXIMUM_COUNT) {
        
        secureTextAlertAction.enabled = true;
        
    }else {
    
        secureTextAlertAction.enabled = false;
    }
    
    NSLog(@"%f", r.size.width);
}

#pragma mark - NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState {
    
    if (networkState == NetworkStateReceivedMatchStatus) {
        
        self.playBtn.enabled = true;
        
    }else {
        
        self.playBtn.enabled = false;
    }
    
    if (networkState == NetworkStateNotAvailable ||
        networkState == NetworkStateReceivedMatchStatus) {
        
        self.activityIndicatorView.hidden = true;
        
    }else {
        
        self.activityIndicatorView.hidden = false;
    }
    
    switch(networkState) {
            
        case NetworkStateNotAvailable:
            
//            self.debugLabel.text = @"Not Available";
            [self.networkStateButton setTitle:@"未登入Game Center" forState:UIControlStateNormal];
            
            [self.playerAliasButton setTitle:playerAlias forState:UIControlStateNormal];

            break;
            
        case NetworkStatePendingAuthentication:
            
//            self.debugLabel.text = @"Pending Authentication";
            [self.networkStateButton setTitle:@"登入Game Center中" forState:UIControlStateNormal];

            break;
            
        case NetworkStateAuthenticated:
            
//            self.debugLabel.text = @"Authenticated";
            [self.networkStateButton setTitle:@"已登入Game Center" forState:UIControlStateNormal];

            
            playerAlias = [GKLocalPlayer localPlayer].alias;
            [self.playerAliasButton setTitle:playerAlias forState:UIControlStateNormal];
            
            break;
            
        case NetworkStateConnectingToServer:
            
//            self.debugLabel.text = @"Connecting to Server";
            [self.networkStateButton setTitle:@"與伺服器連線中" forState:UIControlStateNormal];

            break;
            
        case NetworkStateConnected:
            
//            self.debugLabel.text = @"Connected";
            [self.networkStateButton setTitle:@"已與伺服器連線" forState:UIControlStateNormal];

            break;
            
        case NetworkStatePendingMatchStatus:
            
//            self.debugLabel.text = @"Pending Match Status";
            [self.networkStateButton setTitle:@"準備遊戲資訊中" forState:UIControlStateNormal];

            break;
            
        case NetworkStateReceivedMatchStatus:
            
//            self.debugLabel.text = @"Received Match Status,\nReady to Look for a Match";
            [self.networkStateButton setTitle:@"準備完成,請開始遊戲" forState:UIControlStateNormal];
            
            [[NetworkController sharedInstance]sendUpdatePlayerImage:playerImage];
            [[NetworkController sharedInstance]sendUpdatePlayerAlias:playerAlias];
            
            break;
            
        case NetworkStatePendingMatch:
            
//            self.debugLabel.text = @"Pending Match";
            [self.networkStateButton setTitle:@"準備開始遊戲" forState:UIControlStateNormal];
            break;
            
        case NetworkStatePendingMatchStart:
            
//            self.debugLabel.text = @"Pending Start";
            [self.networkStateButton setTitle:@"準備開始遊戲" forState:UIControlStateNormal];
            break;
            
        case NetworkStateMatchActive:
            
//            self.debugLabel.text = @"Match Active";
            [self.networkStateButton setTitle:@"遊戲已開始" forState:UIControlStateNormal];
            break;
    }
}

- (void)matchStarted:(Match *)match {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"mainView"];
    
    vc.match = match;
    vc.playerImage = playerImage;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
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
    
}

- (void)judgePlayer:(NSString *)playerId {
    
}

- (void)updateJudgeFor:(int)judgeFor fromJudgedFor:(int)judgedFor withPlayerId:(NSString *)playerId {
    
}

- (void)playerHasLastWords:(NSString *)lastWords withPlayerId:(NSString *)playerId {
    
}

- (void)playerDisconnected:(NSString *)playerId willShutDown:(int)willShutDown {
    
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    playerCounts = (int)(MIN_PLAYER_COUNTS +row);
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%ld", MIN_PLAYER_COUNTS +row];
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]}];
    
    return attString;
    
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
