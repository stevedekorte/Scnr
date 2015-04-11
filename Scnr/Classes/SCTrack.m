//
//  SCArtist
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import "SCTrack.h"
#import <NavKit/NavKit.h>
#import "SCTunesCache.h"

@implementation SCTrack

- (id)init
{
    self = [super init];
    self.nodeSuggestedWidth = @350;
    self.nodeShouldSortChildren = @NO;
    
    //[self addChild:self.rootRegion];

    return self;
}

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;
    
    [self setTrackId:[dict objectForKey:@"trackId"]];
    [self setNodeTitle:[dict objectForKey:@"trackName"]];
    //[self setNodeSubtitle:[dict objectForKey:@"collectionName"]];
    //[self setNodeSubtitle:@"track"];
    [self updateLikeStatus];
    
    if ([self isOwned])
    {
        [self like];
        [self setNodeSubtitle:@"owned"];
    }
    
   // NSLog(@"track dict: %@", dict);
    
    [SCTunesCache.sharedTunesCache.trackCache at:[NSString stringWithFormat:@"%@", self.trackId] putIfAbsentDict:dict];
}

- (BOOL)isOwned
{
    return [SCTunesCache.sharedTunesCache itunesLibraryHasSCTrack:self];
    //return [SCTunesCache.sharedTunesCache itunesLibraryHasTrackId:self.trackId];
}

- (NSString *)artistName
{
    return [self.dict objectForKey:@"artistName"];
}

- (NSString *)collectionName
{
    return [self.dict objectForKey:@"collectionName"];
}

- (NSNumber *)collectionId
{
    return [self.dict objectForKey:@"collectionId"];
}

- (NSString *)trackName
{
    return [self.dict objectForKey:@"trackName"];
}

- (void)loadDictIfNeeded
{
    if (!self.dict)
    {
        NSDictionary *dict = [SCTunesCache.sharedTunesCache.trackCache dictAt:[NSString stringWithFormat:@"%@", self.trackId]];
        
        if (dict)
        {
            [self setDict:dict];
            return;
        }
        
        NSString *s = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", self.trackId];
        NSURL *url = [NSURL URLWithString:s];
        
        NSString *dataString = [SCTunesCache.sharedTunesCache syncStringForUrl:url];
        NSError *error;
        id jsonObject = [NSJSONSerialization
                         JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding]
                         options:NSJSONReadingMutableContainers
                         error:&error];
        dict = [[jsonObject objectForKey:@"results" ] objectAtIndex:0];
        [self setDict:dict];
    }
    
}

- (NSURL *)previewUrl
{
    NSString *urlString = [self.dict objectForKey:@"previewUrl"];
    return [NSURL URLWithString:urlString];
}

/*
- (void)downloadDataAndTell:(id)target withAction:(SEL)action
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    self.task = [session dataTaskWithURL:self.previewUrl
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
            {
                _trackData = data;
                [target performSelector:action];
                self.task = nil;
                
            }];
    
    [self.task resume];
}
*/

- (void)cancelDownload
{
    if (self.task)
    {
        [self.task cancel];
    }
}

- (LikeDB *)likeDb
{
    return SCTunesCache.sharedTunesCache.trackLikeDb;
}

- (NSString *)likeId
{
    return [NSString stringWithFormat:@"%@", self.trackId];
}

/*
- (BOOL)isRead
{
    return [self isDisliked];
}
*/

- (void)nodeDoubleClick
{
    [(id)self.nodeView nodeDoubleClick];
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ - %@", self.artistName, self.trackName];
}

@end
