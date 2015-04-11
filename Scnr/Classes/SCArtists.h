//
//  SCArtists
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import <NavKit/NavKit.h>

@interface SCArtists : NavInfoNode

- (void)doSearch;
- (void)search:(NSString *)artistName;
- (NSString *)searchString;
- (void)setSearchString:(NSString *)searchString;

@end
