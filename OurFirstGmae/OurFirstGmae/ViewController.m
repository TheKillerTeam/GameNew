//
//  ViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/17.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

//TODO:check all conditions with dead player

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
#define SYSTEM_ID @"SYSTEM"
#define SYSTEM_IMAGE @"Batman.png"

#define BACKGROUND_IMAGE_DAY @"play7.jpg"
#define BACKGROUND_IMAGE_NIGHT @"play6.jpg"

#define PLAYER_TEAM_CIVILIAN    0
#define PLAYER_TEAM_SHERIFF     1
#define PLAYER_TEAM_MAFIA       2

#define PLAYER_TEAM_CIVILIAN_STRING @"平民"
#define PLAYER_TEAM_SHERIFF_STRING  @"警察"
#define PLAYER_TEAM_MAFIA_STRING    @"殺手"

#define PLAYER_STATE_ALIVE  0
#define PLAYER_STATE_DEAD   1

#define VOTE_MINIMUM_TIME_INTERVAL 0.5f

#define LAST_WORDS_EMPTY @"LAST_WORDS_EMPTY"

@interface ViewController () <NetworkControllerDelegate, UITableViewDelegate, UITableViewDataSource,NSStreamDelegate, UITextFieldDelegate> {
    
    UIView *inputBar;
    CGRect originframeChatBox;
    struct CGColor *oringincolorChatBox;
    
    NSMutableArray *playerDragImageViewArray;
    
    NSMutableArray *chatData;
    NSMutableArray *voteData;
    int selfVoteFor;
    int selfTeam;
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
    
    NSDate *lastVoteTime;
}

@property (weak, nonatomic) IBOutlet UITableView *chatBoxTableView;
@property (weak, nonatomic) IBOutlet UITableView *playerListTableView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *extraBtn;
@property (weak, nonatomic) IBOutlet UIView *thePlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameStateLabel;
@property (nonatomic, strong) TransitionDelegate *transitionController;
@property (weak, nonatomic) IBOutlet UILabel *playerTeamLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmVoteButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    ////////chatBoxTableView
    chatData = [NSMutableArray new];
    
     self.chatBoxTableView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
   
    inputBar = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY([UIScreen mainScreen].bounds)-INPUT_BAR_HEIGHT, CGRectGetWidth([UIScreen mainScreen].bounds),INPUT_BAR_HEIGHT)];
    inputBar.backgroundColor = [UIColor grayColor];
    
    [inputBar addSubview:self.chatTextField];
    [inputBar addSubview:self.sendBtn];
    [inputBar addSubview:self.extraBtn];
    inputBar.backgroundColor=[UIColor grayColor];
    [self.view addSubview:inputBar];
    
    selfChatType = ChatToAll;
    
    //////
    
    self.playerListTableView.delegate=self;
    self.playerListTableView.dataSource=self;
    self.backgroundImg.image=[UIImage imageNamed:BACKGROUND_IMAGE_DAY];

    ///////cicle
    [self initImageView];
    [self fromCircleView];
    
    //vote
    voteData = [NSMutableArray new];
    
    for (int i=0; i<self.match.players.count; i++) {
        
        NSNumber *num = [NSNumber numberWithInt:0];
        [voteData addObject:num];
    }
    selfVoteFor = 99;
    selfShouldUpdateVote = false;
    selfShouldSendVote = false;
    selfShouldVote = false;
    selfShouldSeeVote = false;
    
    //hello
    [self showSystemMessage:@"Hello everyone, 歡迎來到遊戲!"];
    
    //
    for (Player *p in self.match.players) {
        if ([p.playerId isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            
            selfTeam = p.playerTeam;
            break;
        }
    }
    
    nightResults = [NSMutableArray new];
    nightResultsForAll = [NSMutableArray new];
    
    lastVoteTime = [NSDate date];
}

- (void) viewDidAppear:(BOOL)animated {
    
    /////the other views
    SlotVc = [[SlotMachine alloc]init];
    self.transitionController = [[TransitionDelegate alloc] init];
    
    morningOutView =[MorningOutViewController new];
    nightOutView = [outView new];
    loadingView =[LoadingViewController new];
    
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

- (void)callLoadingView{

    loadingView = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    loadingView.view.backgroundColor = [UIColor blackColor];

    loadingView.modalPresentationStyle= UIModalPresentationCustom;
    [self presentViewController:loadingView animated:YES completion:nil];
    
}


-(void)callMorningOutView{

    
    morningOutView = [self.storyboard instantiateViewControllerWithIdentifier:@"morningOutView"];
    morningOutView.view.backgroundColor = [UIColor clearColor];
    [morningOutView setTransitioningDelegate:_transitionController];
    morningOutView.modalPresentationStyle= UIModalPresentationCustom;
    [self presentViewController:morningOutView animated:YES completion:nil];
}


- (void)callNightOutViewWithPlayerImage:(UIImage *)playerImage{

    nightOutView = [self.storyboard instantiateViewControllerWithIdentifier:@"nightOutView"];
    
    nightOutView.playerImage = playerImage;
    
    nightOutView.view.backgroundColor = [UIColor clearColor];
    [nightOutView setTransitioningDelegate:_transitionController];
    nightOutView.modalPresentationStyle= UIModalPresentationCustom;
    
    [self presentViewController:nightOutView animated:YES completion:^{
        
        [self performSelector:@selector(dismissNightOutView) withObject:self afterDelay:5];
    }];
    
}

- (void)keyboardWillChangeFrame:(NSNotification*)notify{

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

- (IBAction)extraBtnPressed:(id)sender {
    
}

- (void)switchDayNightBackgroundImage{
    
    [UIView transitionWithView:self.backgroundImg
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundImg.image =
                        [UIImagePNGRepresentation(self.backgroundImg.image) isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:BACKGROUND_IMAGE_DAY])]?
                        [UIImage imageNamed:BACKGROUND_IMAGE_NIGHT]:
                        [UIImage imageNamed:BACKGROUND_IMAGE_DAY];
                    }
                    completion:^(BOOL finished) {
                        //changeGameState
                        [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:1];
                    }
     ];
}

- (IBAction)confirmVoteButtonPressed:(id)sender {
    
    selfShouldVote = false;
    [self.playerListTableView reloadData];
    
    [self processVoteResult];
    self.confirmVoteButton.enabled = false;
}

- (void)processVoteResult {
    
    [[NetworkController sharedInstance] sendConfirmVote];
    
    if (selfTeam == PLAYER_TEAM_MAFIA) {
        
        if (selfVoteFor != 99) {
            
            Player *playerChosen = [self.match.players objectAtIndex:selfVoteFor];
            [self showSystemMessage:[NSString stringWithFormat:@"你決定投票殺死%@", playerChosen.alias]];
            
        }else {
            
            [self showSystemMessage:@"你決定投票今晚不殺人"];
        }
        
    }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
        
        for (int i=0; i<voteData.count; i++) {
            
            if ([[voteData objectAtIndex:i] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                
                Player *playerChosen = [self.match.players objectAtIndex:i];
                [self showSystemMessage:[NSString stringWithFormat:@"你決定今晚調查%@的身份", playerChosen.alias]];
                if (playerChosen.playerTeam == PLAYER_TEAM_MAFIA) {
                    
                    [nightResults addObject:[NSString stringWithFormat:@"你發現了%@的身份是%@", playerChosen.alias, PLAYER_TEAM_MAFIA_STRING]];
                    
                }else if (playerChosen.playerTeam == PLAYER_TEAM_SHERIFF) {
                    
                    [nightResults addObject:[NSString stringWithFormat:@"你發現了%@的身份是%@", playerChosen.alias, PLAYER_TEAM_SHERIFF_STRING]];
                    
                }else if (playerChosen.playerTeam == PLAYER_TEAM_CIVILIAN) {
                    
                    [nightResults addObject:[NSString stringWithFormat:@"你發現了%@的身份是%@", playerChosen.alias, PLAYER_TEAM_CIVILIAN_STRING]];
                }
                
                return;
            }
        }
        [self showSystemMessage:@"你今晚沒有調查任何人"];
    }
}

- (IBAction)controlListBtnPressed:(id)sender {
    
    [UIView beginAnimations:@"animation1" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.playerListTableView cache:YES];
    [self.playerListTableView setTranslatesAutoresizingMaskIntoConstraints:YES];
        NSLog(@"self.playerListTableViewX=%f",self.playerListTableView.frame.origin.x);
    NSLog(@"self.playerListTableViewY=%f",self.playerListTableView.frame.origin.y);
    CGRect frame = self.playerListTableView.frame;
    
    if(frame.origin.y<0) {

        frame.origin.y =20;
        
    }else {
        
        frame.origin.y -=frame.size.height+20;
    }
    
    NSLog(@"frame=%f",frame.origin.y);
    self.playerListTableView.frame =frame;
    
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
            
            self.playerTeamLabel.text = PLAYER_TEAM_CIVILIAN_STRING;
            break;
            
        case PLAYER_TEAM_SHERIFF:
            
            self.playerTeamLabel.text = PLAYER_TEAM_SHERIFF_STRING;
            break;
            
        case PLAYER_TEAM_MAFIA:
            
            self.playerTeamLabel.text = PLAYER_TEAM_MAFIA_STRING;
            break;
            
        default:
            break;
    }
    
    //showSystemMessage
    [self showSystemMessage:@"這是個風和日麗的一天"];
    
    //changeGameState
    [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:1];
}

- (void)dismissNightOutView {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你已經死了" message:@"在你斷氣之前,你還有最後一口氣能留下遺囑" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *lastWords = [alert.textFields[0] text];
        
        if (lastWords.length == 0) {
            
            [[NetworkController sharedInstance] sendLastWords:LAST_WORDS_EMPTY];
            
        }else {
            
            [[NetworkController sharedInstance] sendLastWords:lastWords];
        }
    }];
    
    [alert addAction:done];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.placeholder = @"leave your lastwords here";
    }];
    
    [self presentViewController:alert animated:false completion:nil];
}

- (void)switchToNextGameState {
    
    GameState currentGameState = [NetworkController sharedInstance].gameState;
    [[NetworkController sharedInstance] setGameState:currentGameState+1];
}

- (void)resetVote {
    
    //for self
    NSNumber *num = [NSNumber numberWithInt:0];
    for (int i=0; i<voteData.count; i++) {
        [voteData replaceObjectAtIndex:i withObject:num];
    }
    
    //for server
    [[NetworkController sharedInstance] sendResetVote];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.chatTextField) {
        
        [self sendButtonPressed:nil];
        return false;
    }
    
    return true;
}

#pragma mark - cirleThePlayerImage

-(void)initImageView{
    
    dragImageView *tempDragImageView;
    playerDragImageViewArray = [NSMutableArray new];
    
    for (Player *player in self.match.players) {
        
        tempDragImageView = [[dragImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        tempDragImageView.backgroundColor=[UIColor clearColor];
        tempDragImageView.image = player.playerImage;
        
        [playerDragImageViewArray addObject:tempDragImageView];
    }
}

-(void)fromCircleView{
    
    circleView *circle =[[circleView alloc]initWithFrame:CGRectMake(0, 0, self.thePlayerView.frame.size.width, self.thePlayerView.frame.size.height)];
    circle.backgroundColor=[UIColor clearColor];
    circle.ImgArray  = playerDragImageViewArray;
    [self.thePlayerView addSubview:circle];
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
        
        if (selfShouldVote) {
            
            cell.userInteractionEnabled = true;
            
        }else {
            
            cell.userInteractionEnabled = false;
        }
        
        if (selfShouldSeeVote == true) {
            
            cell.vote.hidden = false;
            
        }else {
            
            cell.vote.hidden = true;
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
        CGFloat height = [text boundingRectWithSize:CGSizeMake(300, 10000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: font} context:nil].size.height;
        
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
        
        //TODO:check if vote for self or not
        //TODO:check if Mafia vote to kill teammate or not
        
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
            [[NetworkController sharedInstance] setGameState:GameStateNotInGame];
            rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            [rootVC dismissViewControllerAnimated:true completion:nil];
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

- (void)allowVote {
    
    if ([NetworkController sharedInstance].gameState == GameStateNightDiscussion ||
        [NetworkController sharedInstance].gameState == GameStateNightVote) {
        
        //allowNightVote
        if (selfTeam == PLAYER_TEAM_MAFIA) {
            
            selfShouldVote = true;
            selfShouldSeeVote = true;
            self.confirmVoteButton.enabled = true;
            
        }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
            
            selfShouldVote = true;
            selfShouldSeeVote = true;
            self.confirmVoteButton.enabled = true;
            
        }else {
            
            selfShouldVote = false;
            selfShouldSeeVote = false;
        }

    }else if ([NetworkController sharedInstance].gameState == GameStateDayDiscussion ||
              [NetworkController sharedInstance].gameState == GameStateDayVote) {
        
        //TODO:allowDayVote
    }
    [self.playerListTableView reloadData];
}

- (void)playerDied:(NSString *)playerId {
    
    if ([playerId isEqualToString:@"noOne"]) {
        
        [nightResultsForAll addObject:@"作晚月黑風高,但是所有人都平安的度過了"];

        if (selfTeam == PLAYER_TEAM_MAFIA) {
            
            [nightResults addObject:@"殺手今晚沒有殺人"];
        }
        [[NetworkController sharedInstance] setGameState:GameStateShowNightResults];
        [[NetworkController sharedInstance] setGameState:GameStateDayStart];
        
    }else {
    
        if ([[GKLocalPlayer localPlayer].playerID isEqualToString:playerId]) {
        
            [nightResults addObject:@"你在今晚不幸地被殺手殺死了"];
            
            for (Player *p in self.match.players) {
                
                if ([p.playerId isEqualToString:playerId]) {
                    
                    [self callNightOutViewWithPlayerImage:p.playerImage];
                    
                    break;
                }
            }
        }
        
        if (selfTeam == PLAYER_TEAM_MAFIA) {
        
            for (Player *p in self.match.players) {
            
                if ([p.playerId isEqualToString:playerId]) {
                
                    [nightResults addObject:[NSString stringWithFormat:@"殺手今晚前去殺掉了%@", p.alias]];
                    break;
                }
            }
        }
        
        for (Player *p in self.match.players) {
        
            if ([p.playerId isEqualToString:playerId]) {
            
                p.playerState = PLAYER_STATE_DEAD;
                break;
            }
        }
        [[NetworkController sharedInstance] setGameState:GameStateShowNightResults];
    }
}

- (void)playerHasLastWords:(NSString *)lastWords withPlayerId:(NSString *)playerId {
    
    for (Player *p in self.match.players) {
        
        if ([p.playerId isEqualToString:playerId]) {
            
            [nightResultsForAll addObject:@"很不幸的有人看不見今天的太陽"];
            [nightResultsForAll addObject:[NSString stringWithFormat:@"%@被發現陳屍於家中", p.alias]];

            if ([lastWords isEqualToString:LAST_WORDS_EMPTY]) {
                
                [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的身旁沒有留下任何遺囑", p.alias]];
                
            }else {
                
                [nightResultsForAll addObject:[NSString stringWithFormat:@"我們在%@的身旁發現了沾滿血跡的遺囑", p.alias]];
                [nightResultsForAll addObject:[NSString stringWithFormat:@"上面寫道:%@", lastWords]];
                
                if (p.playerTeam == PLAYER_TEAM_MAFIA) {
                    
                    [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的身份是%@", p.alias, PLAYER_TEAM_MAFIA_STRING]];
                    
                }else if (p.playerTeam == PLAYER_TEAM_SHERIFF) {
                    
                    [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的身份是%@", p.alias, PLAYER_TEAM_SHERIFF_STRING]];
                    
                }else if (p.playerTeam == PLAYER_TEAM_CIVILIAN) {
                    
                    [nightResultsForAll addObject:[NSString stringWithFormat:@"%@的身份是%@", p.alias, PLAYER_TEAM_CIVILIAN_STRING]];
                }
            }
            [[NetworkController sharedInstance] setGameState:GameStateDayStart];
            
            break;
        }
    }
}

- (void)gameStateChanged:(GameState)gameState {
    
    switch(gameState) {
            
        case GameStateNotInGame:
            
            self.gameStateLabel.text = @"NotInGame";
            break;
            
        case GameStateGameStart:
            
            self.gameStateLabel.text = @"GameStart";
            
            //gameStartAnimation
            
            //slotMachineAnimation
            [self callSlotMachineWithOutputIndex:selfTeam];
            
            break;
            
        case GameStateNightStart:
            
            self.gameStateLabel.text = @"NightStart";
            
            //nightBeginAnimation
            [self switchDayNightBackgroundImage];
            
            //showSystemMessage
            [self showSystemMessage:@"夜晚降臨"];
            //TODO:number of night this is
            
            break;
            
        case GameStateNightDiscussion:
            
            self.gameStateLabel.text = @"NightDiscussion";
            
            [[NetworkController sharedInstance] sendStartDiscussion];
    
            if (selfTeam == PLAYER_TEAM_MAFIA) {
                
                [self showSystemMessage:@"殺手可以開始討論及選擇對象"];
                
            }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
                
                [self showSystemMessage:@"警察可以開始選擇對象"];
                
            }else if (selfTeam == PLAYER_TEAM_CIVILIAN) {
                
                [self showSystemMessage:@"你不安的在家中等待天明"];
            }

            //allowTeamChat
            if (selfTeam == PLAYER_TEAM_MAFIA) {
                
                selfChatType = ChatToTeam;
                self.chatTextField.enabled = true;
            }
            
            //allow Receive/Send Vote
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
            
            //resetVote
            [self resetVote];

            [self.playerListTableView reloadData];
            
            //changeGameState
            [self performSelector:@selector(switchToNextGameState) withObject:self afterDelay:3];
            
            break;
            
        case GameStateNightVote:
            
            self.gameStateLabel.text = @"NightVote";
            
            //showSystemMessage
            if (selfTeam == PLAYER_TEAM_MAFIA) {
                
                [self showSystemMessage:@"殺手請確認選擇"];
                
            }else if (selfTeam == PLAYER_TEAM_SHERIFF) {
                
                [self showSystemMessage:@"警察請確認選擇"];
            }
            
            break;
            
        case GameStateShowNightResults:
            
            self.gameStateLabel.text = @"ShowNightResults";
            
            //showNightResult
            if (nightResults.count != 0) {
                
                float interval = 1.5f;
                
                for (NSString *result in nightResults) {
                    
                    [self performSelector:@selector(showSystemMessage:) withObject:result afterDelay:interval];
                    
                    interval += 1.5f;
                }
            }
            
            break;
            
        case GameStateDayStart:
            
            self.gameStateLabel.text = @"DayStart";
            
            //dayBeginAnimation
            [self switchDayNightBackgroundImage];
            
            //showSystemMessage
            [self showSystemMessage:@"太陽升起,白天到來"];
            //TODO:number of day this is

            //disable Vote
            selfShouldUpdateVote = false;
            selfShouldSendVote = false;
            selfShouldVote = false;
            selfShouldSeeVote = false;
            [self.playerListTableView reloadData];
            
            //showNightResultForAll
            if (nightResultsForAll.count != 0) {
                
                float interval = 1.5f;

                for (NSString *result in nightResultsForAll) {
                    
                    [self performSelector:@selector(showSystemMessage:) withObject:result afterDelay:interval];
                    
                    interval += 1.5f;
                }
            }
            
            //check for gameOver
            
            break;
            
        case GameStateDayDiscussion:
            
            self.gameStateLabel.text = @"DayDiscussion";
            break;
            
        case GameStateDayVote:
            
            self.gameStateLabel.text = @"DayVote";
            break;
            
        case GameStateJudgementDiscussion:
            
            self.gameStateLabel.text = @"JudgementDiscussion";
            break;
            
        case GameStateJudgementVote:
            
            self.gameStateLabel.text = @"JudgementVote";
            break;
            
        case GameStateGameOver:
            
            self.gameStateLabel.text = @"GameOver";
            break;
    }
}

@end
