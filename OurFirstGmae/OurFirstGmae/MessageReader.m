//
//  MessageReader.m
//  OurFirstGmae
//
//  Created by Eric on 2015/8/3.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "MessageReader.h"

@implementation MessageReader

- (id)initWithData:(NSData *)data {
    
    if ((self = [super init])) {
        _data = data;
        _offset = 0;
    }
    return self;
}

- (unsigned char)readByte {
    
    unsigned char retval = *((unsigned char *) (_data.bytes + _offset));
    _offset += sizeof(unsigned char);
    return retval;
}

- (int)readInt {
    
    int retval = *((unsigned int *) (_data.bytes + _offset));
    retval = ntohl(retval);
    _offset += sizeof(unsigned int);
    return retval;
}

- (NSString *)readString {
    
    int strLen = [self readInt];
    NSString *retval = [NSString stringWithCString:_data.bytes+_offset encoding:NSUTF8StringEncoding];
    _offset += strLen;
    return retval;
}

@end