//
//  SCTrackView
//  Scnr
//
//  Created by Steve Dekorte
//  Copyright (c) 2015 Steve Dekorte. All rights reserved.
//

#import "SCTrackView.h"
#import "SCTrack.h"
#import <NavKit/NavKit.h>
#import "SCTunesCache.h"

@implementation SCTrackView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];


    if (self)
    {
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];

        [self setup];
    }
    

    
    return self;
}

- (SCTrack *)track
{
    return (SCTrack *)self.node;
}

- (void)setup
{
    self.backgroundColor = [NSColor blackColor];
    
    //[self setThemePath:@"address/background"];
    
    self.innerView = [[NavColoredView alloc] initWithFrame:NSMakeRect(0, 0, self.width, self.height)];
    [self addSubview:self.innerView];
    [_innerView setAutoresizesSubviews:NO];
    
    self.progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 32, 128)];
    [self.progress setIndeterminate:YES];
    //[self.progress setStyle:NSProgressIndicatorSpinningStyle];
    [self.progress setStyle:NSProgressIndicatorBarStyle];
    [self.progress setUsesThreadedAnimation:YES];
    [self.progress setDisplayedWhenStopped:NO];
    //[self.progress setControlTint:NSGraphiteControlTint];
    [self.innerView addSubview:self.progress];
    
    /*
    self.artistField   = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, self.width/2, 24)];
    [self.innerView addSubview:self.artistField];
    [self.artistField setThemePath:@"track/artist"];
    [self.artistField centerXInSuperview];
    [self.artistField centerYInSuperview];
    [self.artistField setAutoresizingMask: NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin];
    [self.artistField setRichText:NO];
    
    self.collectionField   = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, self.width/2, 24)];
    [self.innerView addSubview:self.collectionField];
    [self.collectionField setThemePath:@"track/collection"];
    [self.collectionField centerXInSuperview];
    [self.collectionField centerYInSuperview];
    [self.collectionField setAutoresizingMask: NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin];
    [self.collectionField setRichText:NO];
    
    self.trackField = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, self.width/2, 16)];
    [_innerView addSubview:self.trackField];
    [self.trackField setThemePath:@"track/track"];
    [self.trackField centerXInSuperview];
    [self.trackField setY:self.artistField.maxY + 10];
    [self.trackField setAutoresizingMask: NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin];
    [self.trackField setRichText:NO];
    
    [self.artistField setTextColor:[NSColor colorWithCalibratedWhite:0.1 alpha:1.0]];
    */
    [self setPositions];
}

- (void)prepareToDisplay
{
    [self setPositions];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self setPositions];
    [self setPositions];
}

- (void)setPositions
{
    //[self.innerView setFrame:self.bounds];
    [self.innerView setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.innerView setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
    //[self.innerView centerXInSuperview];
    //[self.innerView centerYInSuperview];
    
    /*
    [self.artistField setX:0];
    [self.artistField setY:0];
    [self.artistField setWidth:self.width];
 
    [self.collectionField setX:0];
    [self.collectionField placeYBelow:self.artistField margin:10];
    [self.collectionField setWidth:self.width];
    
    [self.trackField setX:0];
    [self.trackField placeYBelow:self.collectionField margin:10];
    [self.trackField setWidth:self.width];
    
    [self.innerView sizeAndRepositionSubviewsToFit];
    [self.innerView setWidth:self.width];
    //[self.innerView centerSubviewsX];
    [self.artistField centerXInSuperview];
    */
    [self.progress centerXInSuperview];
    [self.progress centerYInSuperview];
    /*
    if (self.player)
    {
        [self.player centerXInSuperview];
        [self.player centerYInSuperview];
    }
     */
    
    [self.innerView centerYInSuperview];
}

- (void)setNode:(NavNode *)node
{
    _node = node;
    [self syncFromNode];
}

- (void)syncFromNode
{
    //[self.artistField setString:@"▶"];
    
    //[self.artistField setString:[self.track artistName]];
    //[self.collectionField setString:[self.track collectionName]];
    //[self.trackField setString:[self.track trackName]];
    
}

/*
- (void)viewDidMoveToSuperview
{
    if (self.superview)
    {
        if (!self.track.trackData)
        {
            [self startDownload];
        }
        else
        {
            [self play];
        }
    }
}
*/

- (void)prepareToPlay
{
    if (!self.player)
    {
        //AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.track.previewUrl];
        //self.player = [AVPlayer playerWithPlayerItem:playerItem];
        //[playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

        self.player = [[AVPlayer alloc] initWithURL:self.track.previewUrl];

    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    //if (object == _player && [keyPath isEqualToString:@"status"])
    {
        if (_player.status == AVPlayerStatusReadyToPlay)
        {
            //[playingLbl setText:@"Playing Audio"];
            NSLog(@"prerolling to play %@ at rate %f", self.track.trackName, self.player.rate);
//            [playBtn setEnabled:YES];
            
            [self.player prerollAtRate:self.player.rate
                    completionHandler:^(BOOL finished) {}];
        }
        /*
         else if (_player.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
            NSLog(@"not fineee");
            NSLog(@"%@",player.error);
            
        }
        else if (_player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
            
        }
        */
    }
}

- (void)viewDidMoveToSuperview
{
    if (self.superview)
    {
        if (!self.player)
        {
            [self prepareToPlay];
            
            //NSArray *tracks = self.track.artist.tracks.children;
            
            /*
            NSInteger index = [tracks indexOfObject:self.track];
            
            if (index < tracks.count - 1)
            {
                SCTrack *nextTrack = [tracks objectAtIndex:index + 1];
                SCTrackView *nextTrackView = (SCTrackView *)nextTrack.nodeView;
                [nextTrackView prepareToPlay];
            }
            */
            
            /*
            NavColumn *navColumn = [self.navView columnForNode:node];
            
            SCTrack *track = (SCTrack *)(navColumn.nextRowObject);
            [(SCTrackView *)track.nodeView prepareToPlay];
             */
            
          // [self.superview.window makeFirstResponder:self];

        }

        [self.player seekToTime:CMTimeMake(10,1)];
        [self.player play];
    }
}

- (void)stop
{
    [self.player pause];
    [self.player cancelPendingPrerolls];
}

/*

- (void)startDownload
{
    [self.track downloadDataAndTell:self withAction:@selector(downloadComplete)];
    self.shouldPlayOnDownload = YES;
    [self.progress startAnimation:self];
}

- (void)downloadComplete
{
    [self performSelectorOnMainThread:@selector(justDownloadComplete) withObject:nil waitUntilDone:NO];
}

- (void)justDownloadComplete
{
    [self.progress stopAnimation:self];

    self.sound = [[NSSound alloc] initWithData:self.track.trackData];
    if (self.shouldPlayOnDownload)
    {
        [self play];
        self.shouldPlayOnDownload = NO;
    }
}

- (void)play
{
    [self.sound setCurrentTime:(NSTimeInterval)10.0];
    [self.sound play];
}

- (void)stop
{
    [self.progress stopAnimation:self];
    
    self.shouldPlayOnDownload = NO;
    [self.sound stop];
    [self.track cancelDownload];
}
*/

- (void)removeFromSuperview
{
    [self stop];
    [super removeFromSuperview];
}


// key down

- (BOOL)acceptsFirstResponder
{
    return NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *c = theEvent.characters;
    
    //[self.nodeParent.view ]
    NSLog(@"track view key down '%@'", theEvent.characters);
    
    if ([c isEqualToString:@"c"])
    {
        [self.track like];
        [self.track.artist updateLikeStatus];
        [self selectNext];
    }
    else if ([c isEqualToString:@"x"])
    {
        [self.track dislike];
        [self.track.artist updateLikeStatus];
        [self selectNext];
    }
    else if ([c isEqualToString:@"X"])
    {
        [self.track.artist dislikeAllTracks];
        [self.track.artist updateLikeStatus];
    }
    
    /*
    else if ([c isEqualToString:@"C"])
    {
        [self.track.artist like];
    }
    */
}

- (void)selectNext
{
    NavColumn *navColumn = (NavColumn *)self.superview;
    NavColumn *tracksColumn = [navColumn.navView columnBeforeColumn:navColumn];

    if (tracksColumn)
    {
        //NSLog(@"previousColumn %@", previousColumn);
        if (![tracksColumn selectNextRow])
        {
            NavColumn *artistsColumn = [tracksColumn previousColumn];
            if (artistsColumn)
            {
                [tracksColumn selectPreviousColumn];
                [artistsColumn selectNextRow];
            }
        }
    }
}

- (void)nodeDoubleClick
{
    [self stop];
    [self openInStore];
}

- (void)openInStore
{
    NSString *iTunesLink = [self.track.dict objectForKey:@"trackViewUrl"];
    iTunesLink = [iTunesLink stringByReplacingOccurrencesOfString:@"https:" withString:@"itms:"];
    
    //    NSString *iTunesLink = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/apple-store/id%@?mt=8",
    //    NSString *iTunesLink = [NSString stringWithFormat:@"itms://itunes.apple.com/us/app/apple-store/id%@?mt=8",
  //                          self.track.trackId];
    NSLog(@"iTunesLink %@", iTunesLink);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:iTunesLink]];
    
}

@end

/*
 self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
 [self.audioPlayer prepareToPlay];
 //[self.audioPlayer playAtTime:(NSTimeInterval)0.0];
 [self.audioPlayer play];
 */
