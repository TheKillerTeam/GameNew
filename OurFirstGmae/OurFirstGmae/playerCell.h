//
//  playerCell.h
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/7/24.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface playerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *playerPhoto;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UILabel *vote;

@end
