//
//  SCTrackView
//  Scnr
//
//  Created by Steve Dekorte
//  Copyright (c) 2015 Steve Dekorte. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NavKit/NavKit.h>
#import "SCTrack.h"
#import <AVFoundation/AVFoundation.h>

@interface SCTrackView : NavColoredView <NSTextViewDelegate>

@property (assign, nonatomic) id navView;
@property (assign, nonatomic) NavNode *node; // node keeps a ref to us?

@property (strong, nonatomic) NavColoredView *innerView; // contains labels and checkbox

/*
@property (strong, nonatomic) NSTextView *artistField;
@property (strong, nonatomic) NSTextView *collectionField;
@property (strong, nonatomic) NSTextView *trackField;
*/

@property (strong, nonatomic) NSSound *sound;
@property (assign, nonatomic) BOOL shouldPlayOnDownload; // in case download finishes after stopping

@property (strong, nonatomic) NSProgressIndicator *progress;
@property (strong, nonatomic) AVPlayer *player;

- (SCTrack *)track;

- (void)setup;
- (void)prepareToDisplay;
- (void)syncFromNode;

@end
