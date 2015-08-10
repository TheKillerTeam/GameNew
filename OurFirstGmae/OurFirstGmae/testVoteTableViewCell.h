//
//  testVoteTableViewCell.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/4.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface testVoteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *playerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *votedCountsLabel;
@property (weak, nonatomic) IBOutlet UIButton *voteButton;

@end
