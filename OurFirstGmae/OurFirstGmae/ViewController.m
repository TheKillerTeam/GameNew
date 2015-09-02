//
//  ViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/17.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "playerCell.h"
#import "ChatCell.h"
#import "circleView.h"
#import "playerInfoViewController.h"
#import "cropView.h"
#import "NetworkController.h"
#import "Match.h"
#import "Player.h"

#import "SlotMachine.h"
#import "TransitionDelegate.h"
#import "LoadingViewController.h"
#import "outView.h"
#import "MorningOutViewController.h"

#define INPUT_BAR_HEIGHT 60
#define SYSTEM_ID @"系統"
#define SYSTEM_IMAGE @"mainCoverDefault.png"

#define PLAYER_TEAM_CIVILIAN_IMAGE  @"cubeCivilian.png"
#define PLAYER_TEAM_SHERIFF_IMAGE   @"cubeSheriff.png"
#define PLAYER_TEAM_MAFIA_IMAGE     @"cubeMafia.png"

#define PLAYER_DAYOUT_IMAGE     @"cubeDayOut.png"
#define PLAYER_NIGHTOUT_IMAGE     @"cubeNightOut.png"

#define BACKGROUND_IMAGE_DAY @"morningBackground.png"
#define BACKGROUND_IMAGE_NIGHT @"nightBackground.png"

#define PLAYER_TEAM_CIVILIAN    0
#define PLAYER_TEAM_SHERIFF     1
#define PLAYER_TEAM_MAFIA       2

#define PLAYER_TEAM_CIVILIAN_STRING @"捍衛者"
#define PLAYER_TEAM_SHERIFF_STRING  @"探索家"
#define PLAYER_TEAM_MAFIA_STRING    @"入侵者"

#define PLAYER_TEAM_CIVILIAN_CUBE_STRING @"和平魔方"
#define PLAYER_TEAM_SHERIFF_CUBE_STRING  @"探索魔方"
#define PLAYER_TEAM_MAFIA_CUBE_STRING    @"破壞魔方"

#define PLAYER_TEAM_PEACE_IMAGE  @"mainCoverPeace.png"
#define PLAYER_TEAM_EYES_IMAGE   @"mainCoverEyes.png"
#define PLAYER_TEAM_FIRE_IMAGE     @"mainCoverFire.png"
#define PLAYER_TEAM_HEART_IMAGE @"mainCoverHeart.png"

#define PLAYER_STATE_ALIVE  0
#define PLAYER_STATE_DEAD   1

#define VOTE_MINIMUM_TIME_INTERVAL 0.5f

#define LAST_WORDS_EMPTY @"LAST_WORDS_EMPTY"

#define JUDGE_GUILTY     0
#define JUDGE_INNOCENT   1

#define NOT_OVER_YET    0
#define MAFIA_WIN       1
#define CIVILIAN_WIN    2

#define NOT_SHUTTING_DOWN   0
#define SHUTTING_DOWN       1

#define CHAT_TO_ALL_IMAGE     @"mainConditionAll.png"
#define CHAT_TO_TEAM_IMAGE    @"mainConditionTeam.png"
#define CHAT_TO_DEAD_IMAGE    @"mainConditionOut.png"
#define CHAT_TO_NON_IMAGE     @"mainConditionNon.png"

#define PLAYER_TEAM_INSTRUCTION_PEACE @"instructionOfPeace.png"
#define PLAYER_TEAM_INSTRUCTION_DISCOVER @"instructionOfDiscover.png"
#define PLAYER_TEAM_INSTRUCTION_HEART @"instructionOfHeart.png"
#define PLAYER_TEAM_INSTRUCTION_RUIN @"instructionOfRuin.png"

@interface ViewController () <NetworkControllerDelegate, UITableViewDelegate, UITableViewDataSource,NSStreamDelegate, UITextFieldDelegate, MorningOutViewControllerDelegate> {
    
    UIView *inputBar;
    UIImageView *inputBarBackground;
    CGRect originframeChatBox;
    struct CGColor *oringincolorChatBox;
    
    NSMutableArray *playerDragImageViewArray;
    
    NSMutableArray *chatData;
    NSMutableArray *voteData;

    int selfVoteFor;
    int selfJudgeFor;
    int selfTeam;
    int selfState;
    BOOL selfShouldUpdateVote;
    BOOL selfShouldSendVote;
    BOOL selfShouldVote;
    BOOL selfShouldSeeVote;
    
    SlotMachine *SlotVc ;
    LoadingViewController *loadingView;
    MorningOutViewController* morningOutView;
    outView *nightOutView;
    UIViewController *rootVC;
    
    ChatType selfChatType;
    NSMutableArray *nightResults;
    NSMutableArray *nightResultsForAll;
    
    NSMutableArray *dayResults;
    
    NSMutableArray *judgementResults;
    
    NSDate *lastVoteTime;
    float interval;
    
    BOOL waitForLastWords;
    BOOL noOneToJudge;
    int dayCount;
    
    NSString *judgePlayerId;
    
    int gameOverResult;
}

@property (weak, nonatomic) IBOutlet UIImageView *instructionImageView;
@property (weak, nonatomic) IBOutlet UIButton *playerStateBtn;
@property (weak, nonatomic) IBOutlet UIButton *playerAliasBtn;
@property (weak, nonatomic) IBOutlet UIButton *gameStateBtn;
@property (weak, nonatomic) IBOutlet UIButton *dayCountBtn;
@property (weak, nonatomic) IBOutlet UIImageView *playerTeamBtn;
@property (weak, nonatomic) IBOutlet UITableView *chatBoxTableView;
@property (weak, nonatomic) IBOutlet UITableView *playerListTableView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatConditionButton;
@property (weak, nonatomic) IBOutlet UIView *thePlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (nonatomic, strong) TransitionDelegate *transitionController;
@property (weak, nonatomic) IBOutlet UIButton *confirmVoteButton;
@property (weak, nonatomic) IBOutlet UIView *judgementVoteView;
@property (weak, nonatomic) IBOutlet UILabel *guityCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *innocentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *guiltyButton;
@property (weak, nonatomic) IBOutlet UIButton *innocentButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //stop auto lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    ////////chatBoxTableView
    chatData = [NSMutableArray new];
    
    self.chatBoxTableView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
    UIImageView *viewBackground =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    viewBackground.image =[UIImage imageNamed:@"viewBackground.png"];
    [self.view insertSubview:viewBackground atIndex:0];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
   
    inputBar = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY([UIScreen mainScreen].bounds)-INPUT_BAR_HEIGHT, CGRectGetWidth([UIScreen mainScreen].bounds),INPUT_BAR_HEIGHT)];
    inputBarBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, inputBar.frame.size.width, inputBar.frame.size.height)];
    inputBarBackground.image =[UIImage imageNamed:@"mainInputbarBackground.png"];
  
    [inputBar addSubview:inputBarBackground];
    [inputBar addSubview:self.chatTextField];
    [inputBar addSubview:self.sendBtn];
    [inputBar addSubview:self.chatConditionButton];
    [self.view addSubview:inputBar];
    
    selfChatType = ChatToAll;
    self.chatTextField.enabled = false;
    [self changeChatConditionButtonImage:CHAT_TO_NON_IMAGE];
    //////
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listBackgroundBorder.png"]];
    [tempImageView setFrame:self.playerListTableView.frame];
    
    self.playerListTableView.backgroundView = tempImageView;
    tempImageView = nil;
    
    self.playerListTableView.delegate=self;
    self.playerListTableView.dataSource=self;

    //
    self.backgroundImg.image=[UIImage imageNamed:BACKGROUND_IMAGE_DAY];
    
    [self setHiddeninstructionImageView];

    ///////cicle
    [self initImageView];
    [self fromCircleView];
    
    //vote
    voteData = [NSMutableArray new];

    NSNumber *numZero = [NSNumber numberWithInt:0];
    for (int i=0; i<self.match.players.count; i++) {
        
        [voteData addObject:numZero];
    }
    
    selfVoteFor = 99;
    selfJudgeFor = 99;
    selfShouldUpdateVote = false;
    selfShouldSendVote = false;
    selfShouldVote = false;
    selfShouldSeeVote = false;
    
    //
    for (Player *p in self.match.players) {
        if ([p.playerId isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            
            selfTeam = p.playerTeam;
            selfState = p.playerState;
            [self.playerAliasBtn setTitle:p.alias forState:UIControlStateNormal];

            break;
        }
    }
    
    nightResults = [NSMutableArray new];
    nightResultsForAll = [NSMutableArray new];
    
    dayResults = [NSMutableArray new];
    
    judgementResults = [NSMutableArray new];
    
    lastVoteTime = [NSDate date];
    judgePlayerId = [NSString new];
    
    [self.playerStateBtn setTitle:@"遊戲中" forState:UIControlStateNormal];
    [self.playerStateBtn setTitleColor:[UIColor colorWithRed:45.0f/255.0f green:223.0f/255.0f blue:255.0f/255.0f alpha:1] forState:UIControlStateNormal];
    
    gameOverResult = NOT_OVER_YET;
}

- (void) viewDidAppear:(BOOL)animated {
    
    /////the other views
    SlotVc = [[SlotMachine alloc]init];
    self.transitionController = [[TransitionDelegate alloc] init];
    
    morningOutView =[MorningOutViewController new];
    nightOutView = [outView new];
    loadingView =[LoadingViewController new];
    
    //hide playerList
    [self hidePlayerList];
    //hide confirmButton
    [self hideConfirmBtn];
    
    //network
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
    [self gameStateChanged:[NetworkController sharedInstance].gameState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSystemMessage:(NSString *)message {
    
    NSArray *tmpChatArray = [NSArray arrayWithObjects:SYSTEM_ID, message, nil];
    [chatData addObject:tmpChatArray];
    
    [self.chatBoxTableView reloadData];
    
    NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
    [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
}

- (void)callSlotMachineWithOutputIndex:(NSInteger)outputIndex {
    
    SlotVc = [self.storyboard instantiateViewControllerWithIdentifier:@"slotMachine"];
    SlotVc.view.backgroundColor = [UIColor clearColor];
    [SlotVc setTransitioningDelegate:_transitionController];
    SlotVc.modalPresentationStyle= UIModalPresentationCustom;
    
    [SlotVc setOutputIndex:outputIndex];
    
    [self presentViewController:SlotVc animated:YES completion:^{
        
        [self performSelector:@selector(dismissSlotMachine) withObject:self afterDelay:3];
    }];
}

- (void)callLoadingView {

    loadingView = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    loadingView.view.backgroundColor = [UIColor blackColor];

    loadingView.modalPresentationStyle= UIModalPresentationCustom;
    [self presentViewController:loadingView animated:YES completion:nil];
    
}

-(void)callMorningOutViewWithPlayerImage:(UIImage *)playerImage {
    
    morningOutView = [self.storyboard instantiateViewControllerWithIdentifier:@"morningOutView"];
    
    morningOutView.playerImage = playerImage;
    
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:judgePlayerId] ||
        selfState == PLAYER_STATE_DEAD) {
        
        morningOutView.autoSwipe = true;
        
    }else {
        
        morningOutView.autoSwipe = false;
    }
    
    morningOutView.delegate = self;
    
    morningOutView.view.backgroundColor = [UIColor clearColor];
    [morningOutView setTransitioningDelegate:_transitionController];
    morningOutView.modalPresentationStyle= UIModalPresentationCustom;
    [self presentViewController:morningOutView animated:YES completion:nil];
}

- (void)callNightOutViewWithPlayerImage:(UIImage *)playerImage {
    
    nightOutView = [self.storyboard instantiateViewControllerWithIdentifier:@"nightOutView"];
    
    nightOutView.playerImage = playerImage;
    
    nightOutView.view.backgroundColor = [UIColor clearColor];
    [nightOutView setTransitioningDelegate:_transitionController];
    nightOutView.modalPresentationStyle= UIModalPresentationCustom;
    
    
    
    
    [self presentViewController:nightOutView animated:YES completion:^{
        
        [self performSelector:@selector(dismissNightOutView) withObject:self afterDelay:7.0f];
     
    }];
    
}

- (void)keyboardWillChangeFrame:(NSNotification*)notify {

    CGRect keyboardRect = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat durationTime = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGFloat transFromY = keyboardRect.origin.y - self.view.frame.size.height;

    [UIView beginAnimations:@"animation2" context:nil];
    [UIView animateWithDuration:durationTime animations:^{
        
        inputBar.transform=CGAffineTransformMakeTranslation(0, transFromY);
        }];
    
    [UIView animateWithDuration:durationTime animations:^{
        
          self.chatBoxTableView.transform =CGAffineTransformMakeTranslation(0, transFromY);
        }];
}


- (void)showDayBackgroundImage{
    
    [UIView transitionWithView:self.backgroundImg
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundImg.image = [UIImage imageNamed:BACKGROUND_IMAGE_DAY];
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

- (void)showNightBackgroundImage{
    
    [UIView transitionWithView:self.backgroundImg
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundImg.image = [UIImage imageNamed:BACKGROUND_IMAGE_NIGHT];
                    }
                    completion:^(BOOL finished) {
                        //changeGameState
                        [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:1];
                    }
     ];
}

- (IBAction)confirmVoteButtonPressed:(id)sender {
    
    if (selfState == PLAYER_STATE_DEAD ||
        [NetworkController sharedInstance].gameState == GameStateGameOver) {
        
        //change confirmVoteButton into leaveGameButton
        [self showBackToMenuAlertWithTitle:@"遊戲結束"];
        [[NetworkController sharedInstance] reconnect];
        
    }else {
        
        selfShouldVote = false;
        [self.playerListTableView reloadData];
        
        self.guiltyButton.userInteractionEnabled = false;
        self.innocentButton.userInteractionEnabled = false;
        
        if ([NetworkController sharedInstance].gameState == GameStateNightDiscussion ||
            [NetworkController sharedInstance].gameState == GameStateNightVote) {
            
            [self processNightVoteResult];

        }else if ([NetworkController sharedInstance].gameState == GameStateDayDiscussion ||
                  [NetworkController sharedInstance].gameState == GameStateDayVote) {
            
            [self processDayVoteResult];
            
        }else if ([NetworkController sharedInstance].gameState == GameStateJudgementDiscussion ||
                  [NetworkController sharedInstance].gameState == GameStateJudgementVote) {
            
            [self processJudgementResult];
        }
    }
    
    self.confirmVoteButton.enabled = false;
}

- (void)processNightVoteResult {
    
    [[NetworkController sharedInstance] sendNightConfirmVote];
    
    if (selfState == PLAYER_STATE_ALIVE) {

        if (selfTeam == PLAYER_TEAM_MAFIA) {
            
            if (selfVoteFor != 99) {
                
                Player *playerChosen = [self.match.players objectAtIndex:selfVoteFor];
                [self showSystemMessage:[NSString stringWithFormat:@"您決定封印%@", playerChosen.alias]];
                
            }else {
                
                [self showSystemMessage:@"您決定今晚放過所有人"];
            }
            
        }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
            
            for (int i=0; i<voteData.count; i++) {
                
                if ([[voteData objectAtIndex:i] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    
                    Player *playerChosen = [self.match.players objectAtIndex:i];
                    [self showSystemMessage:[NSString stringWithFormat:@"你決定今晚探索%@擁有的魔方", playerChosen.alias]];
                    if (playerChosen.playerTeam == PLAYER_TEAM_MAFIA) {
                        
                        [nightResults addObject:[NSString stringWithFormat:@"你發現了%@的魔方是%@", playerChosen.alias, PLAYER_TEAM_MAFIA_CUBE_STRING]];
                        
                    }else if (playerChosen.playerTeam == PLAYER_TEAM_SHERIFF) {
                        
                        [nightResults addObject:[NSString stringWithFormat:@"你發現了%@的魔方是%@", playerChosen.alias, PLAYER_TEAM_SHERIFF_CUBE_STRING]];
                        
                    }else if (playerChosen.playerTeam == PLAYER_TEAM_CIVILIAN) {
                        
                        [nightResults addObject:[NSString stringWithFormat:@"你發現了%@的魔方是%@", playerChosen.alias, PLAYER_TEAM_CIVILIAN_CUBE_STRING]];
                    }
                    
                    return;
                }
            }
            [self showSystemMessage:@"你今晚沒有探索任何人"];
        }
    }
}

- (void)processDayVoteResult {
    
    [[NetworkController sharedInstance] sendDayConfirmVote];
    
    if (selfVoteFor != 99) {
            
        Player *playerChosen = [self.match.players objectAtIndex:selfVoteFor];
        [self showSystemMessage:[NSString stringWithFormat:@"你決定投票審判%@", playerChosen.alias]];
            
    }else {
            
        [self showSystemMessage:@"你決定不審判任何人"];
    }
}

- (void)processJudgementResult {
    
    [[NetworkController sharedInstance] sendJudgementConfirmVote];
    
    NSString *judgePlayerAlias = [NSString new];
    
    for (Player *p in self.match.players) {
        
        if ([p.playerId isEqualToString:judgePlayerId]) {
            
            judgePlayerAlias = p.alias;
        }
    }
    
    if (selfJudgeFor == JUDGE_GUILTY) {
        
        [self showSystemMessage:[NSString stringWithFormat:@"你決定投票認定%@有嫌疑", judgePlayerAlias]];
        
    }else if (selfJudgeFor == JUDGE_INNOCENT) {
        
        [self showSystemMessage:[NSString stringWithFormat:@"你決定投票放過%@", judgePlayerAlias]];

    }else {
        
        [self showSystemMessage:@"你決定不做出判決"];
    }
}

- (IBAction)controlListBtnPressed:(id)sender {
    
    [UIView beginAnimations:@"animation1" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.playerListTableView cache:YES];
    [self.playerListTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
     [self.confirmVoteButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    CGRect frame = self.playerListTableView.frame;
    CGRect frameForBtn = self.confirmVoteButton.frame;
    
    if(frame.origin.y<0) {

        
        if(frameForBtn.origin.x>283)
        {
            frameForBtn.origin.x=283;
            self.confirmVoteButton.hidden =false;
        }
        
        frame.origin.y =103;
        self.playerListTableView.hidden = false;
        
    }else {
        
        if(frameForBtn.origin.x <= 283){
            
            if ([NetworkController sharedInstance].gameState == GameStateJudgementDiscussion ||
                [NetworkController sharedInstance].gameState == GameStateJudgementVote ||
                [NetworkController sharedInstance].gameState == GameStateGameOver ||
                selfState == PLAYER_STATE_DEAD) {
                
            }else {
                
                frameForBtn.origin.x +=frameForBtn.size.width+20;
            }
        }
        
        frame.origin.y -=frame.size.height+110;
        [self performSelector:@selector(setHiddenPlayerList) withObject:self afterDelay:0.3f];
    }
    
    self.playerListTableView.frame =frame;

    self.confirmVoteButton.frame=frameForBtn;
    
    [UIView commitAnimations];
}

- (void)hidePlayerList {
    
    [UIView beginAnimations:@"animation1" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.playerListTableView cache:YES];
    [self.playerListTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    CGRect frame = self.playerListTableView.frame;
    
    if(frame.origin.y>=0) {
        
        frame.origin.y -=frame.size.height+110;
        [self performSelector:@selector(setHiddenPlayerList) withObject:self afterDelay:0.3f];
    }
 
    self.playerListTableView.frame =frame;
    
    [UIView commitAnimations];
}

- (void)setHiddenPlayerList {
    
    self.playerListTableView.hidden = true;
}

- (void)showPlayerList {
    
    [UIView beginAnimations:@"animation1" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.playerListTableView cache:YES];
    [self.playerListTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    CGRect frame = self.playerListTableView.frame;
    
    if(frame.origin.y<0) {
        
        frame.origin.y =103;
        self.playerListTableView.hidden = false;
    }
    
    self.playerListTableView.frame =frame;
    
    [UIView commitAnimations];
}

- (void)hideConfirmBtn{
    
    [UIView beginAnimations:@"animation1" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.confirmVoteButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    CGRect frameForBtn= self.confirmVoteButton.frame;
    
    if(frameForBtn.origin.x<=283)
    {
        frameForBtn.origin.x +=frameForBtn.size.width+20;
        [self performSelector:@selector(setHiddenConfirmButton) withObject:self afterDelay:0.3f];
    }
    
    self.confirmVoteButton.frame = frameForBtn;
    [UIView commitAnimations];
}

- (void)setHiddenConfirmButton {
    
    self.confirmVoteButton.hidden = true;
}

-(void)showConfirmBtn{
    
    [UIView beginAnimations:@"animation1" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.confirmVoteButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    CGRect frameForBtn= self.confirmVoteButton.frame;
        
    if(frameForBtn.origin.x>283)
    {
        frameForBtn.origin.x=283;
        self.confirmVoteButton.hidden =false;
    }

    self.confirmVoteButton.frame = frameForBtn;
    [UIView commitAnimations];
}

- (IBAction)sendButtonPressed:(id)sender {
    
    NSString *chat = self.chatTextField.text;
    
    if (chat.length > 0) {
        //for self
        NSArray *tmpChatArray = [NSArray arrayWithObjects:(NSString *)[NSString stringWithFormat:@"%@", [GKLocalPlayer localPlayer].playerID], (NSString *)chat, nil];
        [chatData addObject:tmpChatArray];
                
        [self.chatBoxTableView reloadData];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
        [self.chatBoxTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
        
        //for other players
        [[NetworkController sharedInstance] sendChat:chat withChatType:selfChatType];
    }
    //隱藏鍵盤
    [self.view endEditing:TRUE];
    self.chatTextField.text = nil;
}

//若點擊畫面
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:TRUE];
}

- (void)dismissSlotMachine {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
    switch (selfTeam) {
            
        case PLAYER_TEAM_CIVILIAN:
            
            self.playerTeamBtn.image =[UIImage imageNamed:PLAYER_TEAM_PEACE_IMAGE];
            self.instructionImageView.image = [UIImage imageNamed:PLAYER_TEAM_INSTRUCTION_PEACE];
            break;
            
        case PLAYER_TEAM_SHERIFF:
            
            self.playerTeamBtn.image =[UIImage imageNamed:PLAYER_TEAM_EYES_IMAGE];
            self.instructionImageView.image = [UIImage imageNamed:PLAYER_TEAM_INSTRUCTION_DISCOVER];
            break;
            
        case PLAYER_TEAM_MAFIA:
            
            self.playerTeamBtn.image =[UIImage imageNamed:PLAYER_TEAM_FIRE_IMAGE];
            self.instructionImageView.image = [UIImage imageNamed:PLAYER_TEAM_INSTRUCTION_RUIN];
            break;
            
        default:
           
            break;
    }
    
    //show systemMessage
    if (selfTeam == PLAYER_TEAM_MAFIA) {

        [self showSystemMessage:[NSString stringWithFormat:@"您的魔方是%@", PLAYER_TEAM_MAFIA_CUBE_STRING]];
        
    }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
        
        [self showSystemMessage:[NSString stringWithFormat:@"您的魔方是%@", PLAYER_TEAM_SHERIFF_CUBE_STRING]];

    }else if (selfTeam == PLAYER_TEAM_CIVILIAN) {
        
        [self showSystemMessage:[NSString stringWithFormat:@"您的魔方是%@", PLAYER_TEAM_CIVILIAN_CUBE_STRING]];
    }

    //show instructionImageView
    [self playerTeamBtnPressed:nil];
    
    //changeGameState
    [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:1.5f];
}

- (void)dismissNightOutView {
    
    [self dismissViewControllerAnimated:true completion:^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您即將被封印" message:@"在你被封印之前,你還有最後的機會留下線索" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *lastWords = [alert.textFields[0] text];
            
            if (lastWords.length == 0) {
                
                [[NetworkController sharedInstance] sendLastWords:LAST_WORDS_EMPTY];
                
            }else {
                
                [[NetworkController sharedInstance] sendLastWords:lastWords];
            }
            self.confirmVoteButton.enabled = true;
        }];
        
        [alert addAction:done];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
            textField.placeholder = @"leave your lastwords here";
            textField.returnKeyType = UIReturnKeyDone;
        }];
        
        [self performSelector:@selector(presentAlertViewController:) withObject:alert afterDelay:2.0f];
    }];
}

- (void)presentAlertViewController:(UIAlertController *)alert {
    
    [self presentViewController:alert animated:false completion:nil];
}

- (void)switchToNextGameState {
    
    GameState currentGameState = [NetworkController sharedInstance].gameState;
    [[NetworkController sharedInstance] setGameState:currentGameState+1];
}

- (void)switchToGameStateNightStart {
    
    [[NetworkController sharedInstance] setGameState:GameStateNightStart];
}

- (void)switchToGameStateGameOver {
    
    [[NetworkController sharedInstance] setGameState:GameStateGameOver];
}

- (void)resetVote {
    
    //for self
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selfVoteFor inSection:0];
    playerCell *cell = (playerCell *)[self.playerListTableView cellForRowAtIndexPath:indexPath];
    cell.vote.textColor = [UIColor blackColor];
    selfVoteFor = 99;
    NSNumber *num = [NSNumber numberWithInt:0];
    for (int i=0; i<voteData.count; i++) {
        [voteData replaceObjectAtIndex:i withObject:num];
    }
    [self.playerListTableView reloadData];
    
    if (selfJudgeFor == JUDGE_GUILTY) {
        
        self.guityCountLabel.textColor = [UIColor whiteColor];
        
    }else {
        
        self.innocentCountLabel.textColor = [UIColor whiteColor];
    }
    selfJudgeFor = 99;
    self.guityCountLabel.text = @"0";
    self.innocentCountLabel.text = @"0";
    
    //for server
    [[NetworkController sharedInstance] sendResetVote];
}

- (IBAction)guiltyButtonPressed:(id)sender {
    
    NSDate *now = [NSDate date];
    
    if ([now timeIntervalSinceDate:lastVoteTime] > VOTE_MINIMUM_TIME_INTERVAL) {
        
        lastVoteTime = now;
        
        //for other players
        if (selfShouldSendVote == true) {
            
            [[NetworkController sharedInstance] sendJudgeFor:JUDGE_GUILTY];
        }
        
        //for self
        NSString *judgePlayerAlias = [NSString new];
        
        for (Player *p in self.match.players) {
            
            if ([p.playerId isEqualToString:judgePlayerId]) {
                
                judgePlayerAlias = p.alias;
            }
        }
        
        NSString *judgeMessage = [NSString new];
        
        if (selfJudgeFor == JUDGE_GUILTY) {//已選取有罪
            
            //voteCount -1
            [self changeJudgeData:JUDGE_GUILTY withInt:-1 fromSelf:true];
            
            //set message
            judgeMessage = [NSString stringWithFormat:@"取消了對%@的投票", judgePlayerAlias];
            
            //update selfVoteFor
            selfJudgeFor = 99;
            
        }else if (selfJudgeFor == 99) {//原本未選取
            
            //voteCount +1
            [self changeJudgeData:JUDGE_GUILTY withInt:+1 fromSelf:true];
            
            //set message
            judgeMessage = [NSString stringWithFormat:@"認為%@有嫌疑", judgePlayerAlias];
            
            //update selfVoteFor
            selfJudgeFor = JUDGE_GUILTY;
            
            
        }else {//原本選取無罪
            
            //voteCount -1
            [self changeJudgeData:JUDGE_INNOCENT withInt:-1 fromSelf:true];
            
            //voteCount +1
            [self changeJudgeData:JUDGE_GUILTY withInt:+1 fromSelf:true];
            
            //set message
            judgeMessage = [NSString stringWithFormat:@"改變了主意，認為%@有嫌疑", judgePlayerAlias];
            
            //update selfVoteFor
            selfJudgeFor = JUDGE_GUILTY;
        }
        
        //show message
        NSArray *tmpChatArray = [NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, judgeMessage, nil];
        [chatData addObject:tmpChatArray];
        
        [self.chatBoxTableView reloadData];
        
        //scroll to bottom
        NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
        [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
    }
}

- (IBAction)InnocentButtonPressed:(id)sender {
    
    NSDate *now = [NSDate date];
    
    if ([now timeIntervalSinceDate:lastVoteTime] > VOTE_MINIMUM_TIME_INTERVAL) {
        
        lastVoteTime = now;
        
        //for other players
        if (selfShouldSendVote == true) {
            
            [[NetworkController sharedInstance] sendJudgeFor:JUDGE_INNOCENT];
        }
        
        //for self
        NSString *judgePlayerAlias = [NSString new];
        
        for (Player *p in self.match.players) {
            
            if ([p.playerId isEqualToString:judgePlayerId]) {
                
                judgePlayerAlias = p.alias;
            }
        }
        
        NSString *judgeMessage = [NSString new];
        
        if (selfJudgeFor == JUDGE_INNOCENT) {//已選取無罪
            
            //voteCount -1
            [self changeJudgeData:JUDGE_INNOCENT withInt:-1 fromSelf:true];
            
            //set message
            judgeMessage = [NSString stringWithFormat:@"取消了對%@的投票", judgePlayerAlias];
            
            //update selfVoteFor
            selfJudgeFor = 99;
            
        }else if (selfJudgeFor == 99) {//原本未選取
            
            //voteCount +1
            [self changeJudgeData:JUDGE_INNOCENT withInt:+1 fromSelf:true];
            
            //set message
            judgeMessage = [NSString stringWithFormat:@"認為%@沒有嫌疑", judgePlayerAlias];
            
            //update selfVoteFor
            selfJudgeFor = JUDGE_INNOCENT;
            
            
        }else {//原本選取有罪
            
            //voteCount -1
            [self changeJudgeData:JUDGE_GUILTY withInt:-1 fromSelf:true];
            
            //voteCount +1
            [self changeJudgeData:JUDGE_INNOCENT withInt:+1 fromSelf:true];
            
            //set message
            judgeMessage = [NSString stringWithFormat:@"改變了主意，認為%@沒有嫌疑", judgePlayerAlias];
            
            //update selfVoteFor
            selfJudgeFor = JUDGE_INNOCENT;
        }
        
        //show message
        NSArray *tmpChatArray = [NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, judgeMessage, nil];
        [chatData addObject:tmpChatArray];
        
        [self.chatBoxTableView reloadData];
        
        //scroll to bottom
        NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
        [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
    }
}

- (void)changeJudgeData:(int)judgeDataIndex withInt:(int)intNumber fromSelf:(BOOL)fromSelf {
    
    //change text & color
    if (judgeDataIndex == JUDGE_GUILTY) {
        
        int tmpInt = [self.guityCountLabel.text intValue] + intNumber;
        self.guityCountLabel.text = [NSString stringWithFormat:@"%d",tmpInt];
        
        if (fromSelf) {
            
            if (intNumber == +1) {
            
                self.guityCountLabel.textColor = [UIColor redColor];

            }else {
            
                self.guityCountLabel.textColor = [UIColor whiteColor];
            }
        }
        
    }else {
        
        int tmpInt = [self.innocentCountLabel.text intValue] + intNumber;
        self.innocentCountLabel.text = [NSString stringWithFormat:@"%d",tmpInt];

        if (fromSelf) {
            
            if (intNumber == +1) {
            
                self.innocentCountLabel.textColor = [UIColor redColor];
            
            }else {
            
                self.innocentCountLabel.textColor = [UIColor whiteColor];
            }
        }
    }
}

- (void)enableChatTextField {
    
    self.chatTextField.enabled = true;
}

- (void)changeChatConditionButtonImage:(NSString *)imageName {
    
    [self.chatConditionButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


- (void)showBackToMenuAlertWithTitle:(NSString *)titleString {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleString message:@"將回到Menu" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [[NetworkController sharedInstance] setGameState:GameStateNotInGame];
        rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootVC dismissViewControllerAnimated:true completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

- (IBAction)playerTeamBtnPressed:(id)sender {
    
    [UIView beginAnimations:@"animationForInstruction" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.instructionImageView cache:YES];
    [self.instructionImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    CGRect frame = self.instructionImageView.frame;
    
    if (frame.origin.x<0) {
        
        frame.origin.x =0;
        self.instructionImageView.hidden = false;
        
    }else {
        
        frame.origin.x = -250;
        [self performSelector:@selector(setHiddeninstructionImageView) withObject:self afterDelay:0.3f];

    }
    
    self.instructionImageView.frame =frame;
    
    [UIView commitAnimations];
}

- (void)setHiddeninstructionImageView {
    
    self.instructionImageView.hidden = true;

}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.chatTextField) {
        
        [self sendButtonPressed:nil];
        return false;
    }
    
    return true;
}

#pragma mark - MorningOutViewControllerDelegate

- (void)swiped {
    
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:judgePlayerId]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您即將被封印" message:@"在你被封印之前,你還有最後的機會能留下線索" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *lastWords = [alert.textFields[0] text];
            
            if (lastWords.length == 0) {
                
                [[NetworkController sharedInstance] sendLastWords:LAST_WORDS_EMPTY];
                
            }else {
                
                [[NetworkController sharedInstance] sendLastWords:lastWords];
            }
            self.confirmVoteButton.enabled = true;
        }];
        
        [alert addAction:done];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
            textField.placeholder = @"留下你最後的線索";
            textField.returnKeyType = UIReturnKeyDone;
        }];
        
        [self performSelector:@selector(presentAlertViewController:) withObject:alert afterDelay:2.0f];
        
    }
}

#pragma mark - cirleThePlayerImage

-(void)initImageView{
    
    dragImageView *tempDragImageView;
    playerDragImageViewArray = [NSMutableArray new];
    
    for (Player *player in self.match.players) {
        
        tempDragImageView = [[dragImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        tempDragImageView.contentMode = UIViewContentModeScaleAspectFit;
        tempDragImageView.backgroundColor=[UIColor clearColor];
        tempDragImageView.image = player.playerImage;
        
        [playerDragImageViewArray addObject:tempDragImageView];
    }
}

-(void)fromCircleView{
    
    circleView *circle =[[circleView alloc]initWithFrame:CGRectMake(0, 0, self.backgroundImg.frame.size.width, self.backgroundImg.frame.size.height)];
    circle.backgroundColor=[UIColor clearColor];
    circle.ImgArray  = playerDragImageViewArray;
    circle.center = self.backgroundImg.center;
    [self.thePlayerView insertSubview:circle atIndex:1];
    [circle loadView];
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.playerListTableView){
        
        playerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell"];

        
        Player *p = [self.match.players objectAtIndex:indexPath.row];
        
        cell.playerPhoto.image = p.playerImage;
        cell.playerName.text = p.alias;
        cell.vote.text = [NSString stringWithFormat:@"%d",[[voteData objectAtIndex:indexPath.row] intValue]];
        
        if (p.playerState == PLAYER_STATE_ALIVE) {
            
            cell.playerName.textColor = [UIColor blackColor];
        
        }else {
            
            cell.playerName.textColor = [UIColor grayColor];
           
        }
        
        if (selfShouldVote) {
            
            //若 顯示的是活人 & 顯示的不是自己 才能開放選取
            if (p.playerState == PLAYER_STATE_ALIVE &&
                ![p.playerId isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                
                //晚上殺手不能殺自己人
                if ([NetworkController sharedInstance].gameState == GameStateNightDiscussion ||
                    [NetworkController sharedInstance].gameState == GameStateNightVote) {
                    
                    if (selfTeam == PLAYER_TEAM_MAFIA && p.playerTeam == PLAYER_TEAM_MAFIA) {

                        cell.userInteractionEnabled = false;
                        
                    }else {
                    
                        cell.userInteractionEnabled = true;
                    }
                    
                }else {
                    
                    cell.userInteractionEnabled = true;
                }
                
            }else {
                
                cell.userInteractionEnabled = false;
            }
            
        }else {
            
            cell.userInteractionEnabled = false;
        }
        
        //若 selfShouldSeeVote & 顯示的是活人
        if (selfShouldSeeVote == true &&
            p.playerState == PLAYER_STATE_ALIVE) {
            
            //晚上
            if ([NetworkController sharedInstance].gameState == GameStateNightDiscussion ||
                [NetworkController sharedInstance].gameState == GameStateNightVote) {
                
                //殺手不能殺自己人
                if (selfTeam == PLAYER_TEAM_MAFIA && p.playerTeam == PLAYER_TEAM_MAFIA) {
                    
                    cell.vote.hidden = true;
                    
                //警察不能調查自己
                }else if (selfTeam == PLAYER_TEAM_SHERIFF &&
                          [p.playerId isEqualToString:[GKLocalPlayer localPlayer].playerID] ) {
                    
                    cell.vote.hidden = true;

                }else {

                    cell.vote.hidden = false;
                }
            }else {
                
                cell.vote.hidden = false;
            }
        }else {
            
            cell.vote.hidden = true;
        }
        
        if (p.playerTeam == PLAYER_TEAM_CIVILIAN) {
            
            cell.playerTeamImageView.image = [UIImage imageNamed:PLAYER_TEAM_CIVILIAN_IMAGE];
            
        }else if (p.playerTeam == PLAYER_TEAM_MAFIA) {
            
            cell.playerTeamImageView.image = [UIImage imageNamed:PLAYER_TEAM_MAFIA_IMAGE];
            
        }else if (p.playerTeam == PLAYER_TEAM_SHERIFF) {
            
            cell.playerTeamImageView.image = [UIImage imageNamed:PLAYER_TEAM_SHERIFF_IMAGE];
            
        }
        
        if (p.playerState == PLAYER_STATE_DEAD) {
            
            cell.playerTeamImageView.hidden = false;
            
         
            
            
        }else {
            
            cell.playerTeamImageView.hidden = true;
        }

        if (gameOverResult != NOT_OVER_YET) {
            
            cell.vote.hidden = true;

            cell.playerTeamImageView.hidden = false;
        }
        return cell;
        
    }else if (tableView == self.chatBoxTableView) {

        ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
        
        NSArray *tmpChatArray = [chatData objectAtIndex:indexPath.row];
        
        if ([[tmpChatArray objectAtIndex:0] isEqualToString:SYSTEM_ID]) {//系統訊息
            
            [cell.playerImageImageView setImage:[UIImage imageNamed:SYSTEM_IMAGE]];
            [cell.playerNameLabel setText:@"System"];
            
        }else {
            
            NSString *tmpPlayerId = [tmpChatArray objectAtIndex:0];
            
            for (Player *p in self.match.players) {
                
                if ([p.playerId isEqualToString:tmpPlayerId]) {
                    
                    [cell.playerImageImageView setImage:p.playerImage];
                    
                    if ([p.playerId isEqualToString:[GKLocalPlayer localPlayer].playerID]) {//若發話人為自己

                        [cell.playerNameLabel setText:@"你"];
                        
                    }else {
                        
                        [cell.playerNameLabel setText:p.alias];
                    }
                    break;
                }
            }
        }
        NSString *tmpChat = [tmpChatArray objectAtIndex:1];
        [cell.chatLabel setText:tmpChat];
        
        return cell;
        
    }else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.playerListTableView){
    
        return 40;
        
    }else if (tableView == self.chatBoxTableView) {
        
        UIFont * font = [UIFont systemFontOfSize:14.0f];
        NSString *text = [[chatData objectAtIndex:indexPath.row] objectAtIndex:1];
        CGFloat height = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-80, 10000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: font} context:nil].size.height;
        
        return height + 30.0f;
        
    }else {
        
        return 40;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.playerListTableView){
        
        return self.match.players.count;
        
    }else{
        
        return chatData.count;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDate *now = [NSDate date];
    
    if (tableView == self.playerListTableView &&
        [now timeIntervalSinceDate:lastVoteTime] > VOTE_MINIMUM_TIME_INTERVAL) {

        lastVoteTime = now;
        
        //for other players
        if (selfShouldSendVote == true) {
            
            [[NetworkController sharedInstance] sendVoteFor:(int)indexPath.row];
        }
        
        //for self
        if (indexPath.row == selfVoteFor) {//選取自己已選取的玩家
            
            playerCell *cell = (playerCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            //voteCount -1
            NSNumber *num = [NSNumber numberWithInt:([[voteData objectAtIndex:indexPath.row] intValue] -1)];
            [voteData replaceObjectAtIndex:indexPath.row withObject:num];
            
            cell.vote.textColor = [UIColor blackColor];
            
            //show message
            Player *player = [self.match.players objectAtIndex:indexPath.row];
            
            NSString *systemMessgae = [NSString stringWithFormat:@"取消了對%@的投票", player.alias];
            NSArray *tmpChatArray = [NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, systemMessgae, nil];
            [chatData addObject:tmpChatArray];
            
            [self.chatBoxTableView reloadData];
            //scroll to bottom
            NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
            [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
            
            //update selfVoteFor
            selfVoteFor = 99;
            
        }else if (selfVoteFor == 99) {//原本未選取玩家
            
            playerCell *cell = (playerCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            //voteCount +1
            NSNumber *num = [NSNumber numberWithInt:([[voteData objectAtIndex:indexPath.row] intValue] +1)];
            [voteData replaceObjectAtIndex:indexPath.row withObject:num];
            
            cell.vote.textColor = [UIColor redColor];
            
            //show message
            Player *player = [self.match.players objectAtIndex:indexPath.row];
            
            NSString *systemMessgae = [NSString stringWithFormat:@"將票投給了%@", player.alias];
            NSArray *tmpChatArray = [NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, systemMessgae, nil];
            [chatData addObject:tmpChatArray];
            
            [self.chatBoxTableView reloadData];
            //scroll to bottom
            NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
            [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
            
            //update selfVoteFor
            selfVoteFor = (int)indexPath.row;

            
        }else {//原本有選取玩家
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:selfVoteFor inSection:0];
            
            playerCell *cell = (playerCell *)[tableView cellForRowAtIndexPath:ip];
            
            //voteCount -1
            NSNumber *num = [NSNumber numberWithInt:([[voteData objectAtIndex:selfVoteFor] intValue] -1)];
            [voteData replaceObjectAtIndex:selfVoteFor withObject:num];
            
            cell.vote.textColor = [UIColor blackColor];
            
            cell = (playerCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            //voteCount +1
            num = [NSNumber numberWithInt:([[voteData objectAtIndex:indexPath.row] intValue] +1)];
            [voteData replaceObjectAtIndex:indexPath.row withObject:num];
            
            cell.vote.textColor = [UIColor redColor];
            
            //show message
            Player *playerPrev = [self.match.players objectAtIndex:selfVoteFor];
            Player *player = [self.match.players objectAtIndex:indexPath.row];
            
            NSString *systemMessgae = [NSString stringWithFormat:@"取消了對%@的投票，並將票投給了%@", playerPrev.alias, player.alias];
            NSArray *tmpChatArray = [NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, systemMessgae, nil];
            [chatData addObject:tmpChatArray];
            
            [self.chatBoxTableView reloadData];
            //scroll to bottom
            NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
            [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];

            //update selfVoteFor
            selfVoteFor = (int)indexPath.row;
        }
        
        [self.playerListTableView reloadData];
        
        return nil;
        
    }else {
        
        return nil;
    }
}

#pragma mark - NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState {
    
    switch(networkState) {
            
        case NetworkStateNotAvailable:
            
            [self showBackToMenuAlertWithTitle:@"未登入Game Center"];
            break;
            
        case NetworkStatePendingAuthentication:
            
            break;
            
        case NetworkStateAuthenticated:
            
            break;
            
        case NetworkStateConnectingToServer:
            
            [self showBackToMenuAlertWithTitle:@"與伺服器連線中斷"];
            break;
            
        case NetworkStateConnected:
            
            break;
            
        case NetworkStatePendingMatchStatus:
            
            break;
            
        case NetworkStateReceivedMatchStatus:
            
            [self showBackToMenuAlertWithTitle:@"遊戲結束"];
            break;
            
        case NetworkStatePendingMatch:
            
            break;
            
        case NetworkStatePendingMatchStart:
            
            break;
            
        case NetworkStateMatchActive:
            
            break;
    }
}

- (void)matchStarted:(Match *)match {
    
}

- (void)updateChat:(NSString *)chat withPlayerId:(NSString *)playerId {

    NSArray *tmpChatArray = [NSArray arrayWithObjects:(NSString *)[NSString stringWithFormat:@"%@", playerId], (NSString *)chat, nil];
    [chatData addObject:tmpChatArray];
            
    [self.chatBoxTableView reloadData];
    //scroll to bottom
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
    [self.chatBoxTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
}

- (void)updateVoteFor:(int)voteFor fromVotedFor:(int)votedFor withPlayerId:(NSString *)playerId {
    
    if (selfShouldUpdateVote == false) {
        
        return;
    }
    
    if (voteFor == votedFor) {//選取自己已選取的玩家
        
        //voteCount -1
        NSNumber *num = [NSNumber numberWithInt:([[voteData objectAtIndex:voteFor] intValue] -1)];
        [voteData replaceObjectAtIndex:voteFor withObject:num];
        
        //show message
        Player *player = [self.match.players objectAtIndex:voteFor];
        
        NSString *systemMessgae = [NSString stringWithFormat:@"取消了對%@的投票", player.alias];
        NSArray *tmpChatArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", playerId],systemMessgae, nil];
        [chatData addObject:tmpChatArray];
        
        [self.chatBoxTableView reloadData];
        //scroll to bottom
        NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
        [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
        
    }else if (votedFor == 99) {//原本未選取玩家
        
        //voteCount +1
        NSNumber *num = [NSNumber numberWithInt:([[voteData objectAtIndex:voteFor] intValue] +1)];
        [voteData replaceObjectAtIndex:voteFor withObject:num];
        
        //show message
        Player *player = [self.match.players objectAtIndex:voteFor];
        
        NSString *systemMessgae = [NSString stringWithFormat:@"將票投給了%@", player.alias];
        NSArray *tmpChatArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", playerId],systemMessgae, nil];
        [chatData addObject:tmpChatArray];
        
        [self.chatBoxTableView reloadData];
        //scroll to bottom
        NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
        [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
        
    }else {//原本有選取玩家
        
        //voteCount -1
        NSNumber *num = [NSNumber numberWithInt:([[voteData objectAtIndex:votedFor] intValue] -1)];
        [voteData replaceObjectAtIndex:votedFor withObject:num];
        
        //voteCount +1
        num = [NSNumber numberWithInt:([[voteData objectAtIndex:voteFor] intValue] +1)];
        [voteData replaceObjectAtIndex:voteFor withObject:num];
        
        //show message
        Player *playerPrev = [self.match.players objectAtIndex:votedFor];
        Player *player = [self.match.players objectAtIndex:voteFor];
        
        NSString *systemMessgae = [NSString stringWithFormat:@"取消了對%@的投票，並將票投給了%@", playerPrev.alias, player.alias];
        NSArray *tmpChatArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", playerId],systemMessgae, nil];
        [chatData addObject:tmpChatArray];
        
        [self.chatBoxTableView reloadData];
        //scroll to bottom
        NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
        [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
        
    }
    
    [self.playerListTableView reloadData];
}

- (void)updateJudgeFor:(int)judgeFor fromJudgedFor:(int)judgedFor withPlayerId:(NSString *)playerId {
    
    if (selfShouldUpdateVote == false) {
        
        return;
    }
    
    NSString *judgePlayerAlias = [NSString new];
    
    for (Player *p in self.match.players) {
        
        if ([p.playerId isEqualToString:judgePlayerId]) {
            
            judgePlayerAlias = p.alias;
        }
    }
    
    NSString *judgeMessage = [NSString new];
    
    if (judgeFor == judgedFor) {//選取同一選項
        
        //voteCount -1
        [self changeJudgeData:judgeFor withInt:-1 fromSelf:false];
        
        //set message
        if (judgeFor == JUDGE_GUILTY) {
            
            judgeMessage = [NSString stringWithFormat:@"取消了對%@的有嫌疑的投票", judgePlayerAlias];
            
        }else {
            
            judgeMessage = [NSString stringWithFormat:@"取消了對%@的無嫌疑投票", judgePlayerAlias];
        }
        
    }else if (judgedFor == 99) {//原本未選取
        
        //voteCount +1
        [self changeJudgeData:judgeFor withInt:+1 fromSelf:false];
        
        //set message
        if (judgeFor == JUDGE_GUILTY) {
            
            judgeMessage = [NSString stringWithFormat:@"認為%@有嫌疑", judgePlayerAlias];
            
        }else {
            
            judgeMessage = [NSString stringWithFormat:@"認為%@無嫌疑", judgePlayerAlias];
        }
        
    }else {//原本有選取玩家
        
        //voteCount -1
        [self changeJudgeData:judgedFor withInt:-1 fromSelf:false];
        
        //voteCount +1
        [self changeJudgeData:judgeFor withInt:+1 fromSelf:false];
        
        //set message
        if (judgeFor == JUDGE_GUILTY) {
            
            judgeMessage = [NSString stringWithFormat:@"改變了主意，認為%@有嫌疑", judgePlayerAlias];
            
        }else {
            
            judgeMessage = [NSString stringWithFormat:@"改變了主意，認為%@無嫌疑", judgePlayerAlias];
        }
    }
    
    //show message
    NSArray *tmpChatArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", playerId],judgeMessage, nil];
    [chatData addObject:tmpChatArray];
    
    [self.chatBoxTableView reloadData];
    
    //scroll to bottom
    NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
    [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
}

- (void)allowVote {
    
    if ([NetworkController sharedInstance].gameState == GameStateNightDiscussion ||
        [NetworkController sharedInstance].gameState == GameStateNightVote) {
        
        //allowNightVote
        if (selfState == PLAYER_STATE_ALIVE) {

            if (selfTeam == PLAYER_TEAM_MAFIA) {
                
                selfShouldVote = true;
                selfShouldSeeVote = true;
                
                //show playerList
                [self showPlayerList];
                //show confirmButton
                [self showConfirmBtn];
                
            }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
                
                selfShouldVote = true;
                selfShouldSeeVote = true;
                
                //show playerList
                [self showPlayerList];
                [self showConfirmBtn];
                
            }else {
                
                selfShouldVote = false;
                selfShouldSeeVote = false;
            }
            
        }else {
            
            selfShouldVote = false;
            selfShouldSeeVote = false;
        }

    }else if ([NetworkController sharedInstance].gameState == GameStateDayDiscussion ||
              [NetworkController sharedInstance].gameState == GameStateDayVote) {
        
        //allowDayVote
        if (selfState == PLAYER_STATE_ALIVE) {
            
            selfShouldVote = true;
            selfShouldSeeVote = true;
            
        }else {
            
            selfShouldVote = false;
            selfShouldSeeVote = true;
        }
        
        //show playerList
        [self showPlayerList];
        //show confirmButton
        [self showConfirmBtn];
        
    }else if ([NetworkController sharedInstance].gameState == GameStateJudgementDiscussion ||
              [NetworkController sharedInstance].gameState == GameStateJudgementVote) {
        
        //allowJudgementVote
        if (selfState == PLAYER_STATE_ALIVE) {

            if ([[GKLocalPlayer localPlayer].playerID isEqualToString:judgePlayerId]) {
                
                selfShouldVote = false;
                selfShouldSeeVote = true;
                
            }else {
                
                selfShouldVote = true;
                selfShouldSeeVote = true;
            }
            
        }else {
            
            selfShouldVote = false;
            selfShouldSeeVote = true;
        }
        
        //allow judgement vote
        self.judgementVoteView.hidden = false;
        //show confirmButton
        [self showConfirmBtn];
    }
    [self.playerListTableView reloadData];
    
//    //show confirmButton
//    [self showConfirmBtn];
    
    //changeGameState
    [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:3];
}

- (void)playerDied:(NSString *)playerId {
    
    if ([NetworkController sharedInstance].gameState == GameStateNightDiscussion ||
        [NetworkController sharedInstance].gameState == GameStateNightVote) {
    
        if ([playerId isEqualToString:@"noOne"]) {
        
            waitForLastWords = false;
        
            [nightResultsForAll addObject:@"昨晚刀聲霍霍,但是所有人都平安的度過了"];

            if (selfState == PLAYER_STATE_ALIVE) {
            
                if (selfTeam == PLAYER_TEAM_MAFIA) {

                    [nightResults addObject:@"破壞魔方今晚沒有啟動"];
                }
            }
        }else {
    
            waitForLastWords = true;
        
            if ([[GKLocalPlayer localPlayer].playerID isEqualToString:playerId]) {
        
                [nightResults addObject:@"您在今晚不幸地被某人封印了"];
            
                for (Player *p in self.match.players) {
                
                    if ([p.playerId isEqualToString:playerId]) {
                    
                        [self performSelector:@selector(callNightOutViewWithPlayerImage:) withObject:p.playerImage afterDelay:1.0f];
                        
                    
                        break;
                    }
                }
            }
        
            if (selfState == PLAYER_STATE_ALIVE) {

                if (selfTeam == PLAYER_TEAM_MAFIA) {
            
                    for (Player *p in self.match.players) {
                
                        if ([p.playerId isEqualToString:playerId]) {
                    
                            [nightResults addObject:[NSString stringWithFormat:@"今晚破壞魔方啟動了,將%@封印至心之魔方中", p.alias]];
                            break;
                        }
                    }
                }
            }
        
            for (Player *p in self.match.players) {
        
                if ([p.playerId isEqualToString:playerId]) {
            
                    p.playerState = PLAYER_STATE_DEAD;
                    
                    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:p.playerId]) {
                        
                        selfState = PLAYER_STATE_DEAD;
                        [self.confirmVoteButton setTitle:@"離開遊戲" forState:UIControlStateNormal];

                        [self.playerStateBtn setTitle:@"出局" forState:UIControlStateNormal];
                        [self.playerStateBtn setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:33.0f/255.0f blue:72.0f/255.0f alpha:1] forState:UIControlStateNormal];
                    }
                    
                    break;
                }
            }
        }
        [[NetworkController sharedInstance] setGameState:GameStateShowNightResults];
        
    }else if ([NetworkController sharedInstance].gameState == GameStateJudgementDiscussion ||
              [NetworkController sharedInstance].gameState == GameStateJudgementVote) {
        
        NSString *judgePlayerAlias = [NSString new];
        
        for (Player *p in self.match.players) {
            
            if ([p.playerId isEqualToString:judgePlayerId]) {
                
                judgePlayerAlias = p.alias;
            }
        }
        
        if ([playerId isEqualToString:@"noOne"]) {
            
            waitForLastWords = false;
            
            
            
            [judgementResults addObject:[NSString stringWithFormat:@"依據審判的結果,我們決定再給%@一次機會", judgePlayerAlias]];
            
        }else {
            
            waitForLastWords = true;
            
            if ([[GKLocalPlayer localPlayer].playerID isEqualToString:judgePlayerId]) {
                
                [judgementResults addObject:@"因為沒能說服多數人相信你是無辜的,您將被封印"];
                
                for (Player *p in self.match.players) {
                    
                    if ([p.playerId isEqualToString:judgePlayerId]) {
                     
                        [self performSelector:@selector(callMorningOutViewWithPlayerImage:) withObject:p.playerImage afterDelay:1.0f];
                        
                        
                        
                        break;
                    }
                }
                
            }else {
                
                [judgementResults addObject:[NSString stringWithFormat:@"依據審判的結果,我們封印了%@", judgePlayerAlias]];
                [judgementResults addObject:[NSString stringWithFormat:@"請稍候%@留下線索", judgePlayerAlias]];

                for (Player *p in self.match.players) {
                    
                    if ([p.playerId isEqualToString:judgePlayerId]) {
                        
                        if (selfState == PLAYER_STATE_ALIVE) {
                            
                            [self performSelector:@selector(callMorningOutViewWithPlayerImage:) withObject:p.playerImage afterDelay:1.0f];
                            
                        }else {
                            
                            [self performSelector:@selector(callMorningOutViewWithPlayerImage:) withObject:p.playerImage afterDelay:1.0f];
                        }
                    }
                }
            }
            
            for (Player *p in self.match.players) {
                
                if ([p.playerId isEqualToString:judgePlayerId]) {
                    
                    p.playerState = PLAYER_STATE_DEAD;
                    
                    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:p.playerId]) {
                        
                        selfState = PLAYER_STATE_DEAD;
                        [self.confirmVoteButton setTitle:@"離開遊戲" forState:UIControlStateNormal];

                        [self.playerStateBtn setTitle:@"出局" forState:UIControlStateNormal];
                        [self.playerStateBtn setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:33.0f/255.0f blue:72.0f/255.0f alpha:1] forState:UIControlStateNormal];
                    }
                    
                    break;
                }
            }
        }
        [[NetworkController sharedInstance] setGameState:GameStateShowJudgementResults];
    }
}

- (void)judgePlayer:(NSString *)playerId {
    
    dayResults = [NSMutableArray new];
    
    if ([playerId isEqualToString:@"noOne"]) {
        
        noOneToJudge = true;
        
        [dayResults addObject:@"依據投票結果,沒有人被送上審判台"];
    
    }else {
        
        judgePlayerId = playerId;
        
        noOneToJudge = false;
        
        if ([[GKLocalPlayer localPlayer].playerID isEqualToString:playerId]) {
            
            [dayResults addObject:@"依據投票結果,你被送上了審判台"];

        }else {
            
            for (Player *p in self.match.players) {
                
                if ([p.playerId isEqualToString:playerId]) {
                    
                    [dayResults addObject:[NSString stringWithFormat:@"依據投票結果,%@被送上了審判台", p.alias]];
                    break;
                }
            }
        }
    }
    //TODO:[self showJudgePlayerAnimation:p.playerImage];

    [[NetworkController sharedInstance] setGameState:GameStateShowDayResults];
}


- (void)playerHasLastWords:(NSString *)lastWords withPlayerId:(NSString *)playerId {
    
    if ([NetworkController sharedInstance].gameState == GameStateNightDiscussion ||
        [NetworkController sharedInstance].gameState == GameStateNightVote ||
        [NetworkController sharedInstance].gameState == GameStateShowNightResults) {
        
        for (Player *p in self.match.players) {
        
            if ([p.playerId isEqualToString:playerId]) {
            
                [nightResultsForAll addObject:@"很不幸的有人看不見今天的太陽"];
                [nightResultsForAll addObject:[NSString stringWithFormat:@"%@憑空消失,旁邊卻多了一顆方塊", p.alias]];

                if ([lastWords isEqualToString:LAST_WORDS_EMPTY]) {
                
                    [nightResultsForAll addObject:[NSString stringWithFormat:@"%@沒有留下任何線索", p.alias]];
                    
                    if (p.playerTeam == PLAYER_TEAM_MAFIA) {
                        
                        [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的魔方是%@", p.alias, PLAYER_TEAM_MAFIA_CUBE_STRING]];
                        
                    }else if (p.playerTeam == PLAYER_TEAM_SHERIFF) {
                        
                        [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的魔方是%@", p.alias, PLAYER_TEAM_SHERIFF_CUBE_STRING]];
                        
                    }else if (p.playerTeam == PLAYER_TEAM_CIVILIAN) {
                        
                        [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的魔方是%@", p.alias, PLAYER_TEAM_CIVILIAN_CUBE_STRING]];
                    }
                
                }else {
                
                    [nightResultsForAll addObject:[NSString stringWithFormat:@"我們在方塊旁,發現了%@留下的的的線索", p.alias]];
                    [nightResultsForAll addObject:[NSString stringWithFormat:@"上面寫道:%@", lastWords]];
                
                    if (p.playerTeam == PLAYER_TEAM_MAFIA) {
                    
                        [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的魔方是%@", p.alias, PLAYER_TEAM_MAFIA_CUBE_STRING]];
                    
                    }else if (p.playerTeam == PLAYER_TEAM_SHERIFF) {
                    
                        [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的魔方是%@", p.alias, PLAYER_TEAM_SHERIFF_CUBE_STRING]];
                    
                    }else if (p.playerTeam == PLAYER_TEAM_CIVILIAN) {
                    
                        [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的魔方是%@", p.alias, PLAYER_TEAM_CIVILIAN_CUBE_STRING]];
                    }
                }
                [self.playerListTableView reloadData];
                [self showPlayerList];
                
                break;
            }
        }
        [self switchToNextGameState];
        
    }else if ([NetworkController sharedInstance].gameState == GameStateJudgementDiscussion ||
              [NetworkController sharedInstance].gameState == GameStateJudgementVote ||
              [NetworkController sharedInstance].gameState == GameStateShowJudgementResults) {
        
        NSString *judgePlayerAlias = [NSString new];
        Player *judgePlayer = [Player new];
        
        for (Player *p in self.match.players) {
            
            if ([p.playerId isEqualToString:judgePlayerId]) {
                
                judgePlayerAlias = p.alias;
                judgePlayer = p;
            }
        }
            
        if ([lastWords isEqualToString:LAST_WORDS_EMPTY]) {
                
            [self showSystemMessage:[NSString stringWithFormat:@"%@突然消失了,什麼線索都沒留下", judgePlayerAlias]];
                    
        }else {
            
            [self showSystemMessage:[NSString stringWithFormat:@"%@的線索上面寫道:%@", judgePlayerAlias, lastWords]];
            
            if (judgePlayer.playerTeam == PLAYER_TEAM_MAFIA) {
                
                [self performSelector:@selector(showSystemMessage:) withObject:[NSString stringWithFormat:@"%@的魔方是%@", judgePlayerAlias, PLAYER_TEAM_MAFIA_CUBE_STRING] afterDelay:1.5f ];
                
            }else if (judgePlayer.playerTeam == PLAYER_TEAM_SHERIFF) {
                
                [self performSelector:@selector(showSystemMessage:) withObject:[NSString stringWithFormat:@"%@的魔方是%@", judgePlayerAlias, PLAYER_TEAM_SHERIFF_CUBE_STRING] afterDelay:1.5f ];
                
            }else if (judgePlayer.playerTeam == PLAYER_TEAM_CIVILIAN) {
                
                [self performSelector:@selector(showSystemMessage:) withObject:[NSString stringWithFormat:@"%@的魔方是%@", judgePlayerAlias, PLAYER_TEAM_CIVILIAN_CUBE_STRING] afterDelay:1.5f ];
            }
        }
        [self.playerListTableView reloadData];
        [self showPlayerList];
        
        //check for gameOver
        if (gameOverResult == NOT_OVER_YET) {
            
            [self performSelector:@selector(switchToGameStateNightStart) withObject:self afterDelay:3.0f];
            
        }else if (gameOverResult == MAFIA_WIN) {
            
            [self performSelector:@selector(switchToGameStateGameOver) withObject:self afterDelay:3.0f];

        }else if (gameOverResult == CIVILIAN_WIN) {
            
            [self performSelector:@selector(switchToGameStateGameOver) withObject:self afterDelay:3.0f];
        }
    }
}

- (void)playerDisconnected:(NSString *)playerId willShutDown:(int)willShutDown {
    
    if (willShutDown == NOT_SHUTTING_DOWN) {
    
        NSString *systemMessgae = @"離開了遊戲";
        NSArray *tmpChatArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", playerId],systemMessgae, nil];
        [chatData addObject:tmpChatArray];
        
        [self.chatBoxTableView reloadData];
        //scroll to bottom
        NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
        [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
        
    }else if (willShutDown == SHUTTING_DOWN) {
        
        for (Player *p in self.match.players) {
            
            if ([p.playerId isEqualToString:playerId]) {
                
                [self showBackToMenuAlertWithTitle:[NSString stringWithFormat:@"很遺憾, %@離開了遊戲", p.alias]];
            }
        }
    }
}

- (void)gameOver:(int)whoWins {
    
    if (whoWins == NOT_OVER_YET) {
        
        NSLog(@"NOT_OVER_YET");
        gameOverResult = NOT_OVER_YET;
        
    }else if (whoWins == MAFIA_WIN) {
        
        NSLog(@"MAFIA_WIN");
        gameOverResult = MAFIA_WIN;
        
    }else if (whoWins == CIVILIAN_WIN) {
     
        NSLog(@"CIVILIAN_WIN");
        gameOverResult = CIVILIAN_WIN;
    }
}

- (void)gameStateChanged:(GameState)gameState {
    
    switch(gameState) {
            
        case GameStateNotInGame:
            [self.gameStateBtn setTitle:@"NotInGame" forState:UIControlStateNormal];

            break;
            
        case GameStateGameStart:
            [self.gameStateBtn setTitle:@"遊戲開始" forState:UIControlStateNormal];
            
            //initialize dayCount;
            dayCount = 1;

            //gameStartAnimation
            
            //hello
            [self showSystemMessage:@"Hello everyone, 歡迎來到遊戲!"];
            
            //showSystemMessage
            [self performSelector:@selector(showSystemMessage:) withObject:[NSString stringWithFormat:@"Day %d: 這是個風和日麗的一天", dayCount] afterDelay:1.5f];
            
            //update dayCountLabel
            [self.dayCountBtn setTitle:[NSString stringWithFormat:@"Day %d", dayCount] forState:UIControlStateNormal];
            
            //slotMachineAnimation
            [self callSlotMachineWithOutputIndex:selfTeam];
            
            break;
            
        case GameStateNightStart:
            [self.gameStateBtn setTitle:@"月黑風高" forState:UIControlStateNormal];
            
            //nightBeginAnimation
            [self showNightBackgroundImage];
            
            //showSystemMessage
            [self showSystemMessage:[NSString stringWithFormat:@"Night %d: 夜晚降臨", dayCount]];
            
            //update dayCountLabel
              [self.dayCountBtn setTitle:[NSString stringWithFormat:@"Night %d", dayCount] forState:UIControlStateNormal];
            
            //disable Vote
            selfShouldUpdateVote = false;
            selfShouldSendVote = false;
            selfShouldVote = false;
            selfShouldSeeVote = false;
            [self.playerListTableView reloadData];
            
            //hide judgementVoteView
            self.judgementVoteView.hidden = true;
            [self hidePlayerList];
            //hide confirmButton
            [self hideConfirmBtn];
            
            break;
            
        case GameStateNightDiscussion:
            [self.gameStateBtn setTitle:@"討論階段" forState:UIControlStateNormal];
            
            [[NetworkController sharedInstance] sendStartDiscussion];
    
            if (selfState == PLAYER_STATE_ALIVE) {
                
                if (selfTeam == PLAYER_TEAM_MAFIA) {
                    
                    [self showSystemMessage:@"您可以開始討論及選擇將封印對象"];
                    
                }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
                    
                    [self showSystemMessage:@"您可以開始選擇需探索的對象"];
                    
                }else if (selfTeam == PLAYER_TEAM_CIVILIAN) {
                    
                    [self showSystemMessage:@"您不安的在家中等待天明"];
                }
                
            }else {
                
                [self showSystemMessage:@"請稍候玩家執行能力"];
            }

            //allowTeamChat & deadChat
            if (selfState == PLAYER_STATE_ALIVE) {

                if (selfTeam == PLAYER_TEAM_MAFIA) {
                    
                    selfChatType = ChatToTeam;
                    self.chatTextField.enabled = true;
                    [self changeChatConditionButtonImage:CHAT_TO_TEAM_IMAGE];
                }
                
            }else {
                
                selfChatType = ChatToDead;
                self.chatTextField.enabled = true;
                [self changeChatConditionButtonImage:CHAT_TO_DEAD_IMAGE];
            }
            
            //allow Receive/Send Vote
            if (selfState == PLAYER_STATE_ALIVE) {

                if (selfTeam == PLAYER_TEAM_MAFIA) {
                    
                    selfShouldUpdateVote = true;
                    selfShouldSendVote = true;
                    
                }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
                    
                    selfShouldUpdateVote = false;
                    selfShouldSendVote = false;
                    
                }else {
                    
                    selfShouldUpdateVote = false;
                    selfShouldSendVote = false;
                }
                
            }else {
                
                selfShouldUpdateVote = false;
                selfShouldSendVote = false;
            }
            
            //resetVote
            [self resetVote];

            [self.playerListTableView reloadData];
            
            break;
            
        case GameStateNightVote:
            [self.gameStateBtn setTitle:@"投票階段" forState:UIControlStateNormal];

            //showSystemMessage
            if (selfState == PLAYER_STATE_ALIVE) {
                
                if (selfTeam == PLAYER_TEAM_MAFIA) {
                    
                    [self showSystemMessage:@"請確認選擇"];
                
                }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
                    
                    [self showSystemMessage:@"請確認選擇"];
                }
                
            }else {
                
                [self showSystemMessage:@"請稍後玩家確認選擇"];
            }
            
            //allow confirm
            if (selfShouldVote == true ||
                selfState == PLAYER_STATE_DEAD) {
                
                self.confirmVoteButton.enabled = true;
                
            }else {
                
                self.confirmVoteButton.enabled = false;
            }
            
            break;
            
        case GameStateShowNightResults:
            [self.gameStateBtn setTitle:@"最後結果" forState:UIControlStateNormal];
            
            //disable chat
            self.chatTextField.enabled = false;
            [self changeChatConditionButtonImage:CHAT_TO_NON_IMAGE];

            //showNightResults
            if (nightResults.count != 0) {
                
                interval = 1.5f;
                
                for (NSString *result in nightResults) {
                    
                    [self performSelector:@selector(showSystemMessage:) withObject:result afterDelay:interval];
                    
                    interval += 1.5f;
                }
            }
            //clear nightResults
            nightResults = [NSMutableArray new];
            
            if (waitForLastWords == false) {
                
                [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:interval];
            }
            
            break;
            
        case GameStateDayStart:
            [self.gameStateBtn setTitle:@"東曦既駕" forState:UIControlStateNormal];
            
            //dayBeginAnimation
            [self showDayBackgroundImage];
            
            //update dayCount
            dayCount++;
            
            //showSystemMessage
            [self showSystemMessage:[NSString stringWithFormat:@"Day %d: 太陽升起,白天到來", dayCount]];
            
            //update dayCountLabel
            [self.dayCountBtn setTitle:[NSString stringWithFormat:@"Day %d", dayCount] forState:UIControlStateNormal];
            
            //disable Vote
            selfShouldUpdateVote = false;
            selfShouldSendVote = false;
            selfShouldVote = false;
            selfShouldSeeVote = false;
            [self.playerListTableView reloadData];
            
            //showNightResultForAll
            if (nightResultsForAll.count != 0) {
                
                interval = 1.5f;

                for (NSString *result in nightResultsForAll) {
                    
                    [self performSelector:@selector(showSystemMessage:) withObject:result afterDelay:interval];
                    
                    interval += 1.5f;
                }
            }
            //clear nightResultsForAll
            nightResultsForAll = [NSMutableArray new];
            
            //check for gameOver
            if (gameOverResult == NOT_OVER_YET) {
                
                [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:interval];
                
            }else if (gameOverResult == MAFIA_WIN) {
                
                [self performSelector:@selector(switchToGameStateGameOver) withObject:self afterDelay:interval];
                
            }else if (gameOverResult == CIVILIAN_WIN) {
                
                [self performSelector:@selector(switchToGameStateGameOver) withObject:self afterDelay:interval];
            }
            
            break;
            
        case GameStateDayDiscussion:
            [self.gameStateBtn setTitle:@"討論階段" forState:UIControlStateNormal];
            
            [[NetworkController sharedInstance] sendStartDiscussion];
            
            [self showSystemMessage:@"所有人可以開始討論及選擇對象"];
            
            //allowChatToAll & chatToDead
            if (selfState == PLAYER_STATE_ALIVE) {

                selfChatType = ChatToAll;
                self.chatTextField.enabled = true;
                [self changeChatConditionButtonImage:CHAT_TO_ALL_IMAGE];
                
            }else {
                
                selfChatType = ChatToDead;
                self.chatTextField.enabled = true;
                [self changeChatConditionButtonImage:CHAT_TO_DEAD_IMAGE];
            }
            
            //allow Receive/Send Vote
            if (selfState == PLAYER_STATE_ALIVE) {

                selfShouldUpdateVote = true;
                selfShouldSendVote = true;
                
            }else {
                
                selfShouldUpdateVote = true;
                selfShouldSendVote = false;
            }
            
            //resetVote
            [self resetVote];
            
            [self.playerListTableView reloadData];
            
            break;
            
        case GameStateDayVote:
            [self.gameStateBtn setTitle:@"投票階段" forState:UIControlStateNormal];
            
            //showSystemMessage
            [self showSystemMessage:@"所有人請確認選擇"];
            
            //allow confirm
            if (selfShouldVote == true ||
                selfState == PLAYER_STATE_DEAD) {
                
                self.confirmVoteButton.enabled = true;
                
            }else {
                
               self.confirmVoteButton.enabled = false;
            }
            
            break;
            
        case GameStateShowDayResults:
            [self.gameStateBtn setTitle:@"最後結果" forState:UIControlStateNormal];
            
            //disable chat
            self.chatTextField.enabled = false;
            [self changeChatConditionButtonImage:CHAT_TO_NON_IMAGE];

            //showDayResults
            if (dayResults.count != 0) {
                
                interval = 1.5f;
                
                for (NSString *result in dayResults) {
                    
                    [self performSelector:@selector(showSystemMessage:) withObject:result afterDelay:interval];
                    
                    interval += 1.5f;
                }
            }
            //clear dayResults
            dayResults = [NSMutableArray new];
            
            if (noOneToJudge == false) {

                [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:interval];
                
            }else {
                
                [self performSelector:@selector(switchToGameStateNightStart) withObject:self afterDelay:interval];
            }
            
            break;
            
        case GameStateJudgementDiscussion:
            [self.gameStateBtn setTitle:@"討論階段" forState:UIControlStateNormal];
            
            [[NetworkController sharedInstance] sendStartDiscussion];
            
            [self showSystemMessage:@"審判開始,所有人可以開始質詢及投票"];
       
            //allowChatToAll & chatToDead
            if (selfState == PLAYER_STATE_ALIVE) {

                selfChatType = ChatToAll;
                self.chatTextField.enabled = true;
                [self changeChatConditionButtonImage:CHAT_TO_ALL_IMAGE];

                
            }else {
                
                selfChatType = ChatToDead;
                self.chatTextField.enabled = true;
                [self changeChatConditionButtonImage:CHAT_TO_DEAD_IMAGE];

            }
            
            //disable Vote
            selfShouldUpdateVote = false;
            selfShouldSendVote = false;
            selfShouldVote = false;
            selfShouldSeeVote = false;
            [self.playerListTableView reloadData];
            
            //hide playerList
            [self hidePlayerList];
         
            //allow Receive/Send Vote
            if (selfState == PLAYER_STATE_ALIVE) {

                selfShouldUpdateVote = true;
                selfShouldSendVote = true;
                
            }else {
                
                selfShouldUpdateVote = true;
                selfShouldSendVote = false;
            }
            
            //resetVote
            
            [self resetVote];
            
            if (selfState == PLAYER_STATE_ALIVE) {
                
                if ([[GKLocalPlayer localPlayer].playerID isEqualToString:judgePlayerId]) {
                    
                    self.guiltyButton.userInteractionEnabled = false;
                    self.innocentButton.userInteractionEnabled = false;
                    
                }else {
                    
                    self.guiltyButton.userInteractionEnabled = true;
                    self.innocentButton.userInteractionEnabled = true;
                }
                
            }else {
                
                self.guiltyButton.userInteractionEnabled = false;
                self.innocentButton.userInteractionEnabled = false;
            }

            break;
            
        case GameStateJudgementVote:
             [self.gameStateBtn setTitle:@"投票階段" forState:UIControlStateNormal];

            //showSystemMessage
            [self showSystemMessage:@"所有人請確認投票"];
            
            //allow confirm
            if (selfShouldVote == true ||
                selfState == PLAYER_STATE_DEAD) {
                
                self.confirmVoteButton.enabled = true;
            }else
            {
                self.confirmVoteButton.enabled = false;
            }
            
            break;
            
        case GameStateShowJudgementResults:
             [self.gameStateBtn setTitle:@"ShowJudgementResults" forState:UIControlStateNormal];
            
            //disable chat
            self.chatTextField.enabled = false;
            [self changeChatConditionButtonImage:CHAT_TO_NON_IMAGE];

            //showjudgementResults
            if (judgementResults.count != 0) {
                
                interval = 1.5f;
                
                for (NSString *result in judgementResults) {
                    
                    [self performSelector:@selector(showSystemMessage:) withObject:result afterDelay:interval];
                    
                    interval += 1.5f;
                }
            }
            //clear judgementResults
            judgementResults = [NSMutableArray new];
            
            if (waitForLastWords == false) {
                
                [self performSelector:@selector(switchToGameStateNightStart) withObject:self afterDelay:interval];
            }

            break;
            
        case GameStateGameOver:
            [self.gameStateBtn setTitle:@"遊戲結束" forState:UIControlStateNormal];
            
            //gameOverAnimation
            if (gameOverResult == MAFIA_WIN) {
                
                //TODO:[self showGameOverAnimationWithWhoWins:MAFIA_WIN];

            }else if (gameOverResult == CIVILIAN_WIN) {
                
                //TODO:[self showGameOverAnimationWithWhoWins:CIVILIAN_WIN];
            }
            
            //showSystemMessage
            if (gameOverResult == MAFIA_WIN) {
                
                [self showSystemMessage:@"遊戲結束,新的主宰世界的力量,誕生了,我們將臣服於新的王者"];
                
            }else if (gameOverResult == CIVILIAN_WIN) {
                
                [self showSystemMessage:@"遊戲結束,日子又平安的過去,感謝各路英雄的努力,成功的守護住我們的地球"];
            }
            [self performSelector:@selector(showSystemMessage:) withObject:[NSString stringWithFormat:@"英雄們可以留下來互相交流,遊戲將在一分鐘後結束"] afterDelay:1.5f];

            //hide judgementVoteView
            self.judgementVoteView.hidden = true;
            
            //allowAllChat
            selfChatType = ChatToAll;
            [self performSelector:@selector(enableChatTextField) withObject:nil afterDelay:1.5f];
            [self performSelector:@selector(changeChatConditionButtonImage:) withObject:CHAT_TO_ALL_IMAGE afterDelay:1.5f];
            

            //show all playerTeam
            [self.playerListTableView reloadData];
            
            //show showPlayerList
            [self showPlayerList];
            
            //show confirmButton
            [self.confirmVoteButton setTitle:@"離開遊戲" forState:UIControlStateNormal];
            self.confirmVoteButton.enabled = true;
            [self showConfirmBtn];

            break;
    }
}

@end
