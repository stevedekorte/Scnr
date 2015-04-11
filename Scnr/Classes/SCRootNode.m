//
//  SCAboutNode.h
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import "SCRootNode.h"
#import "AppDelegate.h"
#import "SCAboutNode.h"

@implementation SCRootNode

static SCRootNode *sharedSCRootNode = nil;

+ (SCRootNode *)sharedSCRootNode
{
    if (sharedSCRootNode == nil)
    {
        sharedSCRootNode = [[self class] alloc];
        sharedSCRootNode = [sharedSCRootNode init]; // not safe
    }
    
    return sharedSCRootNode;
}

- (AppDelegate *)appDelegate
{
    return [[NSApplication sharedApplication] delegate];
}

- (id)init
{
    self = [super init];
    
    self.nodeShouldSortChildren = @NO;
    self.nodeTitle = @"Scnr";
    self.nodeSuggestedWidth = @150;
    
    [self setup];
    
    return self;
}

- nodeAbout
{
    return [[SCAboutNode alloc] init];
}

- (void)setup
{
    [self.appDelegate setNavTitle:@"setting up artists..."];

    self.artists = [[SCArtists alloc] init];
    [self addChild:self.artists];
    
    [self.artists doSearch];
    //[self.artists search:@"Polar Inertia"];
    
    self.unpurchased = [[SCUnpurchased alloc] init];
    [self addChild:self.unpurchased];
    
    [self addChild:[[SCAboutNode alloc] init]];

    
    [NSNotificationCenter.defaultCenter addObserver:self
                                             selector:@selector(willShutdown)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
    
    [self.appDelegate setNavTitle:@""];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}


- (void)willShutdown
{

}

@end
