//
//  QuizResultController.m
//  StarClub
//

#import "QuizResultController.h"
#import "StarTracker.h"


@interface QuizResultController ()<UIActionSheetDelegate>
{
    IBOutlet UIImageView * mImageBack;
    
    IBOutlet UILabel * lbResult;
    
    IBOutlet UIWebView * mWebView;
}

@property (nonatomic, assign) int m_nTotal;
@property (nonatomic, assign) int m_nResult;

@property (nonatomic, strong) NSMutableDictionary * m_dicFeed;


@end

@implementation QuizResultController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithData:(NSMutableDictionary*) dic : (int) total : (int) result
{
    self = [super init] ;
    if (self) {
        self.m_dicFeed = dic;
        self.m_nResult = result;
        self.m_nTotal = total;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"Contest";
    [StarTracker StarSendView:@"Quiz Results"];
    
    UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnCancel setImage:[UIImage imageNamed:@"btn_done.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(onClickDone:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_share.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickShare:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    
    
 //   lbResult.text = [NSString stringWithFormat:@"%d/%d", self.m_nResult, self.m_nTotal];
    lbResult.text = [NSString stringWithFormat:@"%d", self.m_nResult];
    
    
    NSString * backImageUrl = [self.m_dicFeed objectForKey:@"end_image_path"];
    
    NSString * sW = [self.m_dicFeed objectForKey:@"end_img_width"];
    NSString * sH = [self.m_dicFeed objectForKey:@"end_img_height"];
    
    int height = 0;
    if ((NSString *)[NSNull null] != sW && (NSString *)[NSNull null] != sH) {
        int _width, _height;
        _width = [sW intValue];
        _height = [sH intValue];
        
        int realHeight = (FULL_WIDTH * _height / _width);
        height += realHeight; //HEIGHT_IMAGE;
    }
    else {
        height += HEIGHT_IMAGE;
    }
    
    mImageBack.frame = CGRectMake(0, 0, FULL_WIDTH, height);
    [DLImageLoader loadImageFromURL:backImageUrl
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  UIImage * image = [UIImage imageWithData:imgData];
                                  [mImageBack setImage:image];
                              }
                          }];

    //
    NSString * urlString = [self.m_dicFeed objectForKey:@"end_description"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [mWebView loadRequest: request];
    [mWebView setBackgroundColor:[UIColor clearColor]];
    [mWebView setOpaque:NO];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    if (self.m_nResult == self.m_nTotal) {
//        [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
//    }
    
        [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];

}

-(void) postServer
{
    NSString * quizId = [self.m_dicFeed objectForKey:@"id"];
    
    NSString * resultString = [MyUrl getQuizAnswer:quizId questionCount:self.m_nTotal answerCount:self.m_nResult];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:resultString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            return;
        }
    }
    
}




#pragma mark -
#pragma mark Event Button
-(IBAction) onClickDone:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(IBAction) onClickShare:(id)sender
{
    
    NSString * text = [NSString stringWithFormat:@"You answered %@ questions correctly", lbResult.text];
    
    self.m_dicFeed[@"caption"] = text; //self.m_dicFeed[@"text"];
    self.m_dicFeed[@"content_id"] = self.m_dicFeed[@"id"];
    self.m_dicFeed[@"post_type"] = self.m_dicFeed[@"tags"];
    self.m_dicFeed[@"img_path"] = self.m_dicFeed[@"image_path"];
    
    NSLog(@"m_dicFeed = %@", self.m_dicFeed);
    
    PublishFeedController * pController = [[PublishFeedController alloc] initWithShare:self.m_dicFeed];
    [super onPush:pController];
    
//    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", nil];
//    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * text = [NSString stringWithFormat:@"You answered %@ questions correctly", lbResult.text];

    NSMutableDictionary* postObj = [[NSMutableDictionary alloc] init];
    [postObj setObject:text forKey:@"TEXT"];
    
    if (buttonIndex == 0) { // facebook
        [super onFacebook:postObj];
    }
    else if (buttonIndex == 1) {//twitter
        [super onTwitter:postObj];
    }
    else if (buttonIndex == 2) { // instagram
        [super onInstagram:postObj];
    }

}


@end
