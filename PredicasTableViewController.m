//
//  PredicasTableViewController.m
//  AVPlayerApp
//
//  Created by Daniel Cardona on 8/31/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "PredicasTableViewController.h"
#import "AudioTableViewCell.h"

@interface PredicasTableViewController ()
@property NSArray* predicas;
@property NSNumber* progressValue;
@property AudioTableViewCell* currentCell;
@property NSString* currentURL;
@property int selectedIndex;
@end

@implementation PredicasTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delaysContentTouches = YES;
    self.tableView.canCancelContentTouches = YES;
    
    self.player = [[DisplayPlayer alloc]init];
    self.player.delegate = self;

    [self fillFileLocation];
    
    // Turn on remote control event delivery ?should be in VC or in app delegate?
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [_player pause];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)fillFileLocation{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"URLPredicas" ofType:@"plist"];
    _predicas = [[NSArray alloc]initWithContentsOfFile:path];
   // NSLog(@"%@",_predicas);
    
    

    
    
}
#pragma mark DisplayPlayer Delegate Methods



-(void)displayPlayerWillDisplayNormalizedTime:(float)time{
    
    _currentCell.slider.value = time;
}

-(void)displayPlayerWillDisplayTextTime:(NSString *)time{
    
    _currentCell.timeProgress.text = time;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_predicas count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell" forIndexPath:indexPath];
   
    
    // Configure the cell...
    NSString* title = [_predicas objectAtIndex:indexPath.row][@"Nombre"];
    NSString* artist = [_predicas objectAtIndex:indexPath.row][@"Autor"];
    cell.title.text = title;
    cell.meta.text = artist;
    cell.playPauseButton.tag = indexPath.row;
    [cell.playPauseButton setTitle:@"Pause" forState:UIControlStateSelected];
    [cell.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    [cell.playPauseButton addTarget:self action:@selector(playStopAudio:) forControlEvents:UIControlEventTouchUpInside];
    [cell.slider addTarget:self action:@selector(sliderDragged:) forControlEvents:UIControlEventTouchDragInside];
    
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    _currentCell = (AudioTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    _selectedIndex = indexPath.row;
    //Configuring AVPlayer
    NSString* httpUrl = [_predicas objectAtIndex:indexPath.row][@"Url"];
    NSURL* url = [NSURL URLWithString:httpUrl];
    NSLog(@"Selected row: %i",indexPath.row);
    
    //Configure AVPlayer
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    
    if (!_player) {
        self.player = [[DisplayPlayer alloc]initWithPlayerItem:_playerItem];
    }
    if (_currentURL != httpUrl) {
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];

    }
    
    //Display in control center
    NSString* title = [_predicas objectAtIndex:indexPath.row][@"Nombre"];
    NSString* artist = [_predicas objectAtIndex:indexPath.row][@"Autor"];
    _player.title = title;
    _player.artist = artist;
    
    //[_player controlCenterSongInfoWithTitle:title artistName:artist];
    
    
    _currentURL = httpUrl;

    
}

#pragma mark IBActions

-(void)playStopAudio:(UIButton*)sender{

    NSLog(@"Button Tag: %i",sender.tag);
    NSIndexPath* path = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:path];
    
    
    if (sender.selected) {
        NSLog(@"Sender selected");
        [_player pause];

    }else {
        NSLog(@"Sender unselected");
        [_player play];

    }
   
    sender.selected = !sender.selected;

}

-(void)sliderDragged:(UISlider*)sender{
    
    CMTime seekTime = CMTimeMake(_player.currentItem.duration.value * sender.value, _player.currentItem.duration.timescale);
    
    [_player seekToTime:  seekTime];
    
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    NSString* httpUrl;
    NSURL* url;
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                //pause code here
                [_player pause];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                //play code here
                [_player play];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                // previous track code here
               
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                //next track code here
                _selectedIndex = _selectedIndex+1 % [ _predicas count];
                httpUrl = [self.predicas objectAtIndex:_selectedIndex][@"Url"];
                url = [NSURL URLWithString:httpUrl];
                self.playerItem = [AVPlayerItem playerItemWithURL:url];
                break;
                
            default:
                break;
        }
    }
}



/* ---------------------- Streaming in audio ---------------------------------
 
 NSURL *url = [NSURL URLWithString:@"http://predicasdelredil.org/predicas/2014/20140824_LUIS_SANIN_11.mp3"];
 
 // You may find a test stream at <http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8>.
 
 self.playerItem = [AVPlayerItem playerItemWithURL:url];
 
 //(optional) [playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
 
 self.player = [AVPlayer playerWithPlayerItem:_playerItem];
 
 self.player = [AVPlayer playerWithURL:url];
 
 
 //(optional) [player addObserver:self forKeyPath:@"status" options:0 context:&PlayerStatusContext];
 [self.player play];
 
 */


@end
