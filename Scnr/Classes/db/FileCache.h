//
//  FileCache.h
//  Scnr
//
//  Created by Steve Dekorte on 3/26/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *cacheFolder;
@property (assign, nonatomic) NSTimeInterval ttlSeconds;

- (NSString *)pathForKey:(NSString *)aKey;
- (NSString *)at:(NSString *)aKey;
- (BOOL)at:(NSString *)aKey put:(NSString *)aValue;
- (BOOL)removeAt:(NSString *)aKey;

- (NSMutableDictionary *)dictAt:(NSString *)aKey;
- (BOOL)at:(NSString *)aKey putDict:(NSDictionary *)aDict;
- (BOOL)at:(NSString *)aKey putIfAbsentDict:(NSDictionary *)aDict;

@end
