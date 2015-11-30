//
//  LoginController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import "LoginController.h"

#import "AvatarController.h"
#import "SignupController.h"
#import "SignInController.h"
#import "GHAppDelegate.h"
#import "MyDate.h"

#import "HelpController.h"

#import <Social/Social.h>
#import "accounts/Accounts.h"

#import <FacebookSDK/FacebookSDK.h>


#import "JSON.h"
#import "DLImageLoader.h"


#import "ASIFormDataRequest.h"
#import "NSDictionary+JRAdditions.h"

#import "StarTracker.h"

#import <QuartzCore/QuartzCore.h>
#import "AVFoundation/AVFoundation.h"
#import "FBShareController.h"

@interface LoginController ()<FBLoginViewDelegate>
{
    IBOutlet UIImageView *mIvLogo;
    IBOutlet UIButton * btnFacebook;
    FBLoginView *loginView;
    
    IBOutlet UIButton * btnAgree;
    
    BOOL bLoggedIn;
    
    AVPlayer * avPlayer;
}

@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;


@end

@implementation LoginController

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
    
    [StarTracker StarSendView:@"Login Page"];

    [btnAgree setSelected:YES];

#ifdef LOGINVIDEO
    
    mIvLogo.hidden =YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVideo) name:@"LoginViewController" object:nil];
    
    NSString *filepath =[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"intro.mp4"];
//    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"intro" ofType:@"mp4" inDirectory:@"Class/RESOURCE"];
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    avPlayer = [AVPlayer playerWithURL:fileURL];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[avPlayer currentItem]];
    
    layer.frame = CGRectMake(0, 0, 320, 568);
    [self.view.layer insertSublayer:layer atIndex:0];
//    [self.view.layer insertSublayer:layer above:: layer];
    
    [avPlayer play];
#else
    
    mIvLogo.hidden =NO;
    
#endif


}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}
- (void) handleVideo
{
    [avPlayer play];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
    
    self.navigationController.navigationBarHidden = YES;
    
    UIImageView *backgroundView = (UIImageView*)[self.navigationController.view viewWithTag:999];
    if (backgroundView != nil) {
        [backgroundView removeFromSuperview];
    }

/*
    loginView.center = btnFacebook.center;
    
    if ([btnAgree isSelected]) {
        btnFacebook.hidden = YES;
        loginView.hidden = NO;
    } else {
        btnFacebook.hidden = NO;
        loginView.hidden = YES;
    }
*/
    
//    if ([FBSession.activeSession isOpen]) {
//        [FBSession.activeSession close];
//    }
//    [FBSession.activeSession closeAndClearTokenInformation];

}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -------------  button event -----------

-(IBAction) onClickFacebook:(id)sender
{
    if (![self isAgreed]) {
        return;
    }
    
    [self loginFacebook];
}

-(IBAction) onClickSignUp:(id)sender
{
    if (![self isAgreed])
        return;

    SignupController *pController = [[SignupController alloc] init];
    [self onPush:pController];
}
-(IBAction) onClickSignIn:(id)sender
{
    if (![self isAgreed])
        return;

    SignInController *pController = [[SignInController alloc] init];
    [self onPush:pController];
}

-(IBAction) onClickPrivacy:(id)sender
{
    
    [StarTracker StarSendView:@"Privacy"];
    
    NSString * urlString = [[SERVER stringByAppendingFormat:@"/index.php/viewhelp/pravacy/%d", CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    HelpController * pController = [[HelpController alloc] initWithURLString:urlString title:@"Privacy Policy"];
    [self onPush:pController];
}
-(IBAction) onClickTerms:(id)sender
{
    
    [StarTracker StarSendView:@"Terms of Service"];
    
    NSString * urlString = [[SERVER stringByAppendingFormat:@"/index.php/viewhelp/terms/%d", CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    HelpController * pController = [[HelpController alloc] initWithURLString:urlString title:@"Terms of Service"];
    [self onPush:pController];
}
-(IBAction) onClickAgree:(id)sender
{
    if ([btnAgree isSelected]) {
        [btnAgree setSelected:NO];
    }
    else {
        [btnAgree setSelected:YES];
    }
    
    
//    if ([btnAgree isSelected]) {
//        btnFacebook.hidden = YES;
//        loginView.hidden = NO;
//    } else {
//        btnFacebook.hidden = NO;
//        loginView.hidden = YES;
//    }

}

-(BOOL) isAgreed
{
    if (![btnAgree isSelected]) {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"To use this App you must agree to the terms of and conditions."
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil]
         show];

        return NO;
    }
    return YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) { // Cancel
        [StarTracker StarSendEvent:@"App Event" :@"Login" :@"Not Agree to Terms"];
        
    }
    else if (buttonIndex == 1) {
        [btnAgree setSelected:YES];
        
//        if ([btnAgree isSelected]) {
//            btnFacebook.hidden = YES;
//            loginView.hidden = NO;
//        } else {
//            btnFacebook.hidden = NO;
//            loginView.hidden = YES;
//        }
    }
}


#pragma mark -
#pragma mark Facebook
- (void) loginFacebook
{
    
//    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends", @"user_birthday",@"manage_pages",@"publish_actions",@"publish_stream",@"photo_upload",nil];
    
    
    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends",@"manage_pages",@"publish_actions",@"publish_stream",@"photo_upload",nil];
    
    if (FBSession.activeSession.state != FBSessionStateOpen) {
        
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [FBShareController sessionStateChanged:session state:state error:error];
                                          if (!error && state == FBSessionStateOpen) {
                                              NSArray *permissiones = [FBSession activeSession].permissions;
                                              for (NSString *permission in permissiones) {
                                                  
                                                  if ([permission isEqualToString:@"publish_actions"]) {
                                                      
                                                  }
                                              }

                                              [self sendRequests];
                                          }
                                      }];
    } else {
        [self sendRequests];
    }
}



// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
    [StarTracker StarSendEvent:@"App Event" :@"FB Login Error" :text];
}



- (void)sendRequests
{
    
    NSDictionary * params = nil;
    
    [FBRequestConnection startWithGraphPath:@"/me"
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection * connect, id result, NSError* err) {
                              
                              NSLog(@"result = %@", result);
                              
                              [self loginWithData:result];
                              
                          }];
}


// Show the user the logged-out UI
//- (void)userLoggedOut
//{
//     Set the button title as "Log in with Facebook"
//    UIButton *loginButton = [self.customLoginViewController loginButton];
//    [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];

//    Confirm logout message
 //  [self showMessage:@"You're now logged out" withTitle:@""];
//}



/*- (void) loginFacebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
 
        [self showLoading:@"Get Data"];
 
        if(!_accountStore)
            _accountStore = [[ACAccountStore alloc] init];
 
 
        ACAccountType *facebookTypeAccount = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
 
        [_accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                               options:@{ACFacebookAppIdKey: FB_ID, ACFacebookPermissionsKey: @[@"email"]}
                                            completion:^(BOOL granted, NSError *error) {
                                                if(granted){
                                                    NSArray *accounts = [_accountStore accountsWithAccountType:facebookTypeAccount];
                                                    _facebookAccount = [accounts lastObject];
                                                    NSLog(@"Success");
 
                                                    [self me];
                                                }else{
                                                    // ouch
                                                    
                                                    NSLog(@"Fail");
                                                    NSLog(@"Error: %@", error);
                                                    
                                                    [self performSelectorOnMainThread:@selector(loginFail) withObject:nil waitUntilDone:NO];
                                                }
                                            }];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"First You have to register Facebook Account in Settings->Facebook"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)me{
    
    [self showChangeLabel:@"Connect Facebook"];
    
    NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    
    SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                              requestMethod:SLRequestMethodGET
                                                        URL:meurl
                                                 parameters:nil];
    
    merequest.account = _facebookAccount;
    
    [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", meDataString);
        
        NSDictionary * result = [meDataString JSONValue];
        NSDictionary * errorDic = [result objectForKey:@"error"];
        if (errorDic != nil) {
            
            NSString * message = [errorDic objectForKey:@"message"];
            
            [self performSelectorOnMainThread:@selector(mefail:) withObject:message waitUntilDone:NO];
            
            return;
        }

        NSLog(@"facebook info = %@", result);
        [self loginWithData:result];
        
    }];
    
}
*/


- (void) loginWithData:(NSDictionary*)result
{
    
    [self showLoading:@"Loading..."];
    
    
    NSString * userId = [result objectForKey:@"id"];
    NSString * userName = [result objectForKey:@"name"];
    NSString * firstName = [result objectForKey:@"first_name"];
    NSString * lastName = [result objectForKey:@"last_name"];
    NSString * birthday = [result objectForKey:@"birthday"];
    if (birthday != nil) {
        NSArray *arrBirthItem = [birthday componentsSeparatedByString:@"/"];
        if ([arrBirthItem count] == 3) {
            birthday = [NSString stringWithFormat:@"%@-%@-%@", [arrBirthItem objectAtIndex:2], [arrBirthItem objectAtIndex:0], [arrBirthItem objectAtIndex:1]];
        } else {
            birthday = [MyDate getDateString:[NSDate date] :DATE_DATE];
        }
    } else {
        birthday = [MyDate getDateString:[NSDate date] :DATE_DATE];
    }
    
    NSString * country = nil, *city = nil, *state = nil;
    
//    country = [result objectForKey:@"country"];
//    state = [result objectForKey:@"state"];
//    city = [result objectForKey:@"city"];
    
    NSString * location = [[result objectForKey:@"location"] objectForKey:@"name"];
    NSArray *arrLoc = [location componentsSeparatedByString:@","];
    
    if ([arrLoc count] != 0) {
        city = [arrLoc objectAtIndex:0];
        
        if ([arrLoc count] > 1) {
            state = [arrLoc objectAtIndex:1];
        }

        if ([arrLoc count] > 2) {
            country = [arrLoc objectAtIndex:2];
        }
    }
    
    
    NSString * email = [result objectForKey:@"email"];
    NSString * gender = [result objectForKey:@"gender"];        // male;
    NSString * profilePicURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userId];
    
    
    [DLImageLoader loadImageFromURL:profilePicURL
                          completed:^(NSError *error1, NSData *imgData) {
                              if (error1 == nil) {
                                  // if we have no errors
                                  
                                  NSString *url = [MyUrl getSignUpUrl];
                                  
                                  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
                                  request.requestMethod = @"POST";
                                  
                                  [request setPostValue:@"1" forKey:@"facebook"];
                                  [request setPostValue:[NSString stringWithFormat:@"%d", CID] forKey:@"cid"];
                                  [request setPostValue:userName forKey:@"username"];
                                  [request setPostValue:firstName forKey:@"firstname"];
                                  [request setPostValue:lastName forKey:@"lastname"];
                                  [request setPostValue:email forKey:@"email"];
                                  [request setPostValue:DEVICETOKEN forKey:@"ud_token"];
                                  
                                  if ([gender isEqualToString:@"male"]) {
                                      [request setPostValue:@"0" forKey:@"gender"];
                                  } else {
                                      [request setPostValue:@"1" forKey:@"gender"];
                                  }
                                  
                                  if (birthday.length > 0) {
                                      [request setPostValue:birthday forKey:@"birthday"];
                                  }
                                  if (gender.length > 0){
                                      [request setPostValue:gender forKey:@"gender"];
                                  }
                                  if (city.length > 0) {
                                      [request setPostValue:city forKey:@"city"];
                                  }
                                  if (state.length > 0) {
                                      [request setPostValue:state forKey:@"state"];
                                  }
                                  if (country.length > 0) {
                                      [request setPostValue:country forKey:@"country"];
                                  }
                                  
                                  if (imgData != nil) {
                                      [request setData:imgData withFileName:@"picture.jpeg" andContentType:@"image/*" forKey:@"picture"];
                                  }
                                  
                                  [request setDelegate:self];
                                  [request setDidFinishSelector:@selector(uploadRequestFinished:)];
                                  [request setDidFailSelector:@selector(uploadRequestFailed:)];
                                  
                                  [StarTracker StarSendEvent:@"App Event" :@"Login" :@"Logging in!"];
                                  
                                  [request startAsynchronous];
                                  
                                  
                              } else {
                                  // if we got error when load image
                              }
                              
                              
                          }];
}


- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    NSLog(@"result = %@", responseString);
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:responseString];
    
    NSLog(@"result = %@", result);
    
    BOOL status = [[result objectForKey:@"status"] boolValue];
    if (status == true) {
        
        [self hideLoading];

        NSDictionary * userInfo = [result objectForKey:@"info"];
        NSString * userToken = [result objectForKey:@"token"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[userInfo dictionaryByReplacingNullsWithStrings] forKey:USER_INFO];
        [defaults setValue:userToken forKey:USER_TOKEN];
        [defaults synchronize];
        
        GHAppDelegate * appDelegate = APPDELEGATE;
        [appDelegate gotoMainFrame];
        
        return;
    }
    else {
        NSString * ErrMessage = [result objectForKey:@"message"];
        [self showFail:ErrMessage];
    }
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    [self hideLoading];
}

-(void) mefail:(NSString*) msg
{
    [self hideLoading];
    
    [StarTracker StarSendEvent:@"App Event" :@"Login" :@"Loggin Error!"];
    
    [[[UIAlertView alloc] initWithTitle:@"error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
}
-(void) loginFail{
    [self hideLoading];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                    message:@"Facebook Login Fail. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

/*
#pragma mark -
#pragma mark Facebook APP login

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {

    if (!bLoggedIn) {
        return;
    }
    
    NSLog(@"user info = %@", user);
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];

    [dic setValue:[user objectForKey:@"id"]  forKey:@"id"];
    [dic setValue:user.name forKey:@"name"];
    [dic setValue:[user objectForKey:@"first_name"] forKey:@"first_name"];
    [dic setValue:[user objectForKey:@"last_name"] forKey:@"last_name"];
    [dic setValue:user.birthday forKey:@"birthday"];
    [dic setValue:[user objectForKey:@"email"] forKey:@"email"];
    [dic setValue:[user objectForKey:@"gender"] forKey:@"gender"];
    
    [dic setValue:[user objectForKey:@"location"] forKey:@"location"];
//    id<FBGraphPlace> fbPlace = [user location];
//    id<FBGraphLocation> fbLocation = [fbPlace location];
//    NSString * city = [fbLocation city];
//    NSString * country = [fbLocation country];
//    NSString * state = [fbLocation state];
//
//    [dic setValue:city forKey:@"city"];
//    [dic setValue:state forKey:@"state"];
//    [dic setValue:country forKey:@"country"];
    
    [self loginWithData:dic];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {

    NSLog(@"You're logged in as");
    bLoggedIn = YES;
}

 */
// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    //    self.profilePictureView.profileID = nil;
    //    self.nameLabel.text = @"";
    //    self.statusLabel.text= @"You're not logged in!";
    NSLog(@"You're not logged in!");
    bLoggedIn = NO;
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        [StarTracker StarSendEvent:@"App Event" :@"Login" :@"FB Login Error"];
        alertTitle  = @"Facebook COmmunication Issues";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


@end
