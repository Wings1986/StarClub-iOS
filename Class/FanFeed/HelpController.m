//
//  HelpController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import "HelpController.h"

#import "StarTracker.h"

@interface HelpController ()<UIWebViewDelegate>
{
    IBOutlet UIWebView * mWebView;
    
    IBOutlet UIActivityIndicatorView	*m_actLoading;
    
    NSString * m_urlString;
    NSString * m_strTitle;
}

@end

@implementation HelpController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithURLString:(NSString*) url title:(NSString *) title
{
    self = [super init];
    if (self) {
        m_urlString = url;
        m_strTitle = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    
    if (m_urlString == nil) {
        if ([self.title isEqualToString:@"Help"]) {
            
            
            m_urlString = [[SERVER stringByAppendingFormat:@"/index.php/viewhelp/help/%d", CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            m_strTitle = @"Help";
        }
        else if ([self.title isEqualToString:@"Shop"]) {
            
            
            m_urlString = [[SERVER stringByAppendingFormat:@"/index.php/viewhelp/shop/%d", CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            m_strTitle = @"Shop";
        }
        else if ([self.title isEqualToString:MENU_TOUR])
 //                || [self.title isEqualToString:@"Events"])
        {
            
            
            m_urlString = [[SERVER stringByAppendingFormat:@"/index.php/viewhelp/tour/%d", CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            m_strTitle = self.title;
        }
        else if ([self.title isEqualToString:@"ei Live"]) {
            
            m_urlString = [[SERVER stringByAppendingFormat:@"/index.php/viewhelp/live/%d", CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            m_strTitle = @"ei Live";
        }
    }
    
    self.title = m_strTitle;
    
    [StarTracker StarSendView:self.title];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:m_urlString]];
    [mWebView loadRequest: request];
    
//    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];

//    if (!bLoaded) {
//        bLoaded = YES;
//        
//    }
    
    
}

-(void) postServer
{
    NSString * resultString = [MyUrl getHelp];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:resultString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            NSString * helpUrl = [result objectForKey:@"url"];
            
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:helpUrl]];
            [mWebView loadRequest: request];
        }
    }
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
                                                navigationType:(UIWebViewNavigationType)navigationType {
    
    // This practically disables web navigation from the webView.
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return FALSE;
    }
    return TRUE;
}

@end
