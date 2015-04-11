//
//  LikeDB.h
//  Scnr
//
//  Created by Steve Dekorte on 3/25/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "JSONDB.h"

@interface LikeDB : JSONDB

- (void)saveOnExit;

// ids should be strings or numbers

- (void)likeId:(id)anId;
- (void)dislikeId:(id)anId;

- (BOOL)doesLikeId:(id)anId;
- (BOOL)doesDislikeId:(id)anId;

- (NSArray *)likedIds;

@end
