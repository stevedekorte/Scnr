//
//  SCTunesCache
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import "SCTunesCache.h"
#import <iTunesLibrary/iTunesLibrary.h>


static SCTunesCache *sharedTunesCache = nil;

@implementation SCTunesCache

+ (SCTunesCache *)sharedTunesCache
{
    if (!sharedTunesCache)
    {
        sharedTunesCache = [[SCTunesCache alloc] init];
    }
    
    return sharedTunesCache;
}

- (id)init
{
    self = [super init];
    
    self.nodeSuggestedWidth = @250;
    
    self.nodeShouldSortChildren = @NO;
    
    //self.urlCacheDict = [NSMutableDictionary dictionary];
    
    self.fileCache = [[FileCache alloc] init];
    self.fileCache.ttlSeconds = 30*24*60*60; // 30 days
    [self.fileCache setName:@"urlCache"];
    
    self.trackCache = [[FileCache alloc] init];
    self.fileCache.ttlSeconds = 0; // never expire
    [self.fileCache setName:@"trackCache"];
    
    return self;
}

// file cache

- (NSString *)cacheKeyForUrl:(NSURL *)url
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)[[url absoluteString] hash]];
}

- (NSString *)cacheForUrl:(NSURL *)url
{
//    return [self.urlCacheDict objectForKey:[url absoluteString]];

    NSString *result = [self.fileCache at:[self cacheKeyForUrl:url]];
    
    if (result)
    {
        //NSLog(@"CACHE FOUND");
    }
    
    return result;
}

- (void)setCache:(NSString *)aValue forUrl:(NSURL *)url
{
    // [self.urlCacheDict setObject:aValue forKey:[url absoluteString]];
    [self.fileCache at:[self cacheKeyForUrl:url] put:aValue];
}

// ----------------------------------

- (NSArray *)syncResultsForUrl:(NSURL *)url
{
    NSString *jsonString = [self syncStringForUrl:url];
    return [self resultsForJsonString:jsonString];
}
    
- (NSArray *)resultsForJsonString:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    if (error)
    {
        return NO;
    }
    
    
    if(![object isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    
    NSDictionary *response = object;
    NSArray *results = [response objectForKey:@"results"];
    return results;
}

- (NSString *)syncStringForUrl:(NSURL *)url
{
    NSString *result = [self cacheForUrl:url];
    
    if (result)
    {
        return result;
    }
    
    NSError *error;
    result = [NSString stringWithContentsOfURL:url
                                      encoding:NSUTF8StringEncoding
                                         error:&error];
    if (error)
    {
        NSLog(@"error %@ loading %@", error, url);
        return nil;
    }
    
    [self setCache:result forUrl:url];
    
    return result;
}

- (void)asyncStringForUrl:(NSURL *)url target:(id)target withAction:(SEL)action
{
    NSString *result = [self cacheForUrl:url];

    if (result)
    {
        [target performSelectorOnMainThread:action withObject:result waitUntilDone:NO];
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data,
                                                            NSURLResponse *response,
                                                            NSError *error)
                                  {
                                      NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                                      [self setCache:string forUrl:url];
                                      [target performSelector:action withObject:string];
                                      [self.activeTasks removeObject:task];
                                  }];
    
    [self.activeTasks addObject:task];
    
    [task resume];
}

/*
- (void)asyncDataForUrl:(NSURL *)url target:(id)target withAction:(SEL)action
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                       completionHandler:^(NSData *data,
                                           NSURLResponse *response,
                                           NSError *error)
                 {
                     [target performSelector:action withObject:data];
                     [self.activeTasks removeObject:task];
                 }];
    
    [self.activeTasks addObject:task];
    
    [task resume];
}
*/

- (void)asyncResultsForUrl:(NSURL *)url target:(id)target withAction:(SEL)action
{
    
    NSString *result = [self cacheForUrl:url];
    
    if (result)
    {
        NSArray *results = [self resultsForJsonString:result];
        [target performSelectorOnMainThread:action withObject:results waitUntilDone:NO];
        return;
    }
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data,
                                                            NSURLResponse *response,
                                                            NSError *error)
                                  {
                                      NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      [self setCache:jsonString forUrl:url];
                                      NSArray *results = [self resultsForJsonString:jsonString];
                                      [target performSelector:action withObject:results];
                                      [self.activeTasks removeObject:task];
                                  }];
    
    [self.activeTasks addObject:task];
    
    [task resume];
}


// likes

- (LikeDB *)artistLikeDb
{
    if (!_artistLikeDb)
    {
        _artistLikeDb = [[LikeDB alloc] init];
        [_artistLikeDb setName:@"artistLikeDb"];
        _artistLikeDb.location = JSONDB_IN_APP_SUPPORT_FOLDER;
        [_artistLikeDb saveOnExit];
    }
    
    return _artistLikeDb;
}

- (LikeDB *)trackLikeDb
{
    if (!_trackLikeDb)
    {
        _trackLikeDb = [[LikeDB alloc] init];
        [_trackLikeDb setName:@"trackLikeDb"];
        _trackLikeDb.location = JSONDB_IN_APP_SUPPORT_FOLDER;
        [_trackLikeDb saveOnExit];
    }
    
    return _trackLikeDb;
}

/*
- (LikeDB *)likeDb
{
    if (!_likeDb)
    {
        _likeDb = [[LikeDB alloc] init];
        [_likeDb setName:@"likes"];
        _likeDb.location = JSONDB_IN_APP_SUPPORT_FOLDER;
        [_likeDb saveOnExit];
        
        for (NSString *k in _likeDb.dict)
        {
            id value = [_likeDb.dict objectForKey:k];
            
            if ([k hasPrefix:@"track_"])
            {
                [self.trackLikeDb.dict setObject:value forKey:[k after:@"track_"]];
            }
            else if ([k hasPrefix:@"artist_"])
            {
                [self.artistLikeDb.dict setObject:value forKey:[k after:@"artist_"]];
            }
        }
    }
    
    return _likeDb;
}
*/

// itunes


- (NSMutableDictionary *)ownedTracks
{
    if (!_ownedTracks)
    {
        [self readOwnedTracks];
    }
    
    return _ownedTracks;
}

- (BOOL)itunesLibraryHasTrackId:(NSNumber *)trackId
{
    return [self.ownedTracks objectForKey:trackId] != nil;
}

- (NSString *)keyForArtist:(NSString *)artistName andTrack:(NSString *)trackName
{
    NSString *trackKey = [NSString stringWithFormat:@"%@ - %@",
                          artistName.lowercaseString,
                          trackName.lowercaseString];
    return trackKey;
    
}

- (void)readOwnedTracks
{
    _ownedTracks = [NSMutableDictionary dictionary];
    _ownedTrackKeys = [NSMutableSet set];
    
    NSError *error = nil;
    ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];
    
    if (library)
    {
        //NSArray *playlists = library.allPlaylists; //  <- NSArray of ITLibPlaylist
        NSArray *items = library.allMediaItems; //  <- NSArray of ITLibMediaItem
        
        for (ITLibMediaItem *item in items)
        {
            NSNumber *pid = item.persistentID;
            [_ownedTracks setObject:item forKey:pid];
            
            NSString *trackKey = [self keyForArtist:item.artist.name andTrack:item.title];
            //[NSString stringWithFormat:@"%@ - %@", item.artist.name.lowercaseString, item.title.lowercaseString];
            [_ownedTrackKeys addObject:trackKey];
        }
    }
    
    //NSLog(@"_ownedTracks count = %i", (int)_ownedTracks.count);
    //NSLog(@"owned: %@", _ownedTracks);
}

- (BOOL)itunesLibraryHasSCTrack:(SCTrack *)scTrack
{
    [self ownedTracks]; // to make sure it's loaded
    
    NSString *trackKey = [self keyForArtist:scTrack.artistName andTrack:scTrack.trackName];
    return [_ownedTrackKeys containsObject:trackKey];
}

- (NSMutableArray *)unpurchasedSCTracks
{
    NSMutableArray *tracks = [NSMutableArray array];
    
    for (NSString *k in self.trackLikeDb.likedIds)
    {
        NSNumber *kn = [NSNumber numberWithInteger:[k integerValue]];
        
        SCTrack *track = [[SCTrack alloc] init];
        [track setTrackId:kn];
        [track loadDictIfNeeded];
        
        if (![self itunesLibraryHasSCTrack:track])
        {
            [tracks addObject:track];
        }
    }
    
    /*
    if (tracks.count)
    {
        SCTrack *track = [tracks objectAtIndex:0];
        NSLog(@"track 0 dict = %@", track.dict);
        NSLog(@"track 0 nodeTitle = %@", track.nodeTitle);
    }
    */
    
    return tracks;
}

@end
