//
//  SCLikable.m
//  Scnr
//
//  Created by Steve Dekorte on 3/25/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "SCLikable.h"
#import "SCTunesCache.h"

@implementation SCLikable

- (void)updateLikeStatus
{
    NSString *newNote = self.likeString;
    
    if ((newNote != self.nodeNote) && (![newNote isEqualToString:self.nodeNote]))
    {
        self.nodeNote = newNote;
        [self postParentChainChanged];
    }
}

- (LikeDB *)likeDb
{
    //return SCTunesCache.sharedTunesCache.likeDb;
    [NSException raise:@"subclasses should overide likeId method" format:nil];
    return nil;
}

// likes

- (NSString *)likeId
{
    [NSException raise:@"subclasses should overide likeId method" format:nil];
    return nil;
}

- (BOOL)isLiked
{
    return [self.likeDb doesLikeId:self.likeId];
}

- (BOOL)isDisliked
{
    return [self.likeDb doesDislikeId:self.likeId];
}

- (NSString *)nodeStateName
{
    /*
    if (self.isLiked)
    {
        return @"liked";
    }
    */
    
    //if (!self.isSelected &&
    if(self.isDisliked)
    {
        return @"disliked";
    }
    
    return nil;
}

- (NSString *)likeString
{
    if ([self isLiked])
    {
        return @"✔";
    }
    else if ([self isDisliked])
    {
        return @"✘";
    }
    
    return nil;
}

- (void)like
{
    if (![self isLiked])
    {
        [self.likeDb likeId:self.likeId];
        [self updateLikeStatus];
    }
}

- (void)dislike
{
    if (![self isDisliked])
    {
        [self.likeDb dislikeId:self.likeId];
        [self updateLikeStatus];
    }
}

@end
