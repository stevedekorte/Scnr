//
//  SCAboutNode.h
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <NavKit/NavKit.h>
#import "SCArtists.h"
#import "SCUnpurchased.h"

@interface SCRootNode : NavInfoNode

+ (SCRootNode *)sharedSCRootNode;

@property (strong, nonatomic) SCArtists *artists;
@property (strong, nonatomic) SCUnpurchased *unpurchased;

@end
