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

#define INPUT_BAR_HEIGHT 60
#define SYSTEM_ID @"SYSTEM"
#define SYSTEM_IMAGE @"Batman.png"




@interface ViewController () <NetworkControllerDelegate, UITableViewDelegate, UITableViewDataSource,NSStreamDelegate, UITextFieldDelegate> {
    
    UIView *inputBar;
    CGRect originframeChatBox;
    struct CGColor *oringincolorChatBox;
    
    NSMutableArray *playerDragImageViewArray;
    
    NSMutableArray *chatData;
    NSMutableArray *voteData;
    int selfVoteFor;
    
     BOOL firstTime;
    SlotMachine *SlotVc ;
}

@property (weak, nonatomic) IBOutlet UITableView *chatBoxTableView;
@property (weak, nonatomic) IBOutlet UITableView *playerListTableView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *extraBtn;
@property (weak, nonatomic) IBOutlet UIView *thePlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (nonatomic, strong) TransitionDelegate *transitionController;


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
    
    //////
    
    self.playerListTableView.delegate=self;
    self.playerListTableView.dataSource=self;
    self.backgroundImg.image=[UIImage imageNamed:@"play7.jpg"];

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
    
    //network
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
    
    //hello
    NSArray *tmpChatArray = [NSArray arrayWithObjects:SYSTEM_ID, @"Hello everyone, 歡迎來到遊戲!", nil];
    [chatData addObject:tmpChatArray];
    
    [self.chatBoxTableView reloadData];

    NSIndexPath* chatip = [NSIndexPath indexPathForRow:chatData.count-1 inSection:0];
    [self.chatBoxTableView scrollToRowAtIndexPath:chatip atScrollPosition:UITableViewScrollPositionBottom animated:true];
    
    
    
    /////slotMachine
    SlotVc = [[SlotMachine alloc]init];
    self.transitionController = [[TransitionDelegate alloc] init];
    firstTime=YES;
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    [self callSlotMachine];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)callSlotMachine{
    if(firstTime){
        
        SlotVc = [self.storyboard instantiateViewControllerWithIdentifier:@"slotMachine"];
        SlotVc.view.backgroundColor = [UIColor clearColor];
        [SlotVc setTransitioningDelegate:_transitionController];
        SlotVc.modalPresentationStyle= UIModalPresentationCustom;
        [self presentViewController:SlotVc animated:YES completion:nil];
        firstTime=NO;
    }
}


-(void)keyboardWillChangeFrame:(NSNotification*)notify{

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

- (void)performTransition:(UIViewAnimationOptions)options{
    
    static int count = 0;
    NSArray *animationImages = @[[UIImage imageNamed:@"play6.jpg"], [UIImage imageNamed:@"play7.jpg"]];
    UIImage *image = [animationImages objectAtIndex:(count % [animationImages count])];
    
    [UIView transitionWithView:self.backgroundImg
                      duration:1.0f // animation duration
                       options:options
                    animations:^{
                        self.backgroundImg.image = image; // change to other image
                    } completion:^(BOOL finished) {
                        [self backgroundImg]; // once finished, repeat again
                        count++; // this is to keep the reference of which image should be loaded next
                    }];
}

- (IBAction)finalSelectBtnPressed:(id)sender {
    
    [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
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
        [[NetworkController sharedInstance] sendChat:chat withChatType:ChatToAll];
    }
    //隱藏鍵盤
    [self.view endEditing:TRUE];
    self.chatTextField.text = nil;
}

//若點擊畫面
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:TRUE];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn Called");
    
    [self sendButtonPressed:nil];
    
    return false;
}

#pragma mark - cirleThePlayerImage

-(void)initImageView{
    
    dragImageView *tempDragImageView;
    playerDragImageViewArray = [NSMutableArray new];
    
    for (Player *player in self.match.players) {
        
        tempDragImageView = [[dragImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        tempDragImageView.image = player.playerImage;
        
        [playerDragImageViewArray addObject:tempDragImageView];
    }
}

-(void)transImage:(UIImage*)image{
    
    UIImageView *testView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 400, 400)];
    testView.image=image;
    [self.view addSubview:testView];
}

-(void)fromCircleView{
    
    circleView *circle =[[circleView alloc]initWithFrame:CGRectMake(0, 0, self.thePlayerView.frame.size.width, self.thePlayerView.frame.size.height)];
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

    if (tableView == self.playerListTableView) {

        //TODO:check if vote for self or not
        
        //for other players
        [[NetworkController sharedInstance] sendVoteFor:(int)indexPath.row];
        
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
            [self dismissViewControllerAnimated:self completion:nil];
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

@end
