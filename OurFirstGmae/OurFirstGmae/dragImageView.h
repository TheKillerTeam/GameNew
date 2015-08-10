//
//  dragImageView.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/26.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dragImageView : UIImageView
//與y軸實際角度(逆時) 用於在拖動時確定DraaImageView的中心
@property(nonatomic) CGFloat current_radian;

//記錄該位置的初始角度(Y軸)
@property(nonatomic) CGFloat radian;

//與x軸實際角度 用於DraImageView拖動停止後旋轉
@property(nonatomic) CGFloat current_animation_radian;

//記錄該位置初始角度(與X軸）
@property(nonatomic) CGFloat animation_radian;

//DragImageView的中心
@property(nonatomic) CGPoint view_point;

@end
