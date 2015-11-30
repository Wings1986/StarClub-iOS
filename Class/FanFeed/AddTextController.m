//
//  AddTextController.m
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//

#import "AddTextController.h"

#import <QuartzCore/QuartzCore.h>

#import "StarTracker.h"


@interface AddTextController ()
{
    IBOutlet UIImageView * imgAvatar;
    IBOutlet UITextView  * mTextView;
    
    NSMutableDictionary * m_shareDic;
}

@end

@implementation AddTextController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    self.title = @"New Text";
    [ StarTracker StarSendView: self.title];
    
    UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnCancel setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_send.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickPost:) forControlEvents:UIControlEventTouchUpInside];
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) onClickCancel:(id)sender {
    [self onBack];
}
- (IBAction) onClickPost:(id)sender {
 
    if (mTextView.text.length < 1) {
        [self showMessage:@"Warning!" message:@"Please input text!" delegate:nil firstBtn:nil secondBtn:@"OK"];

        return;
    }
    
    if ([mTextView isFirstResponder]) {
        [mTextView resignFirstResponder];
    }
    
    [super showLoading:@"Uploading..."];
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
    
    NSString * urlResult = [MyUrl getAddText:mTextView.text];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            if ([Global getUserType] != FAN) {
 //               [super setResultDic:result[@"post"][0] image:nil];
                m_shareDic = result[@"post"][0];
            }
            
            [self performSelectorOnMainThread:@selector(doneServer) withObject:nil waitUntilDone:YES];
        }
    }
}

-(void) doneServer
{
    [self hideLoading];
    
    [self.delegate addTextPostDone];
    
    if ([Global getUserType] == FAN) {
        [self onBack];
    }
    else {
        UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
        [btnEdit setImage:[UIImage imageNamed:@"btn_post"] forState:UIControlStateNormal];
        [btnEdit addTarget:self action:@selector(onShareDic) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
        self.navigationItem.rightBarButtonItem = btnItemEdit;
        
        NSString * message = [NSString stringWithFormat:@"%@\nSyndicate to Social Media?", @"Published Successfully."];
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@""
                           message:message
                           delegate:self
                           cancelButtonTitle:@"Yes"
                           otherButtonTitles:@"No", nil];
        av.tag = 20000;
        [av show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //OK
        
        if (alertView.tag == 20000) {
            [self onShareDic];
            return;
        }
    }
}
- (void) onShareDic
{
    PublishFeedController * pController = [[PublishFeedController alloc] initWithShare:m_shareDic];
    [super onPush:pController];
}



@end
