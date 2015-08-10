//
//  MessageReader.h
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageReader : NSObject {
    
    NSData * _data;
    int _offset;
}

- (id)initWithData:(NSData *)data;

- (unsigned char)readByte;
- (int)readInt;
- (NSString *)readString;

@end