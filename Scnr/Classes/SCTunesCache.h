//
//  SCTunesCache
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import <NavKit/NavKit.h>
#import "SCArtist.h"
#import "SCAlbum.h"
#import "SCTrack.h"
#import "LikeDB.h"
#import "FileCache.h"

@interface SCTunesCache : NavInfoNode

// network request cache
@property (strong, nonatomic) FileCache *trackCache;
@property (strong, nonatomic) FileCache *fileCache;
//@property (strong, nonatomic) NSMutableDictionary *urlCacheDict;
@property (strong, nonatomic) NSMutableDictionary *ownedTracks;
@property (strong, nonatomic) NSMutableSet *ownedTrackKeys;
@property (strong, nonatomic) NSMutableArray *activeTasks;

+ (SCTunesCache *)sharedTunesCache;

- (NSArray *)syncResultsForUrl:(NSURL *)urlString; // used for albums and tracks
- (NSString *)syncStringForUrl:(NSURL *)url;

- (void)asyncStringForUrl:(NSURL *)url  target:(id)target withAction:(SEL)action;
//- (void)asyncDataForUrl:(NSURL *)url    target:(id)target withAction:(SEL)action;
- (void)asyncResultsForUrl:(NSURL *)url target:(id)target withAction:(SEL)action;

// likes db

//@property (strong, nonatomic) LikeDB *likeDb;
@property (strong, nonatomic) LikeDB *artistLikeDb;
@property (strong, nonatomic) LikeDB *trackLikeDb;

- (BOOL)itunesLibraryHasTrackId:(NSNumber *)trackId;
- (BOOL)itunesLibraryHasSCTrack:(SCTrack *)scTrack;

- (NSMutableArray *)unpurchasedSCTracks;

@end
