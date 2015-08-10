//
//  TestGameViewController.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "TestGameViewController.h"
#import "MenuViewController.h"
#import "Match.h"
#import "Player.h"
#import "testVoteTableViewCell.h"

@interface TestGameViewController () <NetworkControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UITableView *testVoteTabelView;
@property (weak, nonatomic) IBOutlet UITableView *testChatTableView;

@end

@implementation TestGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
}

- (void)updateVoteFor:(int)voteFor fromVotedFor:(int)votedFor withPlayerId:(NSString *)playerId {
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.testVoteTabelView) {
        
        return self.match.players.count;
        
    }else if (tableView == self.testChatTableView) {
        
        return 0;
        
    }else {
        
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.testVoteTabelView) {
        
        testVoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testVoteTableViewCell" forIndexPath:indexPath];
        
        Player *p = [self.match.players objectAtIndex:indexPath.row];
        
        cell.playerNumberLabel.text = [NSString stringWithFormat:@"Player%ld:",indexPath.row+1];
        cell.playerNameLabel.text = p.alias;
        
        return cell;
        
    }else if (tableView == self.testChatTableView) {
        
        UITableViewCell *cell = [UITableViewCell new];
        
        return cell;
    }else {
        
        return nil;
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
