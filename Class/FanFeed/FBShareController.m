//
//  FBShareController.m
//  StarClub
//
//  Created by SilverStar on 5/23/14.
//
//

#import "FBShareController.h"

#import "FBShareCell.h"
#import <FacebookSDK/FacebookSDK.h>

#import "ASIFormDataRequest.h"
#import "NSDictionary+JRAdditions.h"

#import "GHAppDelegate.h"
#import "StarTracker.h"


@interface FBShareController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView * mTableView;
    UIButton * btnFbLogin;
    
    NSMutableArray *  arrPages;
}

@end

@implementation FBShareController

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
    
    self.title = @"Facebook Share";
    
    btnFbLogin = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 40)];
    [btnFbLogin setImage:[UIImage imageNamed:@"btn_fb_login"] forState:UIControlStateNormal];
    [btnFbLogin addTarget:self action:@selector(onFacebookLogin) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemRight = [[UIBarButtonItem alloc] initWithCustomView:btnFbLogin];
    self.navigationItem.rightBarButtonItem = btnItemRight;
    
    [self refreshFbButton];
            [self getFBPageInfo];
    if (FBSession.activeSession.isOpen) {
        [self getFBPageInfo];
    }
    else {
        mTableView.delegate = nil;
        mTableView.dataSource = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void) refreshFbButton
{
    if (FBSession.activeSession.isOpen) {
        [btnFbLogin setImage:[UIImage imageNamed:@"btn_fb_logout"] forState:UIControlStateNormal];
    }
    else {
        [btnFbLogin setImage:[UIImage imageNamed:@"btn_fb_login"] forState:UIControlStateNormal];
    }
}
- (void) onFacebookLogin
{
    if (FBSession.activeSession.isOpen) {
        
        [self logoutfbadmin];

        // log out
 /*
        NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        int fb_user = [[userInfo objectForKey:@"facebook"] intValue];

        if (fb_user == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NOTE"
                                                            message:@"Logging our of Facebook will also log you out of the app"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Cancel", nil];
            alert.tag = 230;
            [alert show];
        }
        else {
            [self logoutfbadmin];
        }
*/
  
  
    }
    else {
        [self getFBPageInfo];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 230) {
        if (buttonIndex == 0) { // OK
            GHAppDelegate * appDelegate = APPDELEGATE;
                [appDelegate logoutFB];
//            [appDelegate signOut];
            [appDelegate gotoLogInFrame];
        }
    }
}


- (void) logoutfbadmin
{
    
    GHAppDelegate * delegate = (GHAppDelegate*)APPDELEGATE;
    [delegate logoutFB];
    [self refreshFbButton];
    
    mTableView.delegate = nil;
    mTableView.dataSource = nil;
    [mTableView reloadData];
}

- (void) getFBPageInfo
/*
 {
        
//NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends", @"user_birthday",@"manage_pages",@"publish_actions",@"publish_stream",@"photo_upload",nil];
    
    
    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends",@"manage_pages",@"publish_stream",@"photo_upload",nil];
    
    if (FBSession.activeSession.state != FBSessionStateOpen) {

            [FBSession openActiveSessionWithReadPermissions:permissions
               allowLoginUI:YES
               openWithBehavior:FBSessionLoginBehaviorForcingWebView
                completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
               [FBShareController sessionStateChanged:session state:state error:error];
                   if (!error && state == FBSessionStateOpen) {
                    [self sendRequests];
                   }
               }];
    } else {
          [self sendRequests];
    }
}

 */

{
    if (FBSession.activeSession.isOpen) {
        // login is integrated with the send button -- so if open, we send
        [self sendRequests];
    } else {
        NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends", @"user_birthday",@"manage_pages",@"publish_stream",@"publish_actions",@"photo_upload",nil];
        

        
        [FBSession setActiveSession: [[FBSession alloc] initWithPermissions:permissions   ] ];
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView     completionHandler:^(FBSession *session, FBSessionState status, NSError *error)

         {
             if (error) {
                 [FBShareController displayFBerrorMsg:error msgTitle:@"Page Info Error"];
                 
             } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                 // send our requests if we successfully logged in
                 [self sendRequests];
             }
         }];
    }
    
}





+ (void)displayFBerrorMsg:(NSError *) error msgTitle:(NSString *) title
{
    NSLog(@"Error");
    NSString *alertText;
    NSString *alertTitle;
    // If the error requires people using an app to make an action outside of the app in order to recover
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
        alertText = [FBErrorUtility userMessageForError:error];
        [[[UIAlertView alloc] initWithTitle:title
                                    message:alertText
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
        [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
    } else {
        
        // If the user cancelled login, do nothing
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            NSLog(@"User cancelled login");
            alertTitle = @"Facebook Login Error";
            alertText = @"User cancelled login. \nPlease log in again.";
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertText
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
            [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
            
            // Handle session closures that happen outside of the app
        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
            alertTitle = @"Session Error";
            alertText = @"Your current session is no longer valid. Please log in again.";
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertText
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
            
        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions){
            alertTitle = @"Permissions Error";
            alertText = @"The user hasn't authorized or doesn't have sufficient permissions to perform this action";
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertText
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
            [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
            // For simplicity, here we just show a generic message for all other errors
            // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            
        } else {
            //Get more error information from the error
            NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
            
            // Show the user an error message
            alertTitle = @"Something went wrong";
            alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertText
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
            [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
        }
    }
    
    // Clear this token
//    [FBSession.activeSession closeAndClearTokenInformation];
    // Show the user the logged-out UI
    //                                      [self userLoggedOut];
    
    
}





// This method will handle ALL the session state changes in the app
+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{

    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Facebook Session opened");

        // Show the user the logged-in UI
//        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Facebook Session closed");
        // Show the user the logged-out UI
        
        NSString *alertText = [FBErrorUtility userMessageForError:error];
        [[[UIAlertView alloc] initWithTitle:@"Facebook \nsession closed!"
                                    message:alertText
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
//        [self userLoggedOut];
    }

    
    // Handle errors
    if (error){

        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertText = [FBErrorUtility userMessageForError:error];
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertText
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
            [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                alertTitle = @"Facebook Login Error";
                alertText = @"User cancelled login. \nPlease log in again.";
                [[[UIAlertView alloc] initWithTitle:alertTitle
                                            message:alertText
                                           delegate:self
                                  cancelButtonTitle:@"OK!"
                                  otherButtonTitles:nil] show];
                [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [[[UIAlertView alloc] initWithTitle:alertTitle
                                            message:alertText
                                           delegate:self
                                  cancelButtonTitle:@"OK!"
                                  otherButtonTitles:nil] show];
                
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions){
                alertTitle = @"Permissions Error";
                alertText = @"The user hasn't authorized or doesn't have sufficient permissions to perform this action";
                [[[UIAlertView alloc] initWithTitle:alertTitle
                                            message:alertText
                                           delegate:self
                                  cancelButtonTitle:@"OK!"
                                  otherButtonTitles:nil] show];
                [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
                
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [[[UIAlertView alloc] initWithTitle:alertTitle
                                            message:alertText
                                           delegate:self
                                  cancelButtonTitle:@"OK!"
                                  otherButtonTitles:nil] show];
                [StarTracker StarSendEvent:@"App Event" :@"FB Error" :alertTitle];
            }
        }
        
        // Clear this token
//        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        //   [self userLoggedOut];
        

    }
}


- (void)sendRequests
{
    
    NSDictionary * params = nil;
    
    [FBRequestConnection startWithGraphPath:@"/me/accounts"
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection * connect, id result, NSError* err) {
                              
                              NSLog(@"result = %@", result);
                              
                              NSDictionary *dict = result;
                              arrPages = [dict objectForKey:@"data"];
                              
                              [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:YES];

                          }];
}

- (void) refreshTableView
{
    mTableView.delegate = self;
    mTableView.dataSource = self;

    [mTableView reloadData];
    
    [self refreshFbButton];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (arrPages == nil) {
        return 1;
    }
    else if ([arrPages count] > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return  [arrPages count];
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 40.0f;
    }
    else {
        return 50.0f;
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 50-HEADER_HEIGHT, tableView.frame.size.width-20, HEADER_HEIGHT)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel * lb = [[UILabel alloc] initWithFrame:view.frame];
    if (section == 0) {
        lb.text = @"";
    } else {
        lb.text = @"CHOOSE A PAGE";
    }
    lb.font = [UIFont boldSystemFontOfSize:16.0f];
    lb.textColor = [UIColor blackColor];
    
    [view addSubview:lb];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FBShareCell";
    
    FBShareCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        UIViewController    *viewController = [[UIViewController alloc] initWithNibName:@"FBShareCell" bundle:nil];
        cell =(FBShareCell*) viewController.view;
    }
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString * fbPageName = [userInfo objectForKey:@"facebook_page_id"];

    if (indexPath.section == 0) {
        cell.lbName.text = @"Timeline";
        
        if (fbPageName == nil || (NSString *)[NSNull null] == fbPageName || [fbPageName isEqualToString:@""] ) {
            [cell.ivChecker setImage:[UIImage imageNamed:@"checked.png"]];
        }
        else {
            [cell.ivChecker setImage:[UIImage imageNamed:@"unchecked.png"]];
        }
    }
    else if (indexPath.section == 1) {
        NSString * pageName = [[arrPages objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSString * pageId = [[arrPages objectAtIndex:indexPath.row] objectForKey:@"id"];
        
        cell.lbName.text = pageName;
        if ([pageId isEqualToString:fbPageName]) {
            [cell.ivChecker setImage:[UIImage imageNamed:@"checked.png"]];
        }
        else {
            [cell.ivChecker setImage:[UIImage imageNamed:@"unchecked.png"]];
        }
        
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSString * fbPageId = @"";
    
    if (indexPath.section == 0 ) {
        fbPageId = @"";
    }
    else {
        fbPageId = [[arrPages objectAtIndex:indexPath.row] objectForKey:@"id"];
    }

    [self uploadSocialShare:fbPageId];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:USER_INFO]];
//    
//    [userInfo setValue:fbPageName forKey:@"facebook_page_id"];
//
//    [defaults setObject:userInfo forKey:USER_INFO];
//    [defaults synchronize];
    
//    [tableView reloadData];
}


#pragma mark - upload

-(void) uploadSocialShare:(NSString*) pageId
{
    NSString *url = [MyUrl getUpdateUser];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:[NSString stringWithFormat:@"%d",CID] forKey:@"cid"];
    [request setPostValue:TOKEN forKey:@"token"];
    [request setPostValue:USERID forKey:@"user_id"];
    [request setPostValue:DEVICETOKEN forKey:@"ud_token"];
    
    [request setPostValue:pageId forKey:@"facebook_page_id"];
    
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

        NSDictionary * userInfo = [result objectForKey:@"info"];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[userInfo dictionaryByReplacingNullsWithStrings] forKey:USER_INFO];
        [defaults synchronize];

        [mTableView reloadData];
    }
}

- (void)failSocialShare:(ASIHTTPRequest *)request{
}

@end
