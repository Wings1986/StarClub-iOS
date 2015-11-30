//
//  QuizCheckController.m
//  StarClub
//

#import "QuizCheckController.h"
#import "DLImageLoader.h"

#import "QuizResultController.h"

#import "UILabel+Size.h"


@interface QuizCheckController ()
{
    IBOutlet UIScrollView * mScrollView;
    IBOutlet UIImageView * mImageBack;
    
    
    int m_nPage;
    NSMutableArray * arrAnswered;
    
    int m_countAnswer;
}

@property (nonatomic, strong) NSDictionary* m_quizEntry;
@property (nonatomic, strong) NSArray * m_arrQuizs;
@property (nonatomic, strong) NSMutableDictionary * m_dicFeed;


@end

@implementation QuizCheckController

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
 
    self.title = @"Quiz";
    
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
    


    mScrollView.scrollEnabled = NO;
    
    m_nPage = 0;
    arrAnswered = [[NSMutableArray alloc] init];
    
    m_countAnswer = 0;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!bLoaded) {
        bLoaded = YES;

        [self getQuizInfo];
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

    
    
    for (int i = 0 ; i < (int)[self.m_arrQuizs count]; i ++) {
        
        NSDictionary * question = [self.m_arrQuizs objectAtIndex:i];
        
        UIView * viewPage = [[UIView alloc] initWithFrame:
                             CGRectMake(i*mScrollView.frame.size.width, 0, mScrollView.frame.size.width, mScrollView.frame.size.height)];
        
        UILabel * lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, viewPage.frame.size.width - 40, 150)];
        lbTitle.textAlignment = NSTextAlignmentLeft;
        lbTitle.numberOfLines = 4;
        lbTitle.font = [UIFont fontWithName:FONT_NAME size:FONT_QUIZ_TITLE];
        lbTitle.text = [question objectForKey:@"question_name"];
        lbTitle.numberOfLines = 10;
        [viewPage addSubview: lbTitle];
        
        
        NSArray * arrAnswers = [question objectForKey:@"answer"];

        int framex = 60;
        int framey = 120;
        for (int j = 0 ; j < (int)[arrAnswers count]; j ++) {
            int x = framex;
            int y = framey + 40 * j;

            
            UIButton *btTemp = [[UIButton alloc]initWithFrame:CGRectMake(x, y, 25, 25)];
            [btTemp addTarget:self action:@selector(checkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btTemp setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            [btTemp setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateSelected];
            [btTemp setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateHighlighted];
            btTemp.tag = i * 10 + j;
            
            UILabel * lbTemp = [[UILabel alloc] initWithFrame:CGRectMake(x + 35, y+12-25-20, 250, 90)];
            lbTemp.font = [UIFont fontWithName:FONT_NAME size:FONT_QUIZ_QUESTION];
            NSString * sTitle = [[arrAnswers objectAtIndex:j] objectForKey:@"name"];
            lbTemp.textAlignment = NSTextAlignmentLeft;
            lbTemp.numberOfLines = 10;
            lbTemp.text = sTitle;

            [viewPage addSubview:btTemp];
            [viewPage addSubview:lbTemp];
        }
        
        [mScrollView addSubview:viewPage];
    }
    
    mScrollView.contentSize = CGSizeMake(mScrollView.frame.size.width * [self.m_arrQuizs count], mScrollView.frame.size.height);
}

#pragma mark - 
- (void) checkButtonClicked:(UIButton*) sender
{
    BOOL bSelected = [sender isSelected];
    
    bSelected = !bSelected;
    
    [sender setSelected:bSelected];
    
    int tag = (int)sender.tag;

    m_nPage = tag / 10;
    
    int index = tag % 10;

    NSString * ansId = [[[[self.m_arrQuizs objectAtIndex:m_nPage] objectForKey:@"answer"] objectAtIndex:index] objectForKey:@"answer_id"];
    if (bSelected) {
        [arrAnswered addObject:ansId];
    } else {
        [arrAnswered removeObject:ansId];
    }
    
}


#pragma mark -
#pragma mark Event Button
-(IBAction) onClickBack:(id)sender{
    [super onBack];
}
-(IBAction) onClickNext:(id)sender
{
    
        
        if ([arrAnswered count] == 0) {
            [super showMessage:@"" message:@"Please select an answer." delegate:nil firstBtn:@"OK" secondBtn:nil];
            return;
        }
        
        
        BOOL bBreak = NO;
        BOOL bRight = NO;
    
        NSArray * arrAnswers = [[self.m_arrQuizs objectAtIndex:m_nPage] objectForKey:@"answer"];
        for (int j = 0 ; j < (int) [arrAnswers count]; j ++) {
            
            NSDictionary * item = [arrAnswers objectAtIndex:j];
            
            
            NSString * answer_id = [item objectForKey:@"answer_id"];
            NSString *is_correct = [item objectForKey:@"is_correct"];
            
            BOOL bOneRight = NO;
            
            for (int i = 0; i < (int)[arrAnswered count]; i ++) {
                NSString * choose_answer_id = [arrAnswered objectAtIndex:i];
                
                if ([answer_id isEqualToString:choose_answer_id]) {
                    if ([is_correct isEqualToString:@"1"]) {
                        bOneRight = YES;
                        break;
                    }
                    else {
                        bBreak = YES;
                        break;
                    }
                }
            }
            
            if (bBreak == YES) {
                bRight = NO;
                break;
            }
            
            if (bOneRight == NO) {
                if ([is_correct isEqualToString:@"1"]) {
                    bRight = NO;
                    break;
                }
            }
            else {
                bRight = YES;
            }
            
        }

        
        if (bRight) {
            m_countAnswer ++;
        }
        
        m_nPage ++;
        [arrAnswered removeAllObjects];
        
        if (m_nPage >= (int)[self.m_arrQuizs count]) {
            
            QuizResultController * pController = [[QuizResultController alloc] initWithData:self.m_dicFeed : (int)[self.m_arrQuizs count] : m_countAnswer];
            [super onPush:pController];
            
        }
        else {
            [mScrollView setContentOffset:CGPointMake(mScrollView.frame.size.width*m_nPage, 0)];
        }
    
    
}

@end
