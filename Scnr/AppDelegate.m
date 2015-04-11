//
//  AppDelegate.m
//  Scnr
//
//  Created by Steve Dekorte on 3/11/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "AppDelegate.h"
#import "SCRootNode.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching: (NSNotification *)aNote
{
    [super applicationDidFinishLaunching:aNote];
    
    NSLog(@"self.navWindow = %@", self.navWindow);
    
    [self setNavTitle:@"launching..."];

    [self setRootNode:[SCRootNode sharedSCRootNode]];
    
    
    [self showHelp];
}

- (void)showHelp
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    
    [alert setMessageText:@"How to use"];
    [alert setInformativeText:@"1. click on the search icon and enter an artist name\n2. use arrow keys to browse tracks by similar artists 3. hit 'x' to dislike, 'c' key to like a track\n4. double click a track to purchase"];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:self.navWindow
                      modalDelegate:self
                     didEndSelector:@selector(actionAlertDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (void)actionAlertDidEnd:(NSAlert *)alert
               returnCode:(NSInteger)returnCode
              contextInfo:(void *)contextInfo
{
    if (returnCode == 1000)
    {
        //[self justSendAction];
    }
    
}

@end
