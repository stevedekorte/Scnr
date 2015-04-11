//
//  FileCache.m
//  Scnr
//
//  Created by Steve Dekorte on 3/26/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "FileCache.h"
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>

@implementation FileCache

- (id)init
{
    self = [super init];
    self.name = @"filecache";
    //self.ttlSeconds = 30*24*60*60; // 30 days
    return self;
}

- (NSString *)cacheFolder
{
    if (!_cacheFolder)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *appFolder = [fm applicationSupportDirectory]; // creates it
        _cacheFolder = [appFolder stringByAppendingPathComponent:self.name];
        
        BOOL isDir;
        NSError *error;
        
        if(![fm fileExistsAtPath:_cacheFolder isDirectory:&isDir])
        {
            if(![fm createDirectoryAtPath:_cacheFolder
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&error])
            {
                
            }
        }
    }
    
    return _cacheFolder;
}

- (NSString *)pathForKey:(NSString *)aKey
{
    return [self.cacheFolder stringByAppendingPathComponent:aKey];
}

- (NSString *)at:(NSString *)aKey
{
    [self expireIfNeededAt:aKey];
    
    NSString *path = [self pathForKey:aKey];
    NSError *error;
    NSString *result = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    return result;
}

- (BOOL)at:(NSString *)aKey put:(NSString *)aValue
{
    NSString *path = [self pathForKey:aKey];
    NSError *error;
    BOOL succeed = [aValue writeToFile:path
                             atomically:YES
                                encoding:NSUTF8StringEncoding
                                 error:&error];
    return succeed;
}

- (BOOL)removeAt:(NSString *)aKey
{
    NSString *path = [self pathForKey:aKey];
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm removeItemAtPath:path error:&error];
}

- (NSTimeInterval)ageAt:(NSString *)aKey
{
    NSString *path = [self pathForKey:aKey];
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attrs = [fm attributesOfItemAtPath:path error:&error];
    
    if (attrs != nil)
    {
        NSDate *creationDate = (NSDate *)[attrs objectForKey:NSFileCreationDate];
        NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:creationDate];
        return age;
    }
    
    return 0;
}

- (BOOL)expireIfNeededAt:(NSString *)aKey
{
    if (self.ttlSeconds && ([self ageAt:aKey] > self.ttlSeconds))
    {
        return [self removeAt:aKey];
    }
    
    return NO;
}

// dicts

- (NSMutableDictionary *)dictAt:(NSString *)aKey
{
    NSData *jsonData = [NSData dataWithContentsOfFile:[self pathForKey:aKey]];
    NSError *error;
    
    if (!jsonData)
    {
        return nil;
    }
    
    id jsonObject = [NSJSONSerialization
                     JSONObjectWithData:jsonData
                     options:NSJSONReadingMutableContainers
                     error:&error];
    
    if (error)
    {
        NSLog(@"JSON Parse Error: %@", [[error userInfo] objectForKey:@"NSDebugDescription"]);
        [NSException raise:@"JSON Parse Error" format:@""];
    }
    else
    {
        return (NSMutableDictionary *)jsonObject; // we used NSJSONReadingMutableContainers
    }
    
    return nil;
}

- (BOOL)at:(NSString *)aKey putDict:(NSDictionary *)aDict
{
    NSError *error;
    NSString *path = [self pathForKey:aKey];

    if (!aDict)
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        return YES;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:aDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    
    if (error)
    {
        NSLog(@"JSON Error: %@", [[error userInfo] objectForKey:@"NSDebugDescription"]);
        [NSException raise:@"JSON Error" format:@""];
    }
    else
    {
        return [data writeToFile:path atomically:YES];
    }
    
    return NO;
}

- (BOOL)at:(NSString *)aKey putIfAbsentDict:(NSDictionary *)aDict
{
    NSString *path = [self pathForKey:aKey];
    BOOL isDir;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
    {
        return [self at:aKey putDict:aDict];
    }
    
    return YES;
}


@end
