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

@interface playerInfoViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *ImagePicker;
    CGRect originalFrame ;
}

@property (strong, nonatomic) IBOutlet cropView *crop;
@property (strong,nonatomic) UIImageView *scan;
@end

@implementation playerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //stop auto lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
  
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
        
        if(finished) {
            
            [self slide];
        }
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
    UIImage *fullAppearanceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(_crop.sendHeadImageView.bounds.size);
    [_crop.sendHeadImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *modifyImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 250,250)];
    modifyImage.backgroundColor=[UIColor clearColor];
    modifyImage.image = myImage;
    modifyImage.contentMode =UIViewContentModeTop;
    UIGraphicsBeginImageContext(modifyImage.bounds.size);
    [modifyImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *headImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    [self.delegate transFullAppearanceImage:fullAppearanceImage withHeadImage:headImage];

    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

@end
