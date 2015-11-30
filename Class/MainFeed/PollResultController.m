//
//  PollResultController.m
//  StarClub
//

#import "PollResultController.h"

#import "StarTracker.h"

@interface PollResultController ()<UIActionSheetDelegate>
{
    IBOutlet UIView * viewResult;
    IBOutlet UIImageView * mImageBack;
}

@property (nonatomic, assign) NSString * m_strAnswerId;
@property (nonatomic, assign) NSString * m_strQuestionId;

@property (nonatomic, strong) NSMutableDictionary * m_dicFeed;
@property (nonatomic, assign) BOOL  m_bFinish;

@property (nonatomic, strong) NSMutableArray * m_arrRating;

@end

@implementation PollResultController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithData:(NSMutableDictionary *) dic : (NSString*) answerId question: (NSString*) questionId done:(BOOL) bFinish {
    self = [super init] ;
    if (self) {
        self.m_dicFeed = dic;
        self.m_strAnswerId = answerId;
        self.m_strQuestionId = questionId;
        self.m_bFinish = bFinish;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    self.m_arrRating = [[NSMutableArray alloc] init];

    self.title = @"Poll";
    [StarTracker StarSendView:self.title];
    
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
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];

}

-(void) postServer
{
    NSString * resultString = [MyUrl getPollAnswer:self.m_strAnswerId questionId:self.m_strQuestionId];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:resultString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            self.m_arrRating = [result objectForKey:@"ratings"];
            
            [self performSelectorOnMainThread:@selector(setInterface) withObject:nil waitUntilDone:YES];
            
            return;
        }
    }
    
}

-(void) setInterface
{
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewResult.frame.size.width, viewResult.frame.size.height)];
    
    int y = 0;
    for (int i = 0 ; i < (int)[self.m_arrRating count]; i ++) {
        NSDictionary * item = [self.m_arrRating objectAtIndex:i];
        
        NSString * text = [item objectForKey:@"name"];
        double percent = [[item objectForKey:@"percent"] doubleValue];
        
        y = 20 + 50 * i;
        UILabel * lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, y-20, 90, 90)];
        lbTitle.textAlignment = NSTextAlignmentRight;
        lbTitle.numberOfLines = 3;
        lbTitle.font = [UIFont fontWithName:FONT_NAME_BOLD size:FONT_POLL_RESULT];
        lbTitle.textColor = [UIColor blackColor];
        lbTitle.text = text;
        [scrollView addSubview:lbTitle];

        UIImageView * imageBar = [[UIImageView alloc] initWithFrame:CGRectMake(120, y+10, 150 * (percent/100), 20)];
        imageBar.backgroundColor = [UIColor greenColor];
        imageBar.layer.cornerRadius = 5;
        [scrollView addSubview:imageBar];

        UILabel * lbText = [[UILabel alloc] initWithFrame:CGRectMake(imageBar.frame.origin.x + imageBar.frame.size.width + 10, y, 80, 50)];
        lbText.font = [UIFont fontWithName:FONT_NAME size:FONT_POLL_RESULT];
        lbText.textColor = [UIColor blackColor];
//        lbText.text = [NSString stringWithFormat:@"%.2f %%", percent];
        lbText.text = [NSString stringWithFormat:@"%.0f %%", percent];
        [scrollView addSubview:lbText];

    }
    
    NSString * urlString = [self.m_dicFeed objectForKey:@"end_description"];
    UIWebView * mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(10, y + 60,
                                                                       viewResult.frame.size.width - 20, y + 60 + 100)];
    mWebView.backgroundColor = [UIColor clearColor];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [mWebView loadRequest: request];
    [mWebView setBackgroundColor:[UIColor clearColor]];
    [mWebView setOpaque:NO];
    [scrollView addSubview:mWebView];
    
    
    [viewResult addSubview:scrollView];
    
    scrollView.contentSize = CGSizeMake(viewResult.frame.size.width, y + 60 + 100);

}


#pragma mark -
#pragma mark Event Button
-(IBAction) onClickDone:(id)sender{
    if (self.m_bFinish) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }

}
-(IBAction) onClickShare:(id)sender
{
    
//    NSString * text = [NSString stringWithFormat:@"You answered %@ questions correctly", lbResult.text];
    
    self.m_dicFeed[@"caption"] = self.m_dicFeed[@"text"];
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

    NSMutableDictionary* postObj = [[NSMutableDictionary alloc] init];
    
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
