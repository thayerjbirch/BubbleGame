//
//  rngNode.m
//  TBRKBubble
//
//  Created by 3413 on 12/4/14.
//  Copyright (c) 2014 3413. All rights reserved.
//

#import "rngNode.h"

@implementation rngNode

- (id)init
{
    self = [super init];
    if(self){
        _colorValue = rand()%2;
        // this will later be _typeValue = rand()%3;
        _typeValue = 1;
    }
    return self;
}

@end
