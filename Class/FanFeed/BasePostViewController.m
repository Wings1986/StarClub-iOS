//
//  BasePostViewController.m
//  StarClub
//
//  Created by SilverStar on 7/23/14.
//
//

#import "BasePostViewController.h"

@interface BasePostViewController ()
{
    BOOL m_bFacebook;
    BOOL m_bTwitter;
    BOOL m_bInstagram;
    
        MBProgressHUD *progressHUD;
}
@end

@implementation BasePostViewController

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
    // Do any additional setup after loading the view.
    
    m_bIsPublished = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if ([Global getUserType] != FAN) {
        m_bDraft = YES;
//    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    m_bDraft = NO;
}

- (void) setResultDic:(NSDictionary* ) result image:(UIImage*) imagePhoto;
{
    m_bIsPublished = YES;
    
    NSString * postType = result[@"post_type"];
    NSString * text = result[@"caption"];
    NSString * imgUrl = result[@"image_path"];
    NSString * contentId = result[@"content_id"];
    NSString * deepLink =  [result[@"deep_link_web"] stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * urlLink = result[@"url_link"];
    
    
    m_postObj = [[NSMutableDictionary alloc] init];
    [m_postObj setObject:text forKey:@"TEXT"];
    if (imagePhoto != nil) {
        [m_postObj setObject:imagePhoto forKey:@"IMAGE"];
        [m_postObj setObject:imgUrl forKey:@"IMAGEURL"];
    }
    
    [m_postObj setObject:postType forKey:@"POSTTYPE"];
    [m_postObj setObject:contentId forKey:@"CONTENTID"];
    [m_postObj setObject:deepLink forKey:@"DEEPLINK"];
    if ([postType  isEqual: @"photo"]) {
        [m_postObj setObject:urlLink forKey:@"url_link"];
    }
}

- (void) changeCaptionText:(NSString *)textCaption
{
    [m_postObj setObject:textCaption forKey:@"TEXT"];
}


- (void) onShare
{
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    m_bFacebook = [[userInfo objectForKey:@"enable_facebook"] boolValue];
    m_bTwitter  = [[userInfo objectForKey:@"enable_twitter"] boolValue];
    m_bInstagram  = [[userInfo objectForKey:@"enable_instagram"] boolValue];
    
    if (m_bFacebook) {
        [super onFacebook:m_postObj];
    }
    else if (m_bTwitter) {
        [super onTwitter:m_postObj];
    }
    else if (m_bInstagram) {
        [super onInstagram:m_postObj];
    }
    else {
        [self showMessage:@"" message:@"No Social Networks Enabled!" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
}

- (void) facebookPostDone:(NSString *)msg
{

    [self showSuccessDlg:msg icon:@"facebook_icon.png"];
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self hideSuccessDlg];
        
        if (m_bTwitter) {
            [super onTwitter:m_postObj];
        }
        else if (m_bInstagram) {
            [super onInstagram:m_postObj];
        }
    });
    
    
    
//    NSString * message = [NSString stringWithFormat:@"%@\nSyndicate to Twitter?", msg];
//    UIAlertView *av = [[UIAlertView alloc]
//                       initWithTitle:@""
//                       message:message
//                       delegate:self
//                       cancelButtonTitle:@"Yes"
//                       otherButtonTitles:@"No", nil];
//    av.tag = 10000;
//    [av show];
}

- (void) twitterPostDone:(NSString*) msg
{
    [self showSuccessDlg:msg icon:@"twitter_icon.png"];
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        //        [self doSometingWithObject:obj1 andAnotherObject:obj2];
        
        [self hideSuccessDlg];
        
        if (m_bInstagram) {
            [super onInstagram:m_postObj];
        }
    });
    
    
    
    
//    NSString * message = [NSString stringWithFormat:@"%@\nSyndicate to Instagram?", msg];
//    UIAlertView *av = [[UIAlertView alloc]
//                       initWithTitle:@""
//                       message:message
//                       delegate:self
//                       cancelButtonTitle:@"Yes"
//                       otherButtonTitles:@"No", nil];
//    av.tag = 10001;
//    [av show];
}


- (void) instagramPostDone:(NSString *)msg
{
    
    [self showSuccessDlg:msg icon:@"instagram_icon.png"];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self hideSuccessDlg];
    });

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //OK
        if (alertView.tag == 10000) {
            [super onTwitter:m_postObj];
            return;
        }
        else if (alertView.tag == 10001) {
            [super onInstagram:m_postObj];
            return;
        }
        
        else if (alertView.tag == 20000) {
            [self onShare];
            return;
        }
    }
    else {
        if (alertView.tag == 10000) {
            
            NSString * message = @"Syndicate to Instagram?";
            UIAlertView *av = [[UIAlertView alloc]
                               initWithTitle:@""
                               message:message
                               delegate:self
                               cancelButtonTitle:@"Yes"
                               otherButtonTitles:@"No", nil];
            av.tag = 10001;
            [av show];
            
            return;
        }
    }
}

- (void)showSuccessDlg:(NSString *) label icon:(NSString *) icon {
    if (self.navigationController.view == nil) {
        return;
    }
    
    if (progressHUD == nil) {
        progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:progressHUD];
    }
	
//	progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];

	// Set custom view mode
	progressHUD.mode = MBProgressHUDModeCustomView;
	
//	progressHUD.delegate = self;
	progressHUD.labelText = label;
	
	[progressHUD show:YES];
    
    //	[HUD hide:YES afterDelay:3];
//	[progressHUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    
}

- (void)hideSuccessDlg
{
	[progressHUD removeFromSuperview];
	progressHUD = nil;
}


@end
