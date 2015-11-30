//
//  AddCommentController.m
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//

#import "AddCommentController.h"

#import <QuartzCore/QuartzCore.h>

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "GAIFields.h"

@interface AddCommentController ()
{
    IBOutlet UIImageView * imgAvatar;
    IBOutlet UITextView  * mTextView;
}
@property(nonatomic, strong) NSDictionary * m_info;

@end

@implementation AddCommentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithData:(NSDictionary*) dic
{
    self = [super init];
    if (self) {
        self.m_info = [[NSDictionary alloc] initWithDictionary:dic];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Add Comments"
                                                      forKey:kGAIScreenName] build]];

    self.title = @"Add Comment";
    
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
    [DLImageLoader loadImageFromURL:imageUrl
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:imgAvatar.frame.size.width];
                                  [imgAvatar setImage:image];
                              }
                          }];

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![mTextView isFirstResponder]) {
        [mTextView becomeFirstResponder];
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
        return;
    }
    
    if ([mTextView isFirstResponder]) {
        [mTextView resignFirstResponder];
    }
    
    [super showLoading:@"Posting..."];
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
}
-(void) postServer
{
    
    NSString* postType = [self.m_info objectForKey:POSTTYPE];
    NSString* contentId = [self.m_info objectForKey:CONTENTID];
    NSString* comment = mTextView.text;
    
    
    NSString * urlString = [MyUrl addComment:postType contentId:contentId comment:comment];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"comment success");
        
        [self performSelectorOnMainThread:@selector(donePostServer) withObject:nil waitUntilDone:YES];
    }
    else {
        NSLog(@"comment fail");
    }
    
    [super hideLoading];
}

-(void) donePostServer
{
    [self hideLoading];
    
    [self.delegate addCommentDone];
    
    [self onBack];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        [self performSelector:@selector(onClickPost:) withObject:nil afterDelay:0.1];
        
        return NO;
    }
    
    return YES;
}
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    [self performSelector:@selector(onClickPost:) withObject:nil afterDelay:0.1];
//    
//    return YES;
//}

@end
