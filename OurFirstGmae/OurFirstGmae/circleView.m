//
//  circleView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/26.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "circleView.h"
#import "dragImageView.h"
@implementation circleView

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
        
        center =CGPointMake(frame.size.width/2,frame.size.height/2);
        
    }
    
    return self;
}
-(void)loadView{
    if(_ImgArray.count>0){
    [self showImage];
    [self addGesture];
    }else{
        return;
    }
    
    
}
-(void)showImage{

    
    CGFloat fRadina;
    avg_radina = 2*M_PI/_ImgArray.count;
    radius=self.frame.size.width/4.0;
    for(int i = 0 ; i<_ImgArray.count ; i++){
        fRadina = avg_radina*i;
        CGPoint point = [self getPointByRadian:fRadina centreOfCircle:center radiusOfCircle:radius];
        dragImageView *dragImg =[_ImgArray objectAtIndex:i];
        dragImg.center =point;
        dragImg.radian =fRadina;
        dragImg.current_radian =fRadina;
        dragImg.view_point = point;
        dragImg.animation_radian = [self getAnimationRadianByRadian:avg_radina*i];
        dragImg.current_animation_radian =[self getAnimationRadianByRadian:avg_radina*i];
        [self addSubview:dragImg];
        
    }
    
    
    
    
    
}

- (CGPoint)getPointByRadian:(CGFloat)radian centreOfCircle:(CGPoint)circle_point radiusOfCircle:(CGFloat)circle_radius
{
    CGFloat c_x = sinf(radian) * circle_radius + circle_point.x;
    CGFloat c_y = cosf(radian) * circle_radius + circle_point.y;
    
    return CGPointMake(c_x, c_y);
}

//根据和y轴的夹角换算成与x轴的夹角用于拖动后旋转
- (CGFloat)getAnimationRadianByRadian:(CGFloat)radian
{
    
    CGFloat an_r = 2.0f * M_PI -  radian + M_PI_2;
    
    if(an_r < 0.0f)
        an_r =  - an_r;
    
    return an_r;
}
- (CGFloat)getRadinaByRadian:(CGFloat)radian
{
    if(radian > 2 * M_PI)//floorf表示不大于该数的最大整数
        return (radian - floorf(radian / (2.0f * M_PI)) * 2.0f * M_PI);
    
    if(radian < 0.0f)//ceilf表示不小于于该数的最小整数
        return (2.0f * M_PI + radian - ceilf(radian / (2.0f * M_PI)) * 2.0f * M_PI);
    
    return radian;
}


- (void)addGesture{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePan:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];

}

//手势操作
- (void)handleSinglePan:(id)sender{
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)sender;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            dra_point = [panGesture locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint pointMove = [panGesture locationInView:self];
            [self dragPoint:dra_point movePoint:pointMove centerPoint:center];
            dra_point = pointMove;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint pointMove = [panGesture locationInView:self];
            [self dragPoint:dra_point movePoint:pointMove centerPoint:center];
            [self reviseCirclePoint];
        }
            break;
        case UIGestureRecognizerStateFailed:
        {
            CGPoint pointMove = [panGesture locationInView:self];
            [self dragPoint:dra_point movePoint:pointMove centerPoint:center];
            [self reviseCirclePoint];
        }
            break;
            
        default:
            break;
    }
}

//随着拖动改变子view位置，子view与y轴的夹角，子view与x轴的夹角
- (void)dragPoint:(CGPoint)dragPoint movePoint:(CGPoint)movePoint centerPoint:(CGPoint)centerPoint{
    CGFloat drag_radian   = [self schAtan2f:dragPoint.x - centerPoint.x theB:dragPoint.y - centerPoint.y];
    
    CGFloat move_radian   = [self schAtan2f:movePoint.x - centerPoint.x theB:movePoint.y - centerPoint.y];
    
    CGFloat change_radian = (move_radian - drag_radian);
    for (int i=0; i<_ImgArray.count; i++) {
        dragImageView *imageview = [_ImgArray objectAtIndex:i];
        imageview.center = [self getPointByRadian:(imageview.current_radian+change_radian) centreOfCircle:center radiusOfCircle:radius];
        imageview.current_radian = [self getRadinaByRadian:imageview.current_radian + change_radian];;
        imageview.current_animation_radian = [self getAnimationRadianByRadian:imageview.current_radian];;
    }
}

//计算schAtan值
- (CGFloat)schAtan2f:(CGFloat)a theB:(CGFloat)b
{
    CGFloat rd = atan2f(a,b);
    
    if(rd < 0.0f)
        rd = M_PI * 2 + rd;
    
    return rd;
}

//旋转结束后滑动到指定位置
- (void)reviseCirclePoint{
    BOOL isClockwise;
    
    dragImageView *imageviewFirst = [_ImgArray objectAtIndex:0];
    CGFloat temp_value = [self getRadinaByRadian:imageviewFirst.current_radian]/avg_radina;
    NSInteger iCurrent = (NSInteger)(floorf(temp_value));
    temp_value = temp_value - floorf(temp_value);
    
    step = iCurrent;
    if (temp_value > 0.5f) {//超过半个弧度
        isClockwise = NO;
        step ++;
    }else{
        isClockwise = YES;
    }
    
    for (int i=0; i<_ImgArray.count; i++) {
        NSInteger iDest = i+step;
        if (iDest >= _ImgArray.count) {
            iDest = iDest%_ImgArray.count;
        }
        [self animateWithDuration:0.25f * (temp_value/avg_radina)  animateDelay:0.0f changeIndex:i toIndex:iDest circleArray:_ImgArray clockwise:isClockwise];
    }
}

//平衡动画
- (void)animateWithDuration:(CGFloat)time animateDelay:(CGFloat)delay changeIndex:(NSInteger)change_index toIndex:(NSInteger)to_index circleArray:(NSMutableArray *)array clockwise:(BOOL)is_clockwise{
    dragImageView *change_cell = [array objectAtIndex:change_index];
    dragImageView *to_cell     = [array objectAtIndex:to_index];
    
    /*圆*/
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:[NSString stringWithFormat:@"position"]];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL,change_cell.layer.position.x,change_cell.layer.position.y);
    
    int clockwise = is_clockwise?0:1;
    
    CGPathAddArc(path,nil,
                 center.x, center.y, /*圆心*/
                 radius,                          /*半径*/
                 change_cell.current_animation_radian, to_cell.animation_radian, /*弧度改变*/
                 clockwise
                 );
    animation.path = path;
    CGPathRelease(path);
    animation.fillMode            = kCAFillModeForwards;
    animation.repeatCount         = 1;
    animation.removedOnCompletion = NO;
    animation.calculationMode     = @"paced";
    
    /*动画组合*/
    CAAnimationGroup *anim_group  = [CAAnimationGroup animation];
    anim_group.animations          = [NSArray arrayWithObjects:animation, nil];
    anim_group.duration            = time + delay;
    anim_group.delegate            = self;
    anim_group.fillMode            = kCAFillModeForwards;
    anim_group.removedOnCompletion = NO;
    NSLog(@"animgroup =%@",anim_group.description);
    
    [change_cell.layer addAnimation:anim_group forKey:[NSString stringWithFormat:@"anim_group_%ld",(long)change_index]];
    
    /*改变属性*/
    change_cell.current_animation_radian = to_cell.animation_radian;
    change_cell.current_radian           = to_cell.radian;
}

#pragma mark -
#pragma mark - animation delegate

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    for (int i = 0; i < _ImgArray.count; ++i)
    {
        NSInteger iDest = i+step;
        if (iDest >= _ImgArray.count) {
            iDest = iDest%_ImgArray.count;
        }
        dragImageView *change_cell = [_ImgArray objectAtIndex:i];
        
        dragImageView *to_cell     = [_ImgArray objectAtIndex:iDest];
        
        [change_cell.layer removeAllAnimations];
        
        change_cell.center    = to_cell.view_point;
    }
}






@end
