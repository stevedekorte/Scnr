//
//  SCAboutNode.h
//  Scnr
//
//  Created by Steve Dekorte .
//  Copyright (c) Steve Dekorte. All rights reserved.
//

#import "SCAboutNode.h"

@implementation SCAboutNode


- (id)init
{
    self = [super init];
    
    self.nodeShouldSortChildren = @NO;
    self.nodeTitle = @"Scnr";
    self.nodeSubtitle = self.versionString;
    self.nodeSuggestedWidth = @150;
    
    [self addAbout];
    
    return self;
}

- (id)nodeRoot
{
    return nil;
}

- (id)nodeAbout
{
    return nil;
}

- (NSArray *)aboutNodes
{
    NSArray *allBundles = [NSBundle.allBundles arrayByAddingObjectsFromArray:NSBundle.allFrameworks];
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSBundle *bundle in allBundles)
    {
        NSLog(@"bundle: '%@'", bundle.bundleIdentifier);
        NSString *bundleClassName = [bundle.bundleIdentifier componentsSeparatedByString:@"."].lastObject;
        Class bundleClass = NSClassFromString(bundleClassName);
        
        if (bundleClass && [bundleClass respondsToSelector:@selector(nodeRoot)])
        {
            id bundleNode = [bundleClass nodeRoot];
            if ([bundleNode respondsToSelector:@selector(nodeAbout)])
            {
                [results addObject:[bundleNode nodeAbout]];
            }
        }
        
    }
    
    return results;
}

- (NSString *)versionString
{
    NSDictionary *info = [NSBundle bundleForClass:[self class]].infoDictionary;
    NSString *versionString = [info objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"version %@", versionString];
}

- (void)addAbout
{
    NavInfoNode *root = self;
    
/*
    NavInfoNode *help = [[NavInfoNode alloc] init];
    [root addChild:help];
    help.nodeTitle = @"Help";
    help.nodeSuggestedWidth = @500;
    help.nodeShouldSortChildren = @NO;
    */
    
    {
        /*
        NavInfoNode *version = [[NavInfoNode alloc] init];
        version.nodeTitle = @"Version";
        version.nodeSubtitle = self.versionString;
        [root addChild:version];
        */
        
        /*
        NavInfoNode *legal = [[NavInfoNode alloc] init];
        [root addChild:legal];
        legal.nodeTitle = @"Legal";
        legal.nodeSuggestedWidth = @200;
        */
        
        NavInfoNode *contributors = [[NavInfoNode alloc] init];
        [root addChild:contributors];
        contributors.nodeTitle = @"Credits";
        contributors.nodeSuggestedWidth = @200;
        contributors.nodeShouldSortChildren = @NO;
        
        
        {
            NavInfoNode *contributor = [[NavInfoNode alloc] init];
            contributor.nodeTitle = @"Steve Dekorte";
            contributor.nodeSubtitle = @"Developer";
            [contributors addChild:contributor];
        }
        
        /*
        NavInfoNode *others = [[NavInfoNode alloc] init];
        [contributors addChild:others];
        others.nodeTitle = @"3rd Party";
        others.nodeSuggestedWidth = @200;
        others.nodeShouldSortChildren = @NO;
         */
    }
}

@end
