//
//  BCOVPlayerController.m
//
//  Created by  on 14-03-16.

#import "BCOVPlayerController.h"

#import "GHAppDelegate.h"

// import the SDK master header
#import "BCOVPlayerSDK.h"
#import "StarTracker.h"

@interface BCOVPlayerController()<UIGestureRecognizerDelegate>
{
    IBOutlet UIButton * btnDone;
    NSTimer * myTimer;
    
    
    NSString * m_videoUrl;
    NSString * m_videoId;
}

@end

@implementation BCOVPlayerController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithVideoURL:(NSString *) url videoId:(NSString*) videoId
{
    self = [super init];
    if (self) {
        m_videoUrl = url;
        m_videoId = videoId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [StarTracker StarSendView:@"Brightcove Player View"];
    
//    UIButton * btnDone = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
//    [btnDone setImage:[UIImage imageNamed:@"btn_done"] forState:UIControlStateNormal];
//    [btnDone addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * btnItemDone = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
//    self.navigationItem.leftBarButtonItem = btnItemDone;
    
    [self showDoneBtn:YES];
}


-(BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown; //Or anyother orientation of your choice
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
}

//-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        self.navigationController.navigationBarHidden = YES;
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//    }
//    else {
//        self.navigationController.navigationBarHidden = NO;
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//    }
//
//}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    
    GHAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.revealController increaseContentSize];
    appDelegate.m_playView.hidden = YES;
    appDelegate.BCOVVideoIsPlaying = YES;
    
    UIImageView *backgroundView = (UIImageView*)[self.navigationController.view viewWithTag:999];
    if (backgroundView != nil) {
        [backgroundView removeFromSuperview];
    }
    
    self.automaticallyAdjustsScrollViewInsets = false;

    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    if (!bLoaded) {
        bLoaded = YES;
        

            [StarTracker StarSendEvent:@"App Event" :@"Brightcove Play VideoUrl  Requested" :m_videoId];
              [self playBCOVVideo:m_videoUrl];

 
 /*
    }
 */       
    }
    
}

-(void) tapRecognized : (UITapGestureRecognizer*) sender {

    [self showDoneBtn:YES];
    
}
-(void) showDoneBtn:(BOOL) bShow
{
    if (bShow) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didStopAnimation)];
        
        [btnDone setHidden:NO];
        
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        
        [btnDone setHidden:YES];
        
        [UIView commitAnimations];
    }
}
-(void) didStopAnimation
{
    if (myTimer != nil) {
        [myTimer invalidate];
        myTimer = nil;
    }
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                         target:self
                                                       selector:@selector(targetMethod)
                                                       userInfo:nil
                                                        repeats:NO];
}
-(void) targetMethod
{
    [self showDoneBtn:NO];
}


-(void) playBCOVVideo:(NSString*) fileName
{
    NSArray *videos = @[
                        [self videoWithURL:[NSURL URLWithString:fileName]],
                        ];
    
    // add the playback controller
    self.controller = [[BCOVPlayerSDKManager sharedManager] createPlaybackControllerWithViewStrategy:[self viewStrategy]];
    self.controller.view.frame = self.view.bounds;
    // create a playback controller delegate
    self.controller.delegate = self;
    
    self.controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    // add the controller view as a subview of the SVPViewController's view
//    [self.view addSubview:self.controller.view];
    [self.view insertSubview:self.controller.view belowSubview:btnDone];
    
    // turn on auto-advance
    self.controller.autoAdvance = YES;
    // turn on auto-play
    self.controller.autoPlay = YES;
    
    // add the video array to the controller's playback queue
    [self.controller setVideos:videos];
    // play the first video
    [self.controller play];
}

- (BCOVVideo *)videoWithURL:(NSURL *)url
{
    // set the delivery method for BCOVSources that belong to a video
    BCOVSource *source = [[BCOVSource alloc] initWithURL:url deliveryMethod:kBCOVSourceDeliveryHLS properties:nil];
    return [[BCOVVideo alloc] initWithSource:source cuePoints:[BCOVCuePointCollection collectionWithArray:@[]] properties:@{}];
}

- (void) playBCOVVideoId:(NSString*) videoId
{
    self.mediaRequestFactory = [[BCOVMediaRequestFactory alloc] initWithToken:@"v2_tp1lbll_k9JjauR8-RcCMzw26Tq-KD87rxfhK7KdRmlkBsrGsKQ.." baseURLString:@"http://api.brightcove.com/services/library"];
    self.catalog = [[BCOVCatalogService alloc] initWithMediaRequestFactory:self.mediaRequestFactory];

    self.controller = [[BCOVPlayerSDKManager sharedManager] createPlaybackControllerWithViewStrategy:[self viewStrategy]];
    self.controller.view.frame = self.view.bounds;
    
    self.controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
//    [self.view addSubview:self.controller.view];
    [self.view insertSubview:self.controller.view belowSubview:btnDone];
    
    @weakify(self);

    [self.catalog findVideoWithVideoID:videoId parameters:nil completion:^(BCOVVideo *video, NSDictionary *jsonResponse, NSError *error) {
        @strongify(self);
        if(video){
            NSLog(@"jsonResponse = %@", jsonResponse);
            
            self.controller.autoAdvance = YES;
            self.controller.autoPlay = YES;
            
            [self.controller setVideos:@[video]];
            [self.controller play];
        }
    }];
}

- (id)viewStrategy
{
    
    // Most apps can create a playback controller with a `nil` view strategy,
    // but for the purposes of this demo we use the stock controls.
   return [[BCOVPlayerSDKManager sharedManager] defaultControlsViewStrategy];

}



- (IBAction)onClose:(id)sender{

    [StarTracker StarSendEvent:@"App Event" :@"Brightcove Player" : @"Closed"];

    [self.controller pause];
    GHAppDelegate * appDelegate = APPDELEGATE;
    [appDelegate.revealController decreaseContentSize];
    appDelegate.m_playView.hidden = NO;
    appDelegate.BCOVVideoIsPlaying = NO;

    [appDelegate orientationMediaPlayer:NO];
    [appDelegate.m_playView setChangeInterface:NO];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    

//    [self dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popViewControllerAnimated:NO];
    [super onBack];
}

@end
