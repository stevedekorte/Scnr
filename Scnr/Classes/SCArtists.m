//
//  SCArtists
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import "SCArtists.h"
#import "SCTunesCache.h"
#import "SCArtist.h"

@implementation SCArtists

- (id)init
{
    self = [super init];
    self.nodeTitle = @"artists";
    self.nodeSuggestedWidth = @270;
    
    self.nodeShouldSortChildren = @NO;
    
    
    //[self addChild:self.rootRegion];

    return self;
}

- (void)read
{

}

- (void)write
{

}


- (void)delete
{
    return;
}

- (BOOL)canSearch
{
    return YES;
}

- (void)doSearch
{
    [self search:self.searchString];
}

- (NSString *)searchString
{
    NSString *s = [[NSUserDefaults standardUserDefaults] stringForKey:@"artistsSearch"];
    
    if (!s)
    {
        s = @"Depeche Mode";
    }
    
    return s;
}

- (void)setSearchString:(NSString *)searchString
{
    [[NSUserDefaults standardUserDefaults] setObject:searchString forKey:@"artistsSearch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)search:(NSString *)artistName
{
    [self setSearchString:artistName];
    
    NSString* escapedUrlString = [artistName
                                  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://itunes.apple.com/search?country=us&entity=musicArtist&term=%@",
                           escapedUrlString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error;
    NSString *jsonString = [NSString stringWithContentsOfURL:url
                                             encoding:NSUTF8StringEncoding
                                                error:&error];
    if (!error)
    {
        [self addNodesFromJsonString:jsonString];
    }
}

- (void)removeAllChildren
{
    for (NavNode *child in self.children.copy)
    {
        [self removeChild:child];
    }
}

/*
- (NavColumn *)navColumn
{
    NavColumn *navColumn = [self.navMirror.navView columnForNode:self];
    return navColumn;
}
*/

- (BOOL)addNodesFromJsonString:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    if (error)
    {
        return NO;
    }
    

    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *response = object;
        NSArray *results = [response objectForKey:@"results"];
        NSMutableArray *artists = [NSMutableArray array];
        
        for (NSDictionary *result in results)
        {
            //NSLog(@"result = %@", result);
            
            SCArtist *artist = [[SCArtist alloc] init];
            [artist setShouldInlineSimilar:YES];
            [artist setDict:result];
            
            if ([self.searchString isEqualToString:artist.artistName])
            {
                [artists addObject:artist];
                [artist loadTracks];
            }
        }
        
        [self setChildren:artists];
        [self postSelfChanged];
        
        return YES;
    }

    return NO;
}

- (BOOL)nodeSearchOnReturn
{
    return YES;
}

- (NSArray *)nodeSearchResults
{
    return self.children;
}

@end
