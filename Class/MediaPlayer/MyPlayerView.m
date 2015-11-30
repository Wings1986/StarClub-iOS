//
//  MyPlayerView.m
//  StarClub
//
//  Created by MAYA on 1/3/14.
//
//

#import "MyPlayerView.h"

#import <AVFoundation/AVAudioPlayer.h>
#import "AudioStreamer.h"

#import "UIImage+animatedGIF.h"

#import "SVPullToRefresh.h"
#import "StarTracker.h"
#import "Base64.h"



/* TOOLBAR   */

#define BTN_CLOSE_X     58
#define BTN_CLOSE_Y     4
#define BTN_CLOSE_WIDTH  52
#define BTN_CLOSE_HEIGHT  30

/* DETAIL   */
#define DETAIL_WIDTH    320
#define DETAIL_HEIGHT   102

#define IMAGE_X         30
#define IMAGE_Y         5
#define IMAGE_WIDTH     90
#define IMAGE_HEIGHT     90

#define LABEL_WIDTH         134
#define LABEL_HEIGHT         25

#define LABEL_PLAYING_X     150
#define LABEL_PLAYING_Y     8
#define LABEL_TITLE_X     150
#define LABEL_TITLE_Y     32

#define BTN_ITUNES_X    150
#define BTN_ITUNES_Y    64
#define BTN_ITUNES_WIDTH    128
#define BTN_ITUNES_HEIGHT    30

/* PLAY BAR */
#define PLAYBAR_WIDTH   320
#define PLAYBAR_HEIGHT  38

#define PLAY_BTN_WIDTH  45
#define PLAY_BTN_HEIGHT 30

#define BTN_PREV_X  16
#define BTN_PREV_Y  3

#define BTN_PAUSE_X  135
#define BTN_PAUSE_Y  3

#define BTN_NEXT_X  253
#define BTN_NEXT_Y  3


@interface MyPlayerView ()<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>
{
    UIButton * btnClose;
    
    UIImageView * ivVolumn;
    UIImageView * ivImage;
    UILabel * lbPlayState;
    UILabel * lbTitle;
    UIButton * btnPrev;
    UIButton * btnPlay;
    UIButton * btnNext;
    
    NSMutableArray * arrList;
    
    int nSelMusic;
    
    BOOL bOpened;
    BOOL bPlaying;
    
    AVAudioPlayer * audioPlayer;
//    AudioStreamer *streamer;

    
    BOOL bCanNotOpen;

}

@property (nonatomic, strong)     UITableView * tbList;

@property (nonatomic, assign) int   nFrameOriginY;


@end

@implementation MyPlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.nFrameOriginY = frame.origin.y;
        
        nSelMusic = -1;
        bOpened = NO;
        bPlaying = NO;
        
        bCanNotOpen = NO;
        
        [self setInterface];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#ifdef TARGET_OS_IPHONE
//
// MyAudioSessionInterruptionListener
//
// Invoked if the audio session is interrupted (like when the phone rings)
//

void MyAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	if (inInterruptionState == kAudioSessionBeginInterruption) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"stopstreamer" object:nil];
		NSLog(@"kAudioSessionBeginInterruption");
	}
	
	else if (inInterruptionState == kAudioSessionEndInterruption) {
		
	    [[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
		NSLog(@"kAudioSessionEndInterruption");
	}
	
}
#endif

-(void) setChangeInterface:(BOOL) bLandscape
{
    if (bLandscape) {
        bCanNotOpen = YES;
    } else {
        bCanNotOpen = NO;
    }

    btnClose.frame = CGRectMake(self.frame.size.width-BTN_CLOSE_X, BTN_CLOSE_Y, BTN_CLOSE_WIDTH, BTN_CLOSE_HEIGHT);
}

-(void) setInterface
{
    UIFont * font = [UIFont fontWithName:FONT_NAME size:14.0f];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose)];
    singleTap.numberOfTapsRequired = 1;
//    singleTap.delegate = self;
    
    
    ///////// toolbar
    UIView * viewToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width*2, TOOLBAR_HEIGHT)];
    viewToolbar.userInteractionEnabled = YES;
    [viewToolbar addGestureRecognizer:singleTap];
    
    
    
    UIImageView * ivToolbarBack = [[UIImageView alloc] initWithFrame:viewToolbar.frame];
    [ivToolbarBack setImage:[UIImage imageNamed:@"media_toolbar"]];
    [viewToolbar addSubview:ivToolbarBack];
    
    ivVolumn = [[UIImageView alloc] initWithFrame:CGRectMake(7, 5, 25, 25)];
    [ivVolumn setImage:[UIImage imageNamed:@"media_volume_nor"]];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"media_volume" withExtension:@"gif"];
//    ivVolumn.image = [UIImage animatedImageWithAnimatedGIFURL:url];

    [viewToolbar addSubview:ivVolumn];
    
    
    btnClose = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-BTN_CLOSE_X, BTN_CLOSE_Y, BTN_CLOSE_WIDTH, BTN_CLOSE_HEIGHT)];
    [btnClose setImage:[UIImage imageNamed:@"media_btn_open"] forState:UIControlStateNormal];
//    [btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    btnClose.titleLabel.font = font;
    [btnClose addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [viewToolbar addSubview:btnClose];
    
    [self addSubview:viewToolbar];
    
    /////////// Details
    UIView * viewDetail = [[UIView alloc] initWithFrame:CGRectMake(0, TOOLBAR_HEIGHT, DETAIL_WIDTH, DETAIL_HEIGHT)];
    viewDetail.backgroundColor = [UIColor whiteColor];
    
    ivImage = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGE_X, IMAGE_Y, IMAGE_WIDTH, IMAGE_HEIGHT)];
    [ivImage setImage:[UIImage imageNamed:@"login_logo"]];
    [viewDetail addSubview:ivImage];
    
    lbPlayState = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_PLAYING_X, LABEL_PLAYING_Y, LABEL_WIDTH, LABEL_HEIGHT)];
    lbPlayState.font = font;
    lbPlayState.text = @"Now Pause";
    [viewDetail addSubview:lbPlayState];

    lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_TITLE_X, LABEL_TITLE_Y, LABEL_WIDTH, LABEL_HEIGHT)];
    lbTitle.font = [UIFont fontWithName:@"Helvetica Neue Medium" size:14.0f];
    lbTitle.text = @"Solo De";
    [viewDetail addSubview:lbTitle];

    UIButton * btnItunes = [[UIButton alloc] initWithFrame:CGRectMake(BTN_ITUNES_X, BTN_ITUNES_Y, BTN_ITUNES_WIDTH, BTN_ITUNES_HEIGHT)];
    [btnItunes setImage:[UIImage imageNamed:@"media_btn_itunes"] forState:UIControlStateNormal];
    [btnItunes addTarget:self action:@selector(onITunes) forControlEvents:UIControlEventTouchUpInside];
    [viewDetail addSubview:btnItunes];
    
    [self addSubview:viewDetail];
    
    /// play bar
    UIView * viewPlayBar = [[UIView alloc] initWithFrame:CGRectMake(0, TOOLBAR_HEIGHT + DETAIL_HEIGHT, PLAYBAR_WIDTH, PLAYBAR_HEIGHT)];
    
    UIImageView * ivBarBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PLAYBAR_WIDTH, PLAYBAR_HEIGHT)];
    [ivBarBack setImage:[UIImage imageNamed:@"media_playbar"]];
    [viewPlayBar addSubview:ivBarBack];
    
    btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(BTN_PREV_X, BTN_PREV_Y, PLAY_BTN_WIDTH, PLAY_BTN_HEIGHT)];
    [btnPrev setImage:[UIImage imageNamed:@"media_btn_prev"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onPrev) forControlEvents:UIControlEventTouchUpInside];
    [viewPlayBar addSubview:btnPrev];

    btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(BTN_PAUSE_X, BTN_PAUSE_Y, PLAY_BTN_WIDTH, PLAY_BTN_HEIGHT)];
    [btnPlay setImage:[UIImage imageNamed:@"media_btn_play"] forState:UIControlStateNormal];
    [btnPlay addTarget:self action:@selector(onPlayPause) forControlEvents:UIControlEventTouchUpInside];
    [viewPlayBar addSubview:btnPlay];

    btnNext = [[UIButton alloc] initWithFrame:CGRectMake(BTN_NEXT_X, BTN_NEXT_Y, PLAY_BTN_WIDTH, PLAY_BTN_HEIGHT)];
    [btnNext setImage:[UIImage imageNamed:@"media_btn_next"] forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [viewPlayBar addSubview:btnNext];

    [self addSubview:viewPlayBar];
    
    
    int originY = TOOLBAR_HEIGHT+DETAIL_HEIGHT+PLAYBAR_HEIGHT;
    self.tbList = [[UITableView alloc] initWithFrame:CGRectMake(0, originY, 320, self.frame.size.height-originY)];
    self.tbList.delegate = self;
    self.tbList.dataSource = self;
    [self addSubview:self.tbList];
    
    __weak MyPlayerView *weakSelf = self;
    
    // setup pull-to-refresh
    [self.tbList addPullToRefreshWithActionHandler:^{
            [weakSelf startRefresh];
    }];

    [self getMusicList];
}

-(void)getMusicList{
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
    
    NSString * urlString = [MyUrl getMusics];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
//    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        
        arrList = [result objectForKey:@"musics"];
        
        
        [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
        
        if ([arrList count] != 0) {
            nSelMusic = 0;
            [self.tbList selectRowAtIndexPath:[NSIndexPath indexPathForRow:nSelMusic inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];

//            [self setMusic:0];
        }
    }
    else {
        NSLog(@"push fail");
    }
    
}
#pragma mark ---- button event ---------
-(void) onClose
{
    if (bCanNotOpen) {
        return;
    }
    
    if (bOpened) {
        // close
        [StarTracker StarSendView:@"Music Play Close"];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.frame = CGRectMake(self.frame.origin.x, self.nFrameOriginY, self.frame.size.width, self.frame.size.height);
        
        [UIView commitAnimations];

        [btnClose setImage:[UIImage imageNamed:@"media_btn_open"] forState:UIControlStateNormal];
        
        bOpened = NO;
    }
    else {
        // open
        [StarTracker StarSendView:@"Music Play Open"];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        int pointY = self.frame.origin.y - self.frame.size.height + TOOLBAR_HEIGHT;
        self.frame = CGRectMake(self.frame.origin.x, pointY, self.frame.size.width, self.frame.size.height);
        
        [UIView commitAnimations];

        [btnClose setImage:[UIImage imageNamed:@"media_btn_close"] forState:UIControlStateNormal];

        bOpened = YES;
    }
}
-(void) onITunes
{
    NSDictionary * music = [arrList objectAtIndex:nSelMusic];
    NSString * urlString = [music objectForKey:@"url"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
}
-(void) onPrev
{
    int nMusic = nSelMusic == 0 ? 0 : nSelMusic -1;
    [self setMusic:nMusic];
}
-(void) onNext
{
    int nMusic = nSelMusic == (int)[arrList count]-1 ? (int)[arrList count]-1 : nSelMusic +1;
    [self setMusic:nMusic];
}
-(void) onPlayPause
{
//    bPlaying = !bPlaying;
    
    if (bPlaying == NO) {
        
        [StarTracker StarSendEvent:@"App Event" :@"Music Play" :@"Started"];
        
//        lbPlayState.text = @"Now Playing...";
//        [btnPlay setImage:[UIImage imageNamed:@"media_btn_pause"] forState:UIControlStateNormal];

        [NSThread detachNewThreadSelector: @selector(onplay) toTarget:self withObject:nil];
    }
    else {
        
        [StarTracker StarSendEvent:@"App Event" :@"Music Play" :@"Paused"];

        [self stopMusic];
        
//        lbPlayState.text = @"Now Pause";
//        [btnPlay setImage:[UIImage imageNamed:@"media_btn_play"] forState:UIControlStateNormal];

//		[streamer stop];
//        if (audioPlayer != nil) {
//            [audioPlayer pause];
//            
//            lbPlayState.text = @"Now Pause";
//        }
        
    }
}

BOOL     m_bLetPlay = NO;

-(void) onplay
{

    [self stopMusic];

    [self letPlayDelegate];
    
//    if (bPlaying == NO) {
//        [self letPlayDelegate];
//        return;
//    }
//    
//    m_bLetPlay = YES;
}

-(void) letPlayDelegate
{
    m_bLetPlay = NO;
    NSDictionary * music = [arrList objectAtIndex:nSelMusic];
    NSString * destination = [music objectForKey:@"destination"];
    [self playMusic:destination];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    NSDictionary * music = [arrList objectAtIndex:indexPath.row];
    
	cell.textLabel.text = [music objectForKey:@"title"];
    cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:14.0f];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self setMusic:(int)indexPath.row];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)startRefresh {
    [self getMusicList];
}

- (void)startMoreLoad {
    
}
- (void) doneLoadingTableViewData
{
    __weak MyPlayerView *weakSelf = self;
    
    [weakSelf.tbList reloadData];
    
    [weakSelf.tbList.pullToRefreshView stopAnimating];

}


- (void) setMusic:(int) nIndex
{
    
    if (nIndex >= (int)[arrList count] || nIndex < 0) {
        return;
    }
    
    nSelMusic = nIndex;
    
    NSDictionary * music = [arrList objectAtIndex:nIndex];
    
    
    
    lbTitle.text = [music objectForKey:@"title"];

    NSString * imageUrl = [music objectForKey:@"image_path"];
    [DLImageLoader loadImageFromURL:imageUrl
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  UIImage * image = [UIImage imageWithData:imgData];
                                  [ivImage setImage:image];
                              }
                          }];
    
    [self.tbList selectRowAtIndexPath:[NSIndexPath indexPathForRow:nIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    if (!bPlaying) {
        return;
    }
    
    [NSThread detachNewThreadSelector: @selector(onplay) toTarget:self withObject:nil];
}

-(void) stopMusic
{
    if (audioPlayer != nil && [audioPlayer isPlaying]) {
        [audioPlayer stop];
    }
    
    [ivVolumn setImage:[UIImage imageNamed:@"media_volume_nor"]];
    lbPlayState.text = @"Now Pause";
    [btnPlay setImage:[UIImage imageNamed:@"media_btn_play"] forState:UIControlStateNormal];

    bPlaying = NO;
}
-(void) playMusic:(NSString * ) fileName
{
//    [self stopMusic];
    
    [self performSelectorOnMainThread:@selector(refreshPlayingText:) withObject:@"Now Loading..." waitUntilDone:YES];

    NSURL *url = [NSURL URLWithString:fileName];
    NSData *soundData = [NSData dataWithContentsOfURL:url];
    audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData  error:NULL];
    audioPlayer.delegate = self;
    audioPlayer.numberOfLoops = -1;
    [audioPlayer prepareToPlay];
    [audioPlayer play];

    [self performSelectorOnMainThread:@selector(refreshPlayingText:) withObject:@"Now Playing..." waitUntilDone:YES];
    
    NSURL *urlGit = [[NSBundle mainBundle] URLForResource:@"media_volume" withExtension:@"gif"];
    ivVolumn.image = [UIImage animatedImageWithAnimatedGIFURL:urlGit];
    [btnPlay setImage:[UIImage imageNamed:@"media_btn_pause"] forState:UIControlStateNormal];
    bPlaying = YES;
}

-(void) refreshPlayingText:(NSString*) text
{
    lbPlayState.text = text;
}
/*
- (void)killaudio
{
	[streamer setDelegate:self];
	[streamer stop];
	NSLog(@"Stop");
}

- (void) stopMusic
{
    if (streamer != nil) {
        [streamer stop];
    }
}



-(void) playMusic:(NSString *) fileName
{
//    if (bPlaying == NO) {
//        return;
//    }
    
    if (fileName == nil && fileName.length < 1) {
        return;
    }
    
    
    NSString *base64String = [fileName base64EncodedString];
    
    [StarTracker StarSendEvent:@"App Event" :@"Music Play" :base64String];
    
    
//    if (audioPlayer != nil && [audioPlayer isPlaying]) {
//        [audioPlayer stop];
//    }
//    
//    lbPlayState.text = @"Now Loading...";
//    
//    NSURL *url = [NSURL URLWithString:fileName];
//    NSData *soundData = [NSData dataWithContentsOfURL:url];
//    audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData  error:NULL];
//    audioPlayer.delegate = self;
//    audioPlayer.numberOfLoops = -1;
//    [audioPlayer prepareToPlay];
//    [audioPlayer play];
//    
//    lbPlayState.text = @"Now Playing...";

    
    NSURL *url = [NSURL URLWithString:fileName];
    streamer = [[AudioStreamer alloc] initWithURL:url];
    [streamer   addObserver:self
                 forKeyPath:@"isPlaying"
                    options:0
                    context:nil];
    
    [streamer setDelegate:self];
//    [streamer setDidUpdateMetaDataSelector:@selector(metaDataUpdated:)];
    [streamer setDidErrorSelector:@selector(streamError)];
    [streamer setDidDetectBitrateSelector:@selector(bitrateUpdated:)];
    
    [streamer start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		@autoreleasepool {
		
            if ([(AudioStreamer *)object isPlaying])
            {
//                lbPlayState.text = @"Now Playing";
//                [btnPlay setImage:[UIImage imageNamed:@"media_btn_pause"] forState:UIControlStateNormal];
                
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"media_volume" withExtension:@"gif"];
                ivVolumn.image = [UIImage animatedImageWithAnimatedGIFURL:url];
                
                lbPlayState.text = @"Now Playing...";
                [btnPlay setImage:[UIImage imageNamed:@"media_btn_pause"] forState:UIControlStateNormal];

                bPlaying = YES;
            }
            else
            {
                [streamer removeObserver:self forKeyPath:@"isPlaying"];
                streamer = nil;
                
//                lbPlayState.text = @"Now Pause";
//                [btnPlay setImage:[UIImage imageNamed:@"media_btn_play"] forState:UIControlStateNormal];

                [ivVolumn setImage:[UIImage imageNamed:@"media_volume_nor"]];
                
                lbPlayState.text = @"Now Pause";
                [btnPlay setImage:[UIImage imageNamed:@"media_btn_play"] forState:UIControlStateNormal];

                bPlaying = NO;
                
                if (m_bLetPlay) {
                    [self letPlayDelegate];
                }
            }
        }

		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}

- (void)streamError
{
	NSLog(@"Stream Error.");
}

- (void)bitrateUpdated:(NSNumber *)br
{
    lbPlayState.text = @"Now Playing";
}
*/

//- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
//{
//    NSLog(@"Start Playing");
//}
//-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
//{
//    [audioPlayer stop];
//    NSLog(@"Finished Playing");
//}
//
//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
//{
//    NSLog(@"Error occured");
//}
@end
