//
//  SCAlbum
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import <NavKit/NavKit.h>

#define SCAlbumFoundSimilarArtist @"SCAlbumFoundSimilarArtist"

@interface SCAlbum : NavInfoNode

@property (strong, nonatomic) NSNumber *collectionId;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NavInfoNode *similar;
@property (strong, nonatomic) NavInfoNode *tracks;
@property (assign, nonatomic) BOOL hasLoaded;

- (void)loadSimilar;

- (void)fetchDictIfNeeded;

@end
