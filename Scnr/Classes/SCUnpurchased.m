//
//  SCUnpurchased.m
//  Scnr
//
//  Created by Steve Dekorte on 3/31/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "SCUnpurchased.h"
#import "SCTunesCache.h"

@implementation SCUnpurchased

- (id)init
{
    self = [super init];
    
    [self setNodeTitle:@"unpurchased"];
    return self;
}

- (void)nodeWillSelect
{
    [self update];
}


- (void)update
{
    [self setChildren:[SCTunesCache.sharedTunesCache unpurchasedSCTracks]];
    [self postParentChainChanged];
    
}

@end
