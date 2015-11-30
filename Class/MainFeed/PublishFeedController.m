//
//  PublishFeedController.m
//  StarClub
//
//  Created by SilverStar on 7/15/14.
//
//

#import "PublishFeedController.h"
#import "StarTracker.h"

#import "ASIFormDataRequest.h"


@interface PublishFeedController ()
{
    NSDictionary * m_feed;
    NSMutableDictionary*    m_postObj;
    
    BOOL m_bIsPublish;
    
    IBOutlet UIImageView *ivAvatar;
    IBOutlet UIImageView *ivVideoIcon;
    IBOutlet UITextView *lbCaption;
    IBOutlet UISwitch * btnSwitch;
    
    IBOutlet UISwitch *switchFb;
    IBOutlet UISwitch *switchTw;
    
    IBOutlet UILabel *lbFb;
    IBOutlet UILabel *lbTwit;
    IBOutlet UILabel *lbInsta;
    IBOutlet UIImageView *imgFb;
    IBOutlet UIImageView *imgTwit;
    IBOutlet UIImageView *imgInsta;
    
    BOOL m_bEnableFb;
    BOOL m_bEnableTw;
    BOOL m_bEnableIns;

}

@end

@implementation PublishFeedController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithFeed:(NSDictionary*) feed
{
    self = [super init];
    if (self) {
        m_feed = feed;
        m_bIsPublish = YES;
    }
    return self;
}
- (id) initWithShare:(NSDictionary*) feed
{
    self = [super init];
    if (self) {
        m_feed = feed;
        m_bIsPublish = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Syndicate";
    [StarTracker StarSendView:self.title];
    
    
    UITapGestureRecognizer * tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCloseKeyboard:)];
    tapGestureUser.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureUser];
    
    
    if (m_bIsPublish) {
        UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
        [btnEdit setImage:[UIImage imageNamed:@"btn_publish"] forState:UIControlStateNormal];
        [btnEdit addTarget:self action:@selector(onClickPublish) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
        self.navigationItem.rightBarButtonItem = btnItemEdit;
    }
    
    
    // set value
    NSString * imageUrl = [m_feed objectForKey:@"image_path"];
    
    if (imageUrl == nil || imageUrl.length < 1) {
 //       imageUrl = SHARE_APP_LOGO;
        [super setResultDic:m_feed image:nil];
    }
//    else {
        [DLImageLoader loadImageFromURL:imageUrl
                              completed:^(NSError *error, NSData *imgData) {
                                  if (error == nil) {
                                      // if we have no errors
                                      UIImage * image = [UIImage imageWithData:imgData];
                                      [ivAvatar setImage:image];
                                      
                                      [super setResultDic:m_feed image:ivAvatar.image];
                                  }
                              }];
//    }
    
    lbCaption.text = [m_feed objectForKey:@"caption"];
    
    ivVideoIcon.hidden = YES;
    NSString* postType = [m_feed[@"post_type"] lowercaseString];
    if ([postType rangeOfString:@"video"].location != NSNotFound) {
        ivVideoIcon.hidden = NO;
    }
    
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    m_bEnableFb = [[userInfo objectForKey:@"enable_facebook"] boolValue];
    m_bEnableTw  = [[userInfo objectForKey:@"enable_twitter"] boolValue];
    m_bEnableIns  = [[userInfo objectForKey:@"enable_instagram"] boolValue];
    
    m_bIsCustomCaptionFb = [[userInfo objectForKey:@"enable_facebook_custom_caption"] boolValue];
    m_bIsCustomCaptionTw = [[userInfo objectForKey:@"enable_twitter_custom_caption"] boolValue];
    m_bIsCustomCaptionInst = [[userInfo objectForKey:@"enable_instagram_custom_caption"] boolValue];
    
    [self refreshSocial];
}

- (void) refreshSocial
{
    if (m_bEnableFb) {
        lbFb.textColor = [UIColor colorWithRed:59.0f/255.0f green:89.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        [imgFb setImage:[UIImage imageNamed:@"facebook_icon.png"]];
    } else {
        lbFb.textColor = [UIColor blackColor];
        [imgFb setImage:[UIImage imageNamed:@"facebook_disable_icon.png"]];
    }

    if (m_bEnableTw) {
        lbTwit.textColor = [UIColor colorWithRed:27.0f/255.0f green:178.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
        [imgTwit setImage:[UIImage imageNamed:@"twitter_icon.png"]];
    } else {
        lbTwit.textColor = [UIColor blackColor];
        [imgTwit setImage:[UIImage imageNamed:@"twitter_disable_icon.png"]];
    }

    if (m_bEnableIns) {
        lbInsta.textColor = [UIColor colorWithRed:79.0f/255.0f green:126.0f/255.0f blue:167.0f/255.0f alpha:1.0f];
        [imgInsta setImage:[UIImage imageNamed:@"instagram_icon.png"]];
    } else {
        lbInsta.textColor = [UIColor blackColor];
        [imgInsta setImage:[UIImage imageNamed:@"instagram_disable_icon.png"]];
    }
    
    switchFb.on = m_bIsCustomCaptionFb;
    switchTw.on = m_bIsCustomCaptionTw;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) onChangeSwitch:(id)sender
{
    if (((UISwitch*)sender).on) {
        
        [super showLoading:@"Publishing..."];
        
        [NSThread detachNewThreadSelector: @selector(onPublish) toTarget:self withObject:nil];
    }
}
-(void) onClickPublish
{
    [super showLoading:@"Publishing..."];
    
    [NSThread detachNewThreadSelector: @selector(onPublish) toTarget:self withObject:nil];
    
}
-(void) onPublish
{
    NSString * postType = [m_feed objectForKey:@"post_type"];
    NSString * contentId = [m_feed objectForKey:@"content_id"];
    
    NSString * urlString = [MyUrl setPublish:postType contentId:contentId];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            [super hideLoading];
            
            [btnSwitch setEnabled:NO];
            [self.delegate setPublished];
            
            return;
        }
        else {
            btnSwitch.on = NO;
            NSString * ErrMessage = [result objectForKey:@"message"];
            [self showFail:ErrMessage];
            return;
        }
    }

    btnSwitch.on = NO;
    [self showFail:@"Network communication problems!"];
}

- (IBAction)onClickShare:(id)sender {
    
    m_bIsCustomCaptionFb = switchFb.on;
    m_bIsCustomCaptionTw = switchTw.on;
    
    NSString * textCaption = lbCaption.text;
    [super changeCaptionText:textCaption];

    [super onShare];
}

- (IBAction)onClickEnableFb:(id)sender {
    (m_bEnableFb = !m_bEnableFb) ? [super showLoading:@"Enable Facebook."] : [super showLoading:@"Disable Facebook."];
    [self uploadSocialShare];
}

- (IBAction)onClickEnableTw:(id)sender {
    (m_bEnableTw = !m_bEnableTw) ? [super showLoading:@"Enable Twitter."] : [super showLoading:@"Disable Twitter."];
    [self uploadSocialShare];
}
- (IBAction)onClickEnableIns:(id)sender {
    (m_bEnableIns = !m_bEnableIns) ? [super showLoading:@"Enable Instagram."] : [super showLoading:@"Disable Instagram."];
    [self uploadSocialShare];
}
-(IBAction) onChangeFBCustomCaption:(id)sender
{
    m_bIsCustomCaptionFb = !switchFb.on;
    
    (m_bIsCustomCaptionFb = !m_bIsCustomCaptionFb) ? [super showLoading:@"Enable Facebook Caption."] : [super showLoading:@"Disable Facebook Caption."];
    
    [self uploadSocialShare];
}
-(IBAction) onChangeTWCustomCaption:(id)sender
{
    m_bIsCustomCaptionTw = !switchTw.on;
    
    (m_bIsCustomCaptionTw = !m_bIsCustomCaptionTw) ? [super showLoading:@"Enable Twitter Caption."] : [super showLoading:@"Disable Twitter Caption."];
    
    [self uploadSocialShare];
}


-(IBAction)dismissKeyboard:(id)sender
{
    [sender resignFirstResponder];
}


-(void) uploadSocialShare
{
    
    NSString *url = [MyUrl getUpdateUser];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:[NSString stringWithFormat:@"%d",CID] forKey:@"cid"];
    [request setPostValue:TOKEN forKey:@"token"];
    NSLog(@"token = %@", TOKEN);
    [request setPostValue:USERID forKey:@"user_id"];
    NSLog(@"userId = %@", USERID);
    [request setPostValue:DEVICETOKEN forKey:@"ud_token"];
    NSLog(@"ud_token = %@", DEVICETOKEN);
    
    [request setPostValue:[NSNumber numberWithBool:m_bEnableFb] forKey:@"enable_facebook"];
    [request setPostValue:[NSNumber numberWithBool:m_bEnableTw] forKey:@"enable_twitter"];
    [request setPostValue:[NSNumber numberWithBool:m_bEnableIns] forKey:@"enable_instagram"];
    
    [request setPostValue:[NSNumber numberWithBool:m_bIsCustomCaptionFb] forKey:@"enable_facebook_custom_caption"];
    [request setPostValue:[NSNumber numberWithBool:m_bIsCustomCaptionTw] forKey:@"enable_twitter_custom_caption"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(doneSocialShare:)];
    [request setDidFailSelector:@selector(failSocialShare:)];
    
    [request startAsynchronous];
}

- (void)doneSocialShare:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:responseString];
    
    NSLog(@"result = %@", result);
    
    BOOL status = [[result objectForKey:@"status"] boolValue];
    if (status == true) {
        
        [super hideLoading];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:USER_INFO]];
        [userInfo setValue:[NSNumber numberWithBool:m_bEnableFb] forKey:@"enable_facebook"];
        [userInfo setValue:[NSNumber numberWithBool:m_bEnableTw] forKey:@"enable_twitter"];
        [userInfo setValue:[NSNumber numberWithBool:m_bEnableIns] forKey:@"enable_instagram"];
        
        [userInfo setValue:[NSNumber numberWithBool:m_bIsCustomCaptionFb] forKey:@"enable_facebook_custom_caption"];
        [userInfo setValue:[NSNumber numberWithBool:m_bIsCustomCaptionTw] forKey:@"enable_twitter_custom_caption"];
        
        [defaults setObject:userInfo forKey:USER_INFO];
        [defaults synchronize];
        
        [self refreshSocial];
        
        return;
    }
    
    [super showFail:@"Network communication problem."];
}

- (void)failSocialShare:(ASIHTTPRequest *)request{
    
    [super showFail:@"Network communication problem."];

    m_bEnableFb = !m_bEnableFb;
    m_bEnableTw = !m_bEnableTw;
    m_bEnableIns = !m_bEnableIns;
    
}

-(void) onCloseKeyboard:(UITapGestureRecognizer*) gesture
{
    if ([lbCaption becomeFirstResponder]) {
        [lbCaption resignFirstResponder];
    }
}
@end
