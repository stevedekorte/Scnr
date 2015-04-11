//
//  SCLikable.h
//  Scnr
//
//  Created by Steve Dekorte on 3/25/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import <NavNodeKit/NavNodeKit.h>

@interface SCLikable : NavInfoNode

- (void)updateLikeStatus;

- (NSString *)likeId;

- (BOOL)isLiked;
- (BOOL)isDisliked;

- (NSString *)likeString;
- (void)like;
- (void)dislike;

@end
