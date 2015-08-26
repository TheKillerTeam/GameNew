//
//  playerInfoViewController.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/28.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "playerInfoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "cropView.h"
#import "ViewController.h"
#import "NetworkController.h"

@interface playerInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, NetworkControllerDelegate>
{
    UIImagePickerController *ImagePicker;
    CGRect originalFrame ;
    
    
}

@property (strong, nonatomic) IBOutlet cropView *crop;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (strong,nonatomic) UIImageView *scan;
@end

@implementation playerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //stop auto lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
  
    
    self.crop = [[cropView alloc]initWithFrame:CGRectMake(0, 119, self.view.frame.size.width,self.view.frame.size.height-120)];
    [self.view addSubview:_crop];
    
    self.scan =[[UIImageView alloc]initWithFrame:CGRectMake(-10000,0 , 10000, 120)];
    UIImage *image= [UIImage imageNamed:@"scan2.png"];
    [_scan setImage:image];
    originalFrame=_scan.frame;
    [self.view insertSubview:_scan atIndex:0];
    
    UIImageView *fillView1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15,  50, 30)];
    fillView1.image =[UIImage imageNamed:@"scan1.png"];
    fillView1.alpha=0.5;
    UIImageView *fillView2 = [[UIImageView alloc]initWithFrame:CGRectMake(110, 15,  50, 30)];
    fillView2.image =[UIImage imageNamed:@"scan1.png"];
    fillView2.alpha=0.5;
    UIImageView *fillView3 = [[UIImageView alloc]initWithFrame:CGRectMake(210, 15,  50, 30)];
    fillView3.image =[UIImage imageNamed:@"scan1.png"];
    fillView3.alpha=0.5;
    UIImageView *fillView4 = [[UIImageView alloc]initWithFrame:CGRectMake(290, 15,  50, 30)];
    fillView4.image =[UIImage imageNamed:@"scan1.png"];
    fillView4.alpha=0.5;
    [self.view insertSubview:fillView1 atIndex:1];
    [self.view insertSubview:fillView2 atIndex:2];
    [self.view insertSubview:fillView3 atIndex:3];
    [self.view insertSubview:fillView4 atIndex:4];
  
    [self slide];

    
    
}


-(void)slide{
  
    _scan.frame=originalFrame;
    
    [UIView animateWithDuration:5.0f animations:^{

        CGRect finalPosition = _scan.frame;
        finalPosition.origin.x =self.view.frame.size.width;
        finalPosition.origin.y =10;
        _scan.frame=finalPosition;
        

        
    }completion:^(BOOL finished){
        if(finished)
            [self slide];
    }];
    
    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self slide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(id)sender {
    
    ImagePicker = [UIImagePickerController new];
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertController *alert =[UIAlertController alertControllerWithTitle:nil message:@"The deviece dosen't support" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok =[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    ImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    ImagePicker.showsCameraControls=true;
    ImagePicker.delegate=self;
  
     [self presentViewController:ImagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    _crop.image = chosenImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)album:(id)sender {
    
    ImagePicker=[UIImagePickerController new];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    ImagePicker.sourceType = sourceType;

    ImagePicker.delegate=self;
   
     [self presentViewController:ImagePicker animated:YES completion:NULL];
}

- (IBAction)nextButton:(id)sender {
    
    UIGraphicsBeginImageContext(_crop.sentView.bounds.size);
    [_crop.sentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    [self.delegate transImage:myImage];

    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - NetworkControllerDelegate

- (void)networkStateChanged:(NetworkState)networkState {
    
    switch(networkState) {
            
        case NetworkStateNotAvailable:
            
            _debugLabel.text = @"Not Available";
            break;
            
        case NetworkStatePendingAuthentication:
            
            _debugLabel.text = @"Pending Authentication";
            break;
            
        case NetworkStateAuthenticated:
            
            _debugLabel.text = @"Authenticated";
            break;
            
        case NetworkStateConnectingToServer:
            
            _debugLabel.text = @"Connecting to Server";
            break;
            
        case NetworkStateConnected:
            
            _debugLabel.text = @"Connected";
            break;
            
        case NetworkStatePendingMatchStatus:
            
            _debugLabel.text = @"Pending Match Status";
            break;
            
        case NetworkStateReceivedMatchStatus:
            
            _debugLabel.text = @"Received Match Status,\nReady to Look for a Match";
            break;
            
        case NetworkStatePendingMatch:
            
            _debugLabel.text = @"Pending Match";
            break;
            
        case NetworkStatePendingMatchStart:
            
            _debugLabel.text = @"Pending Start";
            break;
            
        case NetworkStateMatchActive:
            
            _debugLabel.text = @"Match Active";
            break;
    }
}

- (void)matchStarted:(Match *)match {
    
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

- (void)gameOver:(int)whoWins {
    
}

@end
