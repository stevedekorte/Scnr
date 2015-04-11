//
//  SCArtist
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import <NavKit/NavKit.h>
#import "SCLikable.h"

@interface SCArtist : SCLikable

@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSNumber *artistId;

@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NavInfoNode *similarArtists;
@property (strong, nonatomic) NavInfoNode *albums;
@property (strong, nonatomic) NavInfoNode *tracks;
@property (assign, nonatomic) BOOL hasLoaded;

@property (assign, nonatomic) BOOL shouldInlineSimilar;
@property (assign, nonatomic) BOOL shouldInlineTracks;

@property (assign, nonatomic) BOOL isLoadingTracks;
@property (assign, nonatomic) NSInteger loadingSimilarCount;

- (void)fetchDictIfNeeded;
- (void)loadTracks;

- (void)dislikeAllTracks;
- (void)updateLikeStatus;

@end
