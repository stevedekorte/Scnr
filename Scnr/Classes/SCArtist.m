//
//  SCArtist
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import "SCArtist.h"
#import "SCTrack.h"
#import "SCAlbum.h"
#import <NavKit/NavKit.h>
#import "SCTunesCache.h"

@implementation SCArtist

- (id)init
{
    self = [super init];
    //self.nodeSuggestedWidth = @170;
    self.nodeSuggestedWidth = @270;
    self.nodeShouldSortChildren = @NO;
    
    self.albums = [[NavInfoNode alloc] init];
    [self.albums setNodeTitle:@"albums"];
    //[self addChild:self.albums];
    
    self.tracks = [[NavInfoNode alloc] init];
    [self.tracks setNodeTitle:@"tracks"];
    [self addChild:self.tracks];
    self.tracks.nodeSuggestedWidth = @270;
    
    self.similarArtists = [[NavInfoNode alloc] init];
    [self.similarArtists setNodeTitle:@"similar"];
    [self addChild:self.similarArtists];
    self.similarArtists.nodeSuggestedWidth = @170;
    
    return self;
}

- (void)setShouldInlineSimilar:(BOOL)shouldInlineSimilar
{
    _shouldInlineSimilar = shouldInlineSimilar;
    [self removeChild:self.similarArtists];
    [self removeChild:self.tracks];
}

- (void)setShouldInlineTracks:(BOOL)shouldInlineTracks
{
    _shouldInlineTracks = shouldInlineTracks;
    [self removeChild:self.similarArtists];
    [self removeChild:self.tracks];
}

- (NSString *)nodeSubtitle
{
    if (self.loadingSimilarCount > 0)
    {
        return @"loading similar artists...";
    }
    
    if (self.isLoadingTracks)
    {
        return @"loading tracks...";
    }
    
    return nil;
}


- (NSArray *)children
{
    if (self.shouldInlineSimilar)
    {
        return self.similarArtists.children;
    }
    
    if (self.shouldInlineTracks)
    {
        return self.tracks.children;
    }
    
    return [super children];
}


// ----

- (NSUInteger)hash
{
    return [self.artistName hash];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[SCArtist class]])
    {
        return NO;
    }
    
    return [_artistName isEqual:[(SCArtist *)object artistName]];
}

// ----

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;
    
    [self setArtistName:[dict objectForKey:@"artistName"]];
    [self setNodeTitle:[dict objectForKey:@"artistName"]];
    [self setArtistId:[dict objectForKey:@"artistId"]];
    //[self setNodeSubtitle:[dict objectForKey:@"primaryGenreName"]];
    //[self setNodeSubtitle:@"artist"];
    
    [self updateLikeStatus];
}

- (void)nodeWillSelect
{
    if (self.tracks.children.count == 0)
    {
        [self loadTracks];
    }
}

// --- load albums ---

/*
- (NSURL *)albumSearchURL
{
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?country=us&id=%@&entity=album", self.artistId];
    
    NSLog(@"albumSearchURL %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

- (void)loadAlbums
{
    if (!_hasLoaded)
    {
        _hasLoaded = YES;
        
        NSArray *albumDicts = [[SCTunesCache sharedTunesCache] syncResultsForUrl:self.albumSearchURL];
        NSMutableArray *resultAlbums = [NSMutableArray array];
        
        for (NSDictionary *albumDict in albumDicts)
        {
            //NSLog(@"albumDict = %@", albumDict);
            SCAlbum *album = [[SCAlbum alloc] init];
            [album setDict:albumDict];
            [resultAlbums addObject:album];
        }
        
        [self.albums setChildren:resultAlbums];
        [self.albums postSelfChanged];
        
        [self loadTracks];
        [self loadSimilarArtists];
    }
}
 */

// --- load tracks ---

/*
- (void)fetchArtistIdIfNeeded
{
    if (!self.collectionId)
    {
        NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=album", self.artistId];
        NSString *htmlString = [[SCTunesCache sharedTunesCache] syncStringForUrl:self.similarSearchURL];
    }
}
*/

- (NSURL *)artistLookupURL
{
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", self.artistId];
    return [NSURL URLWithString:urlString];
}

- (void)fetchDictIfNeeded
{
    if (self.artistId && !self.dict)
    {
        NSArray *results = [[SCTunesCache sharedTunesCache] syncResultsForUrl:self.artistLookupURL];
        
        //NSLog(@"results = %@", results);
        
        [self setDict:[results objectAtIndex:0]];
    }
}

- (NSURL *)trackSearchURL
{
    //NSString *escapedUrlString = [self.artistId
     //                             stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=song", self.artistId];
    
    NSLog(@"trackSearchURL %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

- (void)loadTracks
{
    self.isLoadingTracks = YES;
    [[SCTunesCache sharedTunesCache] asyncResultsForUrl:self.trackSearchURL
                                                target:self
                                            withAction:@selector(setTrackDicts:)];
    
    [self postParentChainChanged];
}

- (BOOL)hasTrack:(SCTrack *)aTrack
{
    for (SCTrack *track in self.tracks.children)
    {
        if ([track.trackName.lowercaseString isEqualToString:aTrack.trackName.lowercaseString])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)setTrackDicts:(NSArray *)trackDicts
{
    self.isLoadingTracks = NO;
    //NSMutableArray *tracks = [NSMutableArray array];
    
    for (NSDictionary *trackDict in trackDicts)
    {
        NSString *wrapper = [trackDict objectForKey:@"wrapperType"];
        
        if ([wrapper isEqualToString:@"track"])
        {
            //NSLog(@"albumDict = %@", albumDict);
            SCTrack *track = [[SCTrack alloc] init];
            [track setDict:trackDict];
            //[tracks addObject:track];
            
            if (![self hasTrack:track])
            {
                [track setArtist:self];
                [self.tracks addChild:track];
                [self postParentChainChanged]; // for inline
            }
            
            [self createIfAbsentAlbumWithId:track.collectionId];
        }
    }
    
    [self updateLikeStatus];
    /*
    [self.tracks setChildren:tracks];
    [self.tracks postSelfChanged];
    [self.tracks postParentChanged];
    */
}

- (SCAlbum *)createIfAbsentAlbumWithId:(NSNumber *)collectionId
{
    for (SCAlbum *album in self.albums.children)
    {
        if ([[album collectionId] isEqual:collectionId])
        {
            return album;
        }
    }

    return [self addAlbumWithId:collectionId];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (SCAlbum *)addAlbumWithId:(NSNumber *)collectionId
{
    SCAlbum *album = [[SCAlbum alloc] init];
    [album setCollectionId:collectionId];
    
    [self.albums addChild:album];
    
    if (!self.shouldInlineTracks)
    {
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(foundSimilar:)
                                                   name:SCAlbumFoundSimilarArtist
                                                 object:album];
        self.loadingSimilarCount ++;
        
        [album loadSimilar];
    }
    
    return album;
}

- (void)foundSimilar:(NSNotification *)note
{
    self.loadingSimilarCount --;
    
    SCArtist *foundArtist = [[note userInfo] objectForKey:@"artist"];
    SCArtist *artist = [[SCArtist alloc] init];
    
    if (![foundArtist.artistName.strip isEqualToString:@""])
    {
        [artist setArtistId:foundArtist.artistId];
        [artist fetchDictIfNeeded];

        [self.similarArtists addChild:artist];
        [artist setShouldInlineTracks:YES];
        [self postParentChainChanged]; // for inline
    }
}

// likes

- (LikeDB *)likeDb
{
    return SCTunesCache.sharedTunesCache.artistLikeDb;
}

- (NSString *)likeId
{
    return [NSString stringWithFormat:@"%@", self.artistId];
}

- (void)updateLikeStatus
{
    if ([self allTracksAreUnliked] && ![self isDisliked])
    {
        [self dislike];
    }
    
    if ([self hasLikedTrack] && ![self isLiked])
    {
        [self like];
    }
    
    NSString *newNote = self.likeString;
    
    if ((newNote != self.nodeNote) && (![newNote isEqualToString:self.nodeNote]))
    {
        self.nodeNote = self.likeString;
        [self postParentChainChanged];
    }
}

- (BOOL)allTracksAreUnliked
{
    if (self.tracks.children.count == 0)
    {
        return NO;
    }
    
    NSInteger dislikeCount = 0;
    
    for (SCTrack *track in self.tracks.children)
    {
        if (track.isDisliked)
        {
            dislikeCount ++;
        }
    }
    
    return dislikeCount == [self.tracks.children count];
}

- (BOOL)hasLikedTrack
{
    for (SCTrack *track in self.tracks.children)
    {
        if (track.isLiked)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)dislikeAllTracks
{
    for (SCTrack *track in self.tracks.children)
    {
        if (!track.isLiked)
        {
            [track dislike];
        }
    }
}

/*
- (void)justPostSelfChanged
{
    NSLog(@"Artist %@ justPostSelfChanged", self.artistName);
    [super justPostSelfChanged];
}
*/

@end
