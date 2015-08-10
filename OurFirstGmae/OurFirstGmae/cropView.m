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
  
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)step{
 
    
    uniformArray = [NSArray new];
    
     uniformArray = @[[UIImage imageNamed:@"play6.jpg"],[UIImage imageNamed:@"play7.jpg"]];
    self.clipsToBounds =YES;
    
    _cover= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height-150)];
    _cover.backgroundColor=[UIColor clearColor];
    [self addSubview:_cover];
    
    
    
    
//    int radius = 70;
    mask=[[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2, self.frame.size.height/2-270, 2*RADIUS, 2*RADIUS)];
    mask.center= CGPointMake(self.frame.size.width/2, self.frame.size.height/2-200);
    mask.layer.cornerRadius=RADIUS;
    mask.layer.masksToBounds=YES;
    mask.clipsToBounds=YES;
   
    
    
    mask.layer.borderWidth=5;
    mask.layer.borderColor=[UIColor redColor].CGColor;
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
    clothFrame.backgroundColor = [UIColor whiteColor];
    [clothFrame.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    clothFrame.transform = CGAffineTransformMakeRotation(M_PI/-2);
    clothFrame.showsVerticalScrollIndicator = YES;
    clothFrame.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 150);
    clothFrame.rowHeight = self.frame.size.width/4;
    NSLog(@"%f,%f,%f,%f",clothFrame.frame.origin.x,clothFrame.frame.origin.y,clothFrame.frame.size.width,clothFrame.frame.size.height);
    clothFrame.delegate = self;
    clothFrame.dataSource = self;
    [self addSubview:clothFrame];
    
    
    _clothImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 300)];
    _clothImage.backgroundColor = [UIColor redColor];
    CGRect frame = _clothImage.frame;
    frame.origin.y = mask.center.y;
    frame.origin.x = self.frame.size.width/2-_clothImage.frame.size.width/2;
    _clothImage.frame = frame;
    

    [_cover insertSubview:_clothImage belowSubview:mask];
    
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
        cell.imageView.image = uniform;
        cell.imageView.transform=CGAffineTransformMakeRotation(M_PI/2);

    
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(imageView.image !=nil){
    _clothImage.image = uniformArray[indexPath.row];
    }
    
    
    
    
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
