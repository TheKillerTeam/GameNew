//
//  cropView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/29.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "cropView.h"
#import <QuartzCore/QuartzCore.h>
#import "clothCell.h"
#define RADIUS 70
#define TABLEVIEW_HEIGHT 100
@implementation cropView
{
    CGFloat lastScale,lastX,lastY;
    UIButton *button;
    UIImageView *hairImg;
    CGRect originClothFrame;
    CGRect originHairFrame;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)step{
    sentUniform =[NSArray new];
    sentUniform= @[[UIImage imageNamed:@"forPlayer1.png"],[UIImage imageNamed:@"forPlayer2.png"],[UIImage imageNamed:@"forPlayer3.png"],[UIImage imageNamed:@"forPlayer4.png"],[UIImage imageNamed:@"forPlayer5.png"],[UIImage imageNamed:@"forPlayerHair1.png"],[UIImage imageNamed:@"forPlayerHair2.png"],[UIImage imageNamed:@"forPlayerHair3.png"],[UIImage imageNamed:@"forPlayerHair4.png"],[UIImage imageNamed:@"forPlayerHair5.png"]];
//    hairArray =[NSArray new];
//    hairArray = @[[UIImage imageNamed:@"hair1.png"],[UIImage imageNamed:@"hair2.png"],[UIImage imageNamed:@"hair5.png"],[UIImage imageNamed:@"hair4.png"],[UIImage imageNamed:@"hair3.png"]];
    
    
    uniformArray = [NSArray new];
    
     uniformArray = @[[UIImage imageNamed:@"clothe1.png"],[UIImage imageNamed:@"clothe2.png"],[UIImage imageNamed:@"clothe3.png"],[UIImage imageNamed:@"clothe4.png"],[UIImage imageNamed:@"clothe5.png"],[UIImage imageNamed:@"hair1.png"],[UIImage imageNamed:@"hair2.png"],[UIImage imageNamed:@"hair3.png"],[UIImage imageNamed:@"hair4.png"],[UIImage imageNamed:@"hair5.png"]];
    self.clipsToBounds =YES;
    
    _cover= [[UIImageView alloc]initWithFrame:CGRectMake(-10, 0, self.frame.size.width+10,self.frame.size.height-140)];
    _cover.backgroundColor=[UIColor clearColor];
    _cover.image=[UIImage imageNamed:@"playerInfoBg.png"];
    

    [self addSubview:_cover];
    
     
    NSLog(@"cover %@",NSStringFromCGRect(_cover.frame));
    
//    int radius = 70;
    mask=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 2*RADIUS, 2*RADIUS)];
    mask.center= CGPointMake(self.frame.size.width/2, self.frame.size.height/2-140);
    mask.layer.cornerRadius=RADIUS;
    mask.layer.masksToBounds=YES;
    mask.clipsToBounds=YES;
   
    
    
    mask.layer.borderWidth=0;
    mask.layer.borderColor=[UIColor blackColor].CGColor;
    mask.layer.backgroundColor=[UIColor whiteColor].CGColor;
    mask.userInteractionEnabled= YES;
    [_cover addSubview:mask];
    [self.cover setUserInteractionEnabled:YES];
    
    
    
    imageView=[UIImageView new];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    imageView.frame = CGRectMake(mask.frame.size.width/2, mask.frame.size.height/2, 2*RADIUS ,2*RADIUS);
    imageView.center=CGPointMake(mask.frame.size.width/2, mask.frame.size.height/2);
//    imageView.layer.cornerRadius=RADIUS;
//    imageView.layer.masksToBounds=YES;
//    imageView.clipsToBounds=YES;
    [mask addSubview:imageView];
    
    
    
    
    UIPinchGestureRecognizer *scaleGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(scaleImage:)];
    [mask addGestureRecognizer:scaleGes];
    
    
    UIPanGestureRecognizer *moveGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
    [moveGes setMinimumNumberOfTouches:1];
    [moveGes setMaximumNumberOfTouches:1];
    [mask addGestureRecognizer:moveGes];
    
    


    clothFrame  = [UITableView new];
    clothFrame.backgroundColor = [UIColor redColor];
    [clothFrame.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    clothFrame.transform = CGAffineTransformMakeRotation(M_PI/-2);
    clothFrame.showsVerticalScrollIndicator = YES;
    clothFrame.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 150);
    clothFrame.rowHeight = self.frame.size.width/4;
    NSLog(@"%f,%f,%f,%f",clothFrame.frame.origin.x,clothFrame.frame.origin.y,clothFrame.frame.size.width,clothFrame.frame.size.height);
    clothFrame.delegate = self;
    clothFrame.dataSource = self;
    
    [self addSubview:clothFrame];
    
    
    _clothImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 140, 220)];
    _clothImage.backgroundColor = [UIColor redColor];
    CGRect frame = _clothImage.frame;
    frame.origin.y = mask.center.y+61;
    frame.origin.x = self.frame.size.width/2-_clothImage.frame.size.width/2+3;
    _clothImage.frame = frame;
    _clothImage.backgroundColor=[UIColor clearColor];
    
    originClothFrame = _clothImage.frame;
    [_cover insertSubview:_clothImage aboveSubview:mask];
    
    
    hairImg= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 220, 200)];
    CGRect hair =hairImg.frame;
    hair.origin.y=mask.center.y-140;
    hair.origin.x=self.frame.size.width/2-hairImg.frame.size.width/2-10;
    hairImg.frame=hair;
    hairImg.backgroundColor=[UIColor clearColor];
    originHairFrame=hairImg.frame;
    [_cover insertSubview:hairImg  aboveSubview:mask];
    
    
    
    
    button= [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"add" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button setFrame:CGRectMake(0, 0, 50,50)];
    [button addTarget:self action:@selector(btnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
    
    
    
}

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        [self step];
    }
    return self;
}


-(void)scaleImage:(UIPinchGestureRecognizer*)sender{
    
    if([sender state]==UIGestureRecognizerStateBegan){
        lastScale = 1.0;
        return;
    }
    
    CGFloat scale = [sender scale]/lastScale;
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [imageView setTransform:newTransform];
    
    lastScale = [sender scale];
    
    
    
}
-(void)moveImage:(UIPanGestureRecognizer*)sender{
    
    CGPoint translatedPoint = [sender translationInView:self];
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        lastX=0.0;
        lastY= 0.0;
    }
    
    CGAffineTransform trans = CGAffineTransformMakeTranslation(translatedPoint.x - lastX, translatedPoint.y - lastY);
    CGAffineTransform newTransform = CGAffineTransformConcat(imageView.transform, trans);
    lastX = translatedPoint.x;
    lastY = translatedPoint.y;
    
    imageView.transform = newTransform;
}

-(void)setImage:(UIImage*)image1{
    imageView.image=image1;
    
    
    
    
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
        CGRect rect = CGRectMake(0,0,400,400);
        UIGraphicsBeginImageContext( rect.size );
        [uniform drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData =UIImageJPEGRepresentation(picture1, 1.0);
        UIImage *img=[UIImage imageWithData:imageData];
        
        cell.imageView.image = img;
        cell.imageView.transform=CGAffineTransformMakeRotation(M_PI/2);
   
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

//    _clothImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 140, 220)];
//    _clothImage.backgroundColor = [UIColor redColor];
//    CGRect frame = _clothImage.frame;
//    frame.origin.y = mask.center.y+57;
//    frame.origin.x = self.frame.size.width/2-_clothImage.frame.size.width/2+5;
//    _clothImage.frame = frame;
//    _clothImage.backgroundColor=[UIColor clearColor];
    
    
    
//    
//    hairImg= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 220, 200)];
//    CGRect hair =hairImg.frame;
//    hair.origin.y=mask.center.y-140;
//    hair.origin.x=self.frame.size.width/2-hairImg.frame.size.width/2-10;
//    hairImg.frame=hair;
//    hairImg.backgroundColor=[UIColor clearColor];
//    [_cover insertSubview:hairImg  aboveSubview:mask];
//    if(imageView.image !=nil){
   
    
        if(indexPath.row==0){
            _clothImage.frame=originClothFrame;
            _clothImage.image = sentUniform[indexPath.row];
        }else if (indexPath.row ==1){
            
            
            CGRect targetClothFrame=CGRectMake(83, 137, 200,280);
            _clothImage.frame=targetClothFrame;
            _clothImage.image = sentUniform[indexPath.row];
            
        }else if(indexPath.row ==2)
        {
            CGRect targetClothFrame=CGRectMake(86, 203, 200,200);
            _clothImage.frame=targetClothFrame;
            _clothImage.image = sentUniform[indexPath.row];
            
            
        }else if (indexPath.row==3)
        {
            
            CGRect targetClothFrame=CGRectMake(80, 203, 180,195);
            //        //            targetFrame.origin.y=self.center.y;
            //        //            targetFrame.origin.x=self.center.x;
            _clothImage.frame=targetClothFrame;
//            CGRect targetHairFrame=CGRectMake(0, 0, 200,200);
//            targetHairFrame.origin.y=mask.center.y-130;
//            targetHairFrame.origin.x=self.frame.size.width/2-105;
//            hairImg.frame=targetHairFrame;
             _clothImage.image = sentUniform[indexPath.row];
            
            
        }else if(indexPath.row ==4)
        {
            CGRect targetClothFrame=CGRectMake(110, 157, 190,230);
            //        //            targetFrame.origin.y=self.center.y;
            //        //            targetFrame.origin.x=self.center.x;
            _clothImage.frame=targetClothFrame;
//            CGRect targetHairFrame=CGRectMake(0, 0, 140,100);
//            targetHairFrame.origin.y=mask.center.y-95;
//            targetHairFrame.origin.x=self.frame.size.width/2-70;
//            hairImg.frame=targetHairFrame;
             _clothImage.image = sentUniform[indexPath.row];
        }else if(indexPath.row==5)
        {
            
            hairImg.frame=originHairFrame;
             hairImg.image=sentUniform[indexPath.row];
        }else if(indexPath.row==6)
        {
            CGRect targetHairFrame=CGRectMake(30, 30, 300,350);
            hairImg.frame=targetHairFrame;
            
          
            hairImg.image=sentUniform[indexPath.row];
        }else if(indexPath.row==7)
        {
            CGRect targetHairFrame=CGRectMake(0, 0, 145,185);
            targetHairFrame.origin.y=mask.center.y-114;
            targetHairFrame.origin.x=self.frame.size.width/2-71;
                        hairImg.frame=targetHairFrame;
            
         
            hairImg.image=sentUniform[indexPath.row];
        }else if(indexPath.row==8)
        {
            
            CGRect targetHairFrame=CGRectMake(0, 0, 200,200);
            targetHairFrame.origin.y=mask.center.y-120;
            targetHairFrame.origin.x=self.frame.size.width/2-105;
            hairImg.frame=targetHairFrame;
            hairImg.image=sentUniform[indexPath.row];
        }
        else if(indexPath.row==9)
        {
            CGRect targetHairFrame=CGRectMake(0, 0, 180,200);
            targetHairFrame.origin.y=mask.center.y-130;
            targetHairFrame.origin.x=self.frame.size.width/2-90;
            hairImg.frame=targetHairFrame;
            
            hairImg.image=sentUniform[indexPath.row];
        }
    
    
        
        
 

    
        
    
 
        
        
        
        
        
        
        
//    }
    
    
    
    
}






-(UIImage*) conbineImage:(UIImage*)firstImage withImage:(UIImage*)secondImage{
    
    CGSize targetSize = CGSizeMake(MAX(firstImage.size.width,secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    UIGraphicsBeginImageContext(targetSize);
    [firstImage drawInRect:CGRectMake(0, 0, firstImage.size.width, firstImage.size.height)];
    [secondImage drawInRect:CGRectMake(0, 0, secondImage.size.width, secondImage.size.height)];
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    
    
    
    UIGraphicsEndImageContext();
    
    
    
    
    
    
    return newImage;
}

-(void)btnPressed{
   
    UIGraphicsBeginImageContext(_cover.bounds.size);
    [_cover.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *testView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100,100)];
    
    testView.image = myImage;
    [self addSubview:testView];
    
}


@end
