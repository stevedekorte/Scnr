//
//  JSONDB.m
//  Bitmessage
//
//  Created by Steve Dekorte on 3/17/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "JSONDB.h"
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>

@implementation JSONDB

/*
+ (NSMutableDictionary *)readDictWithName:(NSString *)aName
{
    JSONDB *db = [[JSONDB alloc] init];
    [db setName:aName];
    return [db dict];
}

+ (void)writeDict:(NSMutableDictionary *)dict withName:(NSString *)aName
{
    JSONDB *db = [[JSONDB alloc] init];
    [db setName:aName];
    [db setDict:dict];
    [db write];
}
*/

- (id)init
{
    self = [super init];
    _name = @"default";
    self.location = JSONDB_IN_SERVER_FOLDER;
    //self.dict = [NSMutableDictionary dictionary];
    return self;
}

- (void)setName:(NSString *)name
{
    _name = name;
}

- (NSString *)path
{
    NSString *fileName = [NSString stringWithFormat:@"%@.json", self.name];
    
    if ([_location isEqualToString:JSONDB_IN_APP_WRAPPER])
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:self.name ofType:nil];
        return path;
    }
    else if ([_location isEqualToString:JSONDB_IN_APP_SUPPORT_FOLDER])
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *folder = [fm applicationSupportDirectory];
        
        
        BOOL isDir;
        NSError *error;
        
        if(![fm fileExistsAtPath:folder isDirectory:&isDir])
        {
            if(![fm createDirectoryAtPath:folder
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&error])
            {
                
            }
        }
        
        NSString *path = [folder stringByAppendingPathComponent:fileName];
        return path;
    }

    [NSException raise:@"Invalid location" format:@"unknown location setting '%@'", _location];
    return nil;
}

- (NSDictionary *)dict
{
    if (!_dict)
    {
        [self read];
    }
    
    return _dict;
}

- (void)read
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path])
    {
        self.dict = [NSMutableDictionary dictionary];
        return;
    }
    
    NSData *jsonData = [NSData dataWithContentsOfFile:self.path];
    NSError *error;
    
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
        self.dict = (NSMutableDictionary *)jsonObject; // we used NSJSONReadingMutableContainers
    }
}

- (void)write
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    
    if (error)
    {
        NSLog(@"JSON Error: %@", [[error userInfo] objectForKey:@"NSDebugDescription"]);
        [NSException raise:@"JSON Error" format:@""];
    }
    else
    {
        [data writeToFile:self.path atomically:YES];
    }
}


@end
