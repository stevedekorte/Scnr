//
//  SCTrack
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import <NavKit/NavKit.h>
#import "SCLikable.h"

@class SCArtist;

@interface SCTrack : SCLikable

@property (weak, nonatomic) SCArtist *artist;

@property (strong, nonatomic) NSNumber *trackId;
@property (strong, nonatomic) NSDictionary *dict;

@property (strong, nonatomic) NSData *trackData;
@property (strong, nonatomic) NSURLSessionDataTask *task;

- (void)updateLikeStatus;


- (NSString *)artistName;
- (NSString *)collectionName;
- (NSNumber *)collectionId;
- (NSString *)trackName;

- (NSString *)fullName;

- (NSURL *)previewUrl;

//- (void)downloadDataAndTell:(id)target withAction:(SEL)action;
- (void)cancelDownload;

- (void)loadDictIfNeeded;

@end
