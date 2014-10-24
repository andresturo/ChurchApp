//
//  DisplayPlayer.h
//  RedilApp
//
//  Created by Daniel Cardona on 9/6/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

@protocol DisplayPlayerDelegate;


@interface DisplayPlayer : AVPlayer
@property NSString* title;
@property NSString* artist;
@property id<DisplayPlayerDelegate> delegate;
-(void)displayControlCenterSongInfo;
@end

@protocol DisplayPlayerDelegate <NSObject>

@required
-(void)displayPlayerWillDisplayNormalizedTime:(float)time;
-(void)displayPlayerWillDisplayTextTime:(NSString*)time;
@end