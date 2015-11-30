//
//  QuizController.m
//  StarClub
//

#import "PollsController.h"
#import "DLImageLoader.h"
#import "MIRadioButtonGroup.h"

#import "PollResultController.h"
#import "StarTracker.h"

@interface PollsController ()<MIRadioButtonGroupDelegate>
{
    IBOutlet UIScrollView * mScrollView;
    IBOutlet UIImageView * mImageBack;

    
    int m_nPage;
    int m_nSelAnswer;
    
    int m_countAnswer;
    
}

@property (nonatomic, strong) NSDictionary* m_quizEntry;
@property (nonatomic, strong) NSArray * m_arrQuizs;
@property (nonatomic, strong) NSMutableDictionary * m_dicFeed;

@end

@implementation PollsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithData:(NSDictionary *) dic {
    self = [super init] ;
    if (self) {
        self.m_quizEntry = dic;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    
    self.title = @"Poll";
    [StarTracker StarSendView:self.title];
    
    UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnCancel setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_next.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickNext:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    
    
    m_nPage = -1;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    mScrollView.scrollEnabled = NO;
    
    m_nSelAnswer = -1;
    
    m_countAnswer = 0;

    m_nPage ++;

    if (!bLoaded) {
        bLoaded = YES;

        [self getQuizInfo];
    }
    else {
        [self setInterface];
    }
    
}

- (void) getQuizInfo{
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
    
}
-(void) postServer
{
    
    NSString * postType = [self.m_quizEntry objectForKey:@"post_type"];
    NSString * contentID = [self.m_quizEntry objectForKey:@"content_id"];
    
    NSString * urlResult = [MyUrl getQuizData:postType :contentID];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            self.m_arrQuizs = [result objectForKey:@"questions"];
            self.m_dicFeed = [result objectForKey:@"feed"];
            
              [self performSelectorOnMainThread:@selector(setInterface) withObject:nil waitUntilDone:YES];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setInterface {
    
    NSString * backImageUrl = [self.m_dicFeed objectForKey:@"background_image_path"];
    
    NSString * sW = [self.m_dicFeed objectForKey:@"background_img_width"];
    NSString * sH = [self.m_dicFeed objectForKey:@"background_img_height"];
    
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

    
    for (UIView* subView in mScrollView.subviews) {
        [subView removeFromSuperview];
    }
    
//    for (int i = 0 ; i < (int)[self.m_arrQuizs count]; i ++) {
    
    
        NSDictionary * question = [self.m_arrQuizs objectAtIndex:m_nPage];
    
    
        UIScrollView * viewPage = [[UIScrollView alloc] initWithFrame:
                             CGRectMake(0, 0, mScrollView.frame.size.width, mScrollView.frame.size.height)];
        viewPage.backgroundColor = [UIColor clearColor];
        
        UILabel * lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, viewPage.frame.size.width - 40, 90)];
        lbTitle.textAlignment = NSTextAlignmentCenter;
        lbTitle.numberOfLines = 5;
        lbTitle.font = [UIFont fontWithName:FONT_NAME size:FONT_POLL_TITLE];
        lbTitle.text = [question objectForKey:@"question_name"];
        [viewPage addSubview: lbTitle];
        
        
        NSArray * arrAnswers = [question objectForKey:@"answer"];
        
        MIRadioButtonGroup *group =[[MIRadioButtonGroup alloc] initWithFrame:CGRectMake(40, 120, 320, mScrollView.frame.size.height-60) andOptions:arrAnswers];
        group.delegate = self;
        group.tag = m_nPage;
        [viewPage addSubview:group];
    
    
        viewPage.contentSize = CGSizeMake(320, 120 + group.m_height);
    
        [mScrollView addSubview:viewPage];
//    }
    
    mScrollView.contentSize = CGSizeMake(mScrollView.frame.size.width, mScrollView.frame.size.height);
}

#pragma mark - 
- (void) setSelectedButton:(int) index : (MIRadioButtonGroup*) parent
{
    int tag = parent.tag;

    m_nPage = tag;
    m_nSelAnswer = index;
}


#pragma mark -
#pragma mark Event Button
-(IBAction) onClickBack:(id)sender{
    [super onBack];
}
-(IBAction) onClickNext:(id)sender
{
    
    if (m_nSelAnswer == -1) {
        [super showMessage:@"" message:@"Please seelct an answer." delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    NSDictionary * dicQuestion = [self.m_arrQuizs objectAtIndex:m_nPage];
    
    NSString * question_id = [dicQuestion objectForKey:@"question_id"];
    NSString * answer_id = [[[dicQuestion objectForKey:@"answer"] objectAtIndex:m_nSelAnswer] objectForKey:@"answer_id"];
    
    BOOL bFinish = NO;
    if (m_nPage == (int)[self.m_arrQuizs count]-1) {
        bFinish = YES;
    }
    PollResultController * pController = [[PollResultController alloc] initWithData:self.m_dicFeed : answer_id question:question_id done:bFinish];
    [super onPush:pController];

}

@end
