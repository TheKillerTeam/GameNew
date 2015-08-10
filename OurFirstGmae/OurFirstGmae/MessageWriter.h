//
//  MessageWriter.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageWriter : NSObject

@property (retain, readonly) NSMutableData *data;

- (void)writeByte:(unsigned char)value;
- (void)writeInt:(int)value;
- (void)writeString:(NSString *)value;

@end
