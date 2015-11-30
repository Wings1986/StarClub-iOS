//
//  YoutubeController.m
//  StarClub
//
//  Created by MAYA on 1/14/14.
//
//

#import "YoutubeController.h"
#import "GHAppDelegate.h"

#import "StarTracker.h"
#import "Base64.h"

@interface YoutubeController ()<UIWebViewDelegate>
{
    IBOutlet UIWebView * mWebView;
    
    IBOutlet UIActivityIndicatorView	*m_actLoading;

}

@property (nonatomic, assign) NSString * urlYoutube;

@end



@implementation YoutubeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUrl:(NSString *) url {
    self = [super init];
    if (self) {
        self.urlYoutube = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [StarTracker StarSendView:@"U-Tube Video"];
    
    self.title = @"Video";
    
    
    UIView * viewAdd = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30 * 2, 30)];
    
    UIButton * btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 30)];
    [btnPrev setImage:[UIImage imageNamed:@"btn_prev_icon.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(webViewGoBack) forControlEvents:UIControlEventTouchUpInside];
    [viewAdd addSubview:btnPrev];
    
    UIButton * btnNext = [[UIButton alloc] initWithFrame:CGRectMake(34, 0, 26, 30)];
    [btnNext setImage:[UIImage imageNamed:@"btn_next_icon.png"] forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(webViewGoForward) forControlEvents:UIControlEventTouchUpInside];
    [viewAdd addSubview:btnNext];
    
    UIBarButtonItem * btnItemAdd = [[UIBarButtonItem alloc] initWithCustomView:viewAdd];
    self.navigationItem.rightBarButtonItem = btnItemAdd;
    
    NSString *base64String = [ self.urlYoutube base64EncodedString];
    
    [StarTracker StarSendEvent:@"App Event" :@"External Video Requested" : base64String];
 
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlYoutube]];
    [mWebView loadRequest: request];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Webview Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
	if ([webView isEqual:mWebView]) {
		[m_actLoading startAnimating];
        m_actLoading.hidden = NO;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if ([webView isEqual:mWebView]) {
		[m_actLoading stopAnimating];
        m_actLoading.hidden = YES;
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if ([webView isEqual:mWebView]) {
		[m_actLoading stopAnimating];
		m_actLoading.hidden = YES;
		NSLog(@"webview load fail (%@)", [error localizedDescription]);
	}
}



-(IBAction) onClickBack:(id)sender {
    [StarTracker StarSendEvent:@"App Event" :@"External Video Requested" : @"Stopped"];
    [super onBack];
}


- (IBAction) webViewGoBack
{
    // si puede ir atras, pues va atras
//    if ([mWebView canGoBack])
    {
        [mWebView goBack];
    }
}

- (IBAction) webViewGoForward
{
    // si puede ir adelante, pues va adelante
//    if ([mWebView canGoForward])
    {
        [mWebView goForward];   
    }
}


#pragma mark -
#pragma mark Notify
-(void)youTubeStarted:(NSNotification *)notification{
    
    [StarTracker StarSendEvent:@"App Event" :@"External Video Requested" : @"Started"];
    // Entered Fullscreen code goes here..
    GHAppDelegate *appDelegate = APPDELEGATE;
    appDelegate.fullScreenVideoIsPlaying = YES;
    
}

-(void)youTubeFinished:(NSNotification *)notification{
    
        [StarTracker StarSendEvent:@"App Event" :@"External Video Requested" : @"Finished"];
    // Left fullscreen code goes here...
    GHAppDelegate *appDelegate = APPDELEGATE;
    appDelegate.fullScreenVideoIsPlaying = NO;
    
    //CODE BELOW FORCES APP BACK TO PORTRAIT ORIENTATION ONCE YOU LEAVE VIDEO.
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    //present/dismiss viewcontroller in order to activate rotating.
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentViewController:mVC animated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

//-(BOOL) shouldAutorotate {
//    return YES;
//}
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}

- (void)orientationChanged2:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}
- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
//    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
//    {
//        [self.moviePlayerController setFullscreen:NO animated:YES];
//    }
//    else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
//    {
//        [self.moviePlayerController setFullscreen:YES animated:YES];
//    }
}
@end
