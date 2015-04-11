//
//  SCAlbum
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import "SCAlbum.h"
#import "SCArtist.h"
#import "SCTrack.h"
#import "SCTunesCache.h"

@implementation SCAlbum

- (id)init
{
    self = [super init];
    
    self.nodeSuggestedWidth = @250;
    
    self.nodeShouldSortChildren = @NO;
    

    self.tracks = [[NavInfoNode alloc] init];
    [self.tracks setNodeTitle:@"tracks"];
    [self addChild:self.tracks];
    
    self.similar = [[NavInfoNode alloc] init];
    [self.similar setNodeTitle:@"similar"];
    [self addChild:self.similar];
    
    return self;
}

- (NSString *)nodeTitle
{
    [self fetchDictIfNeeded];
    return self.collectionName;
}

- (NSString *)collectionName
{
    return [self.dict objectForKey:@"collectionName"];
}

- (NSString *)artistName
{
    return [self.dict objectForKey:@"artistName"];
}

- (NSString *)nodeNote
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)self.tracks.children.count];
}

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;
    
    [self setNodeTitle:[dict objectForKey:@"collectionName"]];
    [self setCollectionId:[self.dict objectForKey:@"collectionId"]];
    //[self setNodeSubtitle:[[dict objectForKey:@"releaseDate"] before:@"-"]];
    [self setNodeSubtitle:[NSString stringWithFormat:@"artist %@", self.artistName]];
}

- (void)nodeWillSelect
{
    [self loadSimilar];
}

- (NSURL *)albumLookupURL
{
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", self.collectionId];
    return [NSURL URLWithString:urlString];
}


- (void)fetchDictIfNeeded
{
    if (self.collectionId && !self.dict)
    {
        NSArray *results = [[SCTunesCache sharedTunesCache] syncResultsForUrl:self.albumLookupURL];
        
        //NSLog(@"results = %@", results);
        
        [self setDict:[results objectAtIndex:0]];
    }
}

// -------------------------------------

- (NSURL *)similarSearchURL
{
    // example: https://itunes.apple.com/us/album/id362862555
    
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/us/album/id%@", self.collectionId];
    
    NSLog(@"similarSearchURL %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (void)loadSimilar
{
    //[self fetchDictIfNeeded];

    [[SCTunesCache sharedTunesCache] asyncStringForUrl:self.similarSearchURL
                                                target:self
                                            withAction:@selector(parseSimilar:)];
}
        
- (void)parseSimilar:(NSString *)htmlString
{
    //NSLog(@"html %@", htmlString);
    
    NSString *s = [htmlString after:@"Listeners Also Bought"];
    s = [s after:@"TrackList"];

    NSMutableArray *artistIds = [NSMutableArray array];
    
    do
    {
        NSArray *parts = [s splitBetweenFirst:@"https://itunes.apple.com/us/artist/" andString:@"\""];
        
        if (parts.count == 3)
        {
            s = [parts objectAtIndex:2];
            
            NSNumber *artistId = [[[[parts objectAtIndex:1] after:@"/id"] before:@"#"] asNumber];
            
            if (artistId == nil)
            {
                NSLog(@"nil artist id error");
            }
            else
            {
                [self addSimilarArtistId:artistId];
            }
        }
        else
        {
            s = nil;
        }
    } while (s);
}

- (void)addSimilarArtistId:(NSNumber *)artistId
{
    SCArtist *artist = [[SCArtist alloc] init];
    [artist setArtistId:artistId];
    [artist fetchDictIfNeeded];
    
    //NSLog(@"%@ adding similar artist %@", self.collectionName, artistId);
    
    [self.similar addChild:artist];
    
    [NSNotificationCenter.defaultCenter postNotificationName:SCAlbumFoundSimilarArtist
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:artist forKey:@"artist"]];
    
    //NSLog(@"self.similar.children.count = %i", (int)self.similar.children.count);
}

/*
- (void)addMatchingTracks:(NSArray *)tracks
{
    for (SCTrack *track in tracks)
    {
        if ([[track collectionId] isEqual:self.collectionId])
        {
            // add check to see if it's absent before adding
            [self.tracks addChild:track];
        }
    }
}
*/

@end
