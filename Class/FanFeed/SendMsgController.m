//
//  SendMsgController.m
//  StarClub
//

#import "SendMsgController.h"

#import <QuartzCore/QuartzCore.h>

#import "StarTracker.h"
@interface SendMsgController ()
{
    IBOutlet UIImageView * imgAvatar;
    IBOutlet UITextView  * mTextView;
    IBOutlet UILabel     * lbTitle;
    IBOutlet UITextView  * mMessageView;
}

@property (nonatomic, strong) NSString * m_receiver;
@property (nonatomic, assign) NSString * m_userName;
@property (nonatomic, assign) NSString * m_message;

@end

@implementation SendMsgController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithReceiverId:(NSString *) userId userName:(NSString*) userName message:(NSString*) prev_msg
{
    self = [super init];
    if (self) {
        self.m_receiver = userId;
        self.m_userName = userName;
        self.m_message = prev_msg;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Send Message";
    [StarTracker StarSendView:self.title];
    
    UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnCancel setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_send.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickSend:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    

    mTextView.layer.borderWidth = 1.0f;
    mTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    
    NSString * imageUrl = [userInfo objectForKey:@"img_url"];
    if (imageUrl == nil || imageUrl.length < 1) {
        UIImage * image = [[UIImage imageNamed:@"demo-avatar.png"] circleImageWithSize:imgAvatar.frame.size.width];
        [imgAvatar setImage:image];
    }
    else {
        [DLImageLoader loadImageFromURL:imageUrl
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:imgAvatar.frame.size.width];
                                      [imgAvatar setImage:image];
                                  }
                              }];
    }
    
    self.title = [NSString stringWithFormat:@"To %@", self.m_userName];

    mMessageView.text = self.m_message;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) onClickCancel:(id)sender {
    [self onBack];
}
- (IBAction) onClickSend:(id)sender {
 
    if (mTextView.text.length < 1) {
        [super showMessage:@"Warnings!" message:@"Please input message" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    if ([mTextView isFirstResponder]) {
        [mTextView resignFirstResponder];
    }
    
    [super showLoading:@"Sending..."];
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
    
    NSString * urlResult = [MyUrl sendMessage:self.m_receiver text:mTextView.text];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
              [self performSelectorOnMainThread:@selector(donePostServer) withObject:nil waitUntilDone:YES];

        }
    }
}

-(void) donePostServer
{
    [self hideLoading];
    
    [self onBack];
}
@end
