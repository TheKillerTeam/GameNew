//
//  cropView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "cropView.h"


#define RADIUS 70
#define TABLEVIEW_HEIGHT 100
@implementation cropView
{
    CGFloat lastScale,lastX,lastY;
    
    UIImageView *backgroundImg;
    UIImageView *mask;
    UIImageView *hairImg;
    UIImageView *clothImage;
    UIImageView *picetureView;
    
    CGRect originClothFrame;
    CGRect originHairFrame;
    
    
    UITableView *clothFrame;
    
    NSArray *uniformArray ;
    NSArray *sentUniform;
    NSArray *hairArray;
  
    UIButton *button;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        [self step];
        
    }
    return self;
}

-(void)step{
     sentUniform =[NSArray new];
     sentUniform= @[[UIImage imageNamed:@"forPlayer1.png"],[UIImage imageNamed:@"forPlayer2.png"],[UIImage imageNamed:@"forPlayer3.png"],[UIImage imageNamed:@"forPlayer4.png"],[UIImage imageNamed:@"forPlayer5.png"],[UIImage imageNamed:@"forPlayerHair1.png"],[UIImage imageNamed:@"forPlayerHair2.png"],[UIImage imageNamed:@"forPlayerHair3.png"],[UIImage imageNamed:@"forPlayerHair4.png"],[UIImage imageNamed:@"forPlayerHair5.png"]];
    
     uniformArray = [NSArray new];
     uniformArray = @[[UIImage imageNamed:@"clothe1.png"],[UIImage imageNamed:@"clothe2.png"],[UIImage imageNamed:@"clothe3.png"],[UIImage imageNamed:@"clothe4.png"],[UIImage imageNamed:@"clothe5.png"],[UIImage imageNamed:@"hair1.png"],[UIImage imageNamed:@"hair2.png"],[UIImage imageNamed:@"hair3.png"],[UIImage imageNamed:@"hair4.png"],[UIImage imageNamed:@"hair5.png"]];

    
     backgroundImg= [[UIImageView alloc]initWithFrame:CGRectMake(-10, -5, self.frame.size.width+10,self.frame.size.height-140)];
     backgroundImg.backgroundColor=[UIColor clearColor];
     backgroundImg.image=[UIImage imageNamed:@"PlayerInfoBackground.png"];
     [self addSubview:backgroundImg];
    
    
     self.sentView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, backgroundImg.frame.size.width, backgroundImg.frame.size.height)];
     self.sentView.center =backgroundImg.center;
     self.sentView.backgroundColor=[UIColor clearColor];
     [self addSubview:_sentView];

    
     mask=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 2*RADIUS, 2*RADIUS)];
     mask.center= CGPointMake(self.frame.size.width/2+35, self.frame.size.height/2-110);
     UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100,130)];
     CAShapeLayer *maskLayer = [CAShapeLayer layer];
     maskLayer.path =path.CGPath;
     mask.layer.mask=maskLayer;
     mask.layer.backgroundColor=[UIColor whiteColor].CGColor;
     mask.userInteractionEnabled=YES;
     [_sentView addSubview:mask];
     [self.sentView setUserInteractionEnabled:YES];
    
  
    picetureView=[UIImageView new];
    picetureView.contentMode = UIViewContentModeScaleAspectFit;
    picetureView.frame = CGRectMake(0,0, 2*RADIUS ,2*RADIUS);
    picetureView.center=CGPointMake(mask.frame.size.width/2, mask.frame.size.height/2);
    picetureView.userInteractionEnabled=YES;
    [mask addSubview:picetureView];

    
    clothImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 140, 223)];
    clothImage.backgroundColor = [UIColor redColor];
    CGRect frame = clothImage.frame;
    frame.origin.y = mask.center.y+18;
    frame.origin.x = self.frame.size.width/2-50;
    clothImage.frame = frame;
    clothImage.backgroundColor=[UIColor clearColor];
    
    originClothFrame = clothImage.frame;
    [_sentView insertSubview:clothImage belowSubview:mask];
    
    
    hairImg= [[UIImageView alloc]initWithFrame:CGRectMake(0, -35, 230, 320)];
    CGRect hair =hairImg.frame;
    hair.origin.x=self.frame.size.width/2-hairImg.frame.size.width/2+10;
    hairImg.frame=hair;
    hairImg.backgroundColor=[UIColor clearColor];
    originHairFrame=hairImg.frame;
    [_sentView insertSubview:hairImg  aboveSubview:mask];

    
    
    clothFrame  = [UITableView new];
    clothFrame.backgroundColor = [UIColor clearColor];
    [clothFrame.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    clothFrame.transform = CGAffineTransformMakeRotation(M_PI/-2);
    clothFrame.showsVerticalScrollIndicator = YES;
    clothFrame.separatorColor = [UIColor blackColor];
    clothFrame.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 150);
    clothFrame.rowHeight = self.frame.size.width/4;
    NSLog(@"%f,%f,%f,%f",clothFrame.frame.origin.x,clothFrame.frame.origin.y,clothFrame.frame.size.width,clothFrame.frame.size.height);
    clothFrame.delegate = self;
    clothFrame.dataSource = self;
    [self addSubview:clothFrame];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    UIPinchGestureRecognizer *pinchGesture =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(scaleImage:)];
    [picetureView addGestureRecognizer:panGesture];
    [picetureView addGestureRecognizer:pinchGesture];
    
    
    button= [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"add" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button setFrame:CGRectMake(0, 0, 50,50)];
    [button addTarget:self action:@selector(btnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
}

-(void)setImage:(UIImage*)image1{
    picetureView.image=image1;
    
}

-(void)moveImage:(UIPanGestureRecognizer *)sender{

    CGPoint translation = [sender translationInView:mask];
    CGPoint newCenter =CGPointMake(sender.view.center.x+translation.x,
                                   sender.view.center.y + translation.y);

    if (newCenter.y >= 0 && newCenter.y <= mask.frame.size.height) {
        if(newCenter.x >= 0 && newCenter.x <= mask.frame.size.width){
            sender.view.center = newCenter;
            [sender setTranslation:CGPointZero inView:mask];
        }

    }

}
-(void)scaleImage:(UIPinchGestureRecognizer*)sender{
    
        if([sender state]==UIGestureRecognizerStateBegan){
            lastScale = 1.0;
            return;
        }
        CGFloat scale = [sender scale]/lastScale;
        CGAffineTransform currentTransform = picetureView.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
        [picetureView setTransform:newTransform];
        lastScale = [sender scale];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return uniformArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"cellID";
    clothCell *cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell ==nil){
        cell = [[clothCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if(tableView == clothFrame){
       
        UIImage *uniform = [uniformArray objectAtIndex:indexPath.row];
        cell.imageView.image = uniform;
        cell.imageView.transform=CGAffineTransformMakeRotation(M_PI/2);

      
        
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
        if(indexPath.row==0){
            clothImage.frame=originClothFrame;
            clothImage.image = sentUniform[indexPath.row];
        }else if (indexPath.row ==1){
            
            
            CGRect targetClothFrame=CGRectMake(110, 153, 200,230);
            clothImage.frame=targetClothFrame;
            clothImage.image = sentUniform[indexPath.row];
            
        }else if(indexPath.row ==2)
        {
            CGRect targetClothFrame=CGRectMake(105, 195, 200,210);
            clothImage.frame=targetClothFrame;
            clothImage.image = sentUniform[indexPath.row];
            
            
        }else if (indexPath.row==3)
        {
            
            CGRect targetClothFrame=CGRectMake(100, 198, 180,210);
 
            clothImage.frame=targetClothFrame;
             clothImage.image = sentUniform[indexPath.row];
            
            
        }else if(indexPath.row ==4)
        {
            CGRect targetClothFrame=CGRectMake(110, 157, 190,230);
     
            clothImage.frame=targetClothFrame;

             clothImage.image = sentUniform[indexPath.row];
        }else if(indexPath.row==5)
        {
            
            hairImg.frame=originHairFrame;
             hairImg.image=sentUniform[indexPath.row];
        }else if(indexPath.row==6)
        {
            CGRect targetHairFrame=CGRectMake(24, -25, 350,360);
            hairImg.frame=targetHairFrame;
            
          
            hairImg.image=sentUniform[indexPath.row];
        }else if(indexPath.row==7)
        {
            CGRect targetHairFrame=CGRectMake(90, 15, 230,300);
  
                        hairImg.frame=targetHairFrame;
            
         
            hairImg.image=sentUniform[indexPath.row];
        }else if(indexPath.row==8)
        {
            
            CGRect targetHairFrame=CGRectMake(0, 0, 240,350);
            targetHairFrame.origin.y=mask.center.y-190;
            targetHairFrame.origin.x=self.frame.size.width/2-110;
            hairImg.frame=targetHairFrame;
            hairImg.image=sentUniform[indexPath.row];
        }
        else if(indexPath.row==9)
        {
            CGRect targetHairFrame=CGRectMake(0, 0, 327,350);
            targetHairFrame.origin.y=mask.center.y-270;
            targetHairFrame.origin.x=self.frame.size.width/2-150;
            hairImg.frame=targetHairFrame;
            
            hairImg.image=sentUniform[indexPath.row];
        }
    
    
}






-(void)btnPressed{
   
    UIGraphicsBeginImageContext(_sentView.bounds.size);
    [_sentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *testView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100,100)];
    
    testView.image = myImage;
    
    [self addSubview:testView];
    
}


@end
