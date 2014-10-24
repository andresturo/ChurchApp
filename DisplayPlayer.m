//
//  DisplayPlayer.m
//  RedilApp
//
//  Created by Daniel Cardona on 9/6/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "DisplayPlayer.h"

@interface DisplayPlayer ()
@property NSTimer* myTimer;

@end

@implementation DisplayPlayer

- (void)displayMyCurrentTime
{
    float timeInSeconds = CMTimeGetSeconds([self currentTime]);
    float durationInSeconds = CMTimeGetSeconds(self.currentItem.duration );
    int secs = ((int)timeInSeconds) % 60;
    int mins = (int)timeInSeconds / 60;
    
    float normalizedTime = timeInSeconds/durationInSeconds;
    NSString* timeString = [NSString stringWithFormat:@"%02i : %02i",mins,secs];
    
        [self.delegate displayPlayerWillDisplayNormalizedTime:normalizedTime];
        [self.delegate displayPlayerWillDisplayTextTime:timeString];
    
    
    
}

-(void)play{
    
    [super play];
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                  selector:@selector(displayMyCurrentTime)userInfo:nil repeats:YES];
    
    
}

-(void)pause{
    
    [super pause];
    [self.myTimer invalidate];
}

-(void)displayControlCenterSongInfo{
    
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    float timeInSeconds = CMTimeGetSeconds([self currentTime]);
    float durationInSeconds = CMTimeGetSeconds(self.currentItem.duration );
//    float timeInSeconds = self.currentTime.value;
//    float durationInSeconds = self.currentItem.duration.value;
    NSNumber* elapsedTime = [NSNumber numberWithDouble:timeInSeconds];
    NSNumber* duration = [NSNumber numberWithDouble:durationInSeconds];
    
    [songInfo setObject:_title forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:_artist forKey:MPMediaItemPropertyArtist];
    [songInfo setObject:duration forKey:MPMediaItemPropertyPlaybackDuration];
   // [songInfo setObject:releaseDate forKey:MPMediaItemPropertyReleaseDate];
    [songInfo setValue:[NSNumber numberWithDouble:1.0f] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
   [songInfo setObject:elapsedTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
   // [songInfo setObject:albumArtImage forKey:MPMediaItemPropertyArtwork];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
}
@end
