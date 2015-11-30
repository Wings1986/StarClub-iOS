//
//  SendMsgController.m
//  StarClub
//

#import "MsgDetailController.h"
#import "SendMsgController.h"
#import <QuartzCore/QuartzCore.h>

#import "StarTracker.h"
@interface MsgDetailController ()
{
    IBOutlet UITextView  * mTextView;
    
    IBOutlet UILabel     * lbFromName;
    IBOutlet UILabel     * lbToName;
    
}

@property (nonatomic, strong) NSDictionary * m_detail;

@end

@implementation MsgDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithMessageDetail:(NSDictionary *)detail
{
    self = [super init];
    if (self) {
        self.m_detail = detail;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.title = @"Message";
    
    [StarTracker StarSendView:self.title];
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * toUserName = [userInfo objectForKey:@"name"];
    lbToName.text = toUserName;
    
    NSString * fromUserName = [self.m_detail objectForKey:@"name"];
    lbFromName.text = fromUserName;
    
    NSString * msg = [self.m_detail objectForKey:@"message"];
    mTextView.text = msg;

    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_reply"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onReply) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) onReply
{
    NSString * receiverId = [self.m_detail objectForKey:@"sender_id"];
    NSString * userName = [self.m_detail objectForKey:@"name"];
    NSString * prevMessage = [self.m_detail objectForKey:@"message"];
    
    SendMsgController * pController = [[SendMsgController alloc] initWithReceiverId:receiverId userName:userName message:prevMessage];
    [super onPush:pController];
}

- (IBAction) onClickCancel:(id)sender {
    
    [self onBack];
    
    [self.delegate msgDetailsDone];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString * mailId = [self.m_detail objectForKey:@"id"];
    
    int is_seen = [[self.m_detail objectForKey:@"is_seen"] intValue];
    if (is_seen == 0) {
        [self setReadStatue:mailId];
    }
}

- (void) setReadStatue:(NSString*) mailId {
    [NSThread detachNewThreadSelector: @selector(postServer:) toTarget:self withObject:mailId];
}
-(void) postServer:(NSString *) mailId
{
    NSString * urlResult = [MyUrl readMessage:mailId];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
        }
    }
}

@end
