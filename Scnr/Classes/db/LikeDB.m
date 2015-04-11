//
//  LikeDB.m
//  Scnr
//
//  Created by Steve Dekorte on 3/25/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "LikeDB.h"
#import <Cocoa/Cocoa.h>
#import <NavKit/NavKit.h>

#import "SCTunesCache.h"
#import "SCTrack.h"

@implementation LikeDB

- (id)init
{
    self = [super init];
    
    
    return self;
}

- (void)saveOnExit
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(write)
                                                 name:NSApplicationWillTerminateNotification
                                               object:[NSApplication sharedApplication]];
}

- (void)read
{
    [super read];
    
    /*
    NSArray *keys = self.dict.allKeys.copy;
    
    for (NSString *key in keys)
    {
        if ([key hasPrefix:@"track_"])
        {
            id value = [self.dict objectForKey:key];
            NSString *newKey = [key after:@"_"];
            [self.dict setObject:value forKey:newKey];
            [self.dict removeObjectForKey:key];
        }
    }
    */
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)keyForId:(id)anId
{
    return [NSString stringWithFormat:@"%@", anId];
}

- (void)likeId:(id)anId
{
    [self.dict setObject:@1 forKey:[self keyForId:anId]];
}

- (void)dislikeId:(id)anId
{
    [self.dict setObject:@0 forKey:[self keyForId:anId]];
}

- (BOOL)doesLikeId:(id)anId
{
    return [[self.dict objectForKey:[self keyForId:anId]] isEqual:@1];
}

- (BOOL)doesDislikeId:(NSString *)anId
{
    return [[self.dict objectForKey:[self keyForId:anId]] isEqual:@0];
}

- (NSArray *)likedIds
{
    NSMutableArray *likes = [NSMutableArray array];
    
    for (NSString *k in self.dict.allKeys)
    {
        if ([self doesLikeId:k])
        {
            [likes addObject:k];
        }
    }
    
    return likes;
}

@end
