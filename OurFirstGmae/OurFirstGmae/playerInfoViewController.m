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
    
}
@property (weak, nonatomic) IBOutlet UIImageView *playPhoto;
@property (weak, nonatomic) IBOutlet cropView *crop;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;

@end

@implementation playerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    _crop.layer.borderWidth=1.0;
    _crop.layer.borderColor=[UIColor redColor].CGColor;
    
    [_crop step];
    
    [NetworkController sharedInstance].delegate = self;
    [self networkStateChanged:[NetworkController sharedInstance].networkState];
}

- (void)viewDidAppear:(BOOL)animated {

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
//    self.playPhoto.image = chosenImage;
    _crop.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)album:(id)sender {
    
    ImagePicker=[UIImagePickerController new];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    ImagePicker.sourceType = sourceType;

    ImagePicker.delegate=self;
    [_crop step];
   
     [self presentViewController:ImagePicker animated:YES completion:NULL];
}

- (IBAction)nextButton:(id)sender {
    
    UIGraphicsBeginImageContext(_crop.bounds.size);
    [_crop.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.delegate transImage:myImage];

    [self dismissViewControllerAnimated:true completion:nil];
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

@end
