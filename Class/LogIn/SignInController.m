//
//  SignInController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import "SignInController.h"
#import "GHAppDelegate.h"

#import "SBJsonParser.h"
#import "NSDictionary+JRAdditions.h"
#import "StarTracker.h"

@interface SignInController ()

@end

@implementation SignInController

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
    
    [StarTracker StarSendView:@"Sign-In"];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Sign In";
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_signin.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickGo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
}

-(void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (![txtEmail isFirstResponder]) {
        [txtEmail becomeFirstResponder];
    }
    
}

-(IBAction) onClickBack:(id)sender
{
    [self onBack];
}
-(IBAction) onClickGo:(id)sender
{
    NSString* userName = txtEmail.text;
    NSString* password = txtPassword.text;
    
    if (userName == nil || userName.length < 1) {
        [self showMessage:@"Warning!" message:@"Please Input Email" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    if (password == nil || password.length < 1) {
        [self showMessage:@"Warning!" message:@"Please Input Password" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    
    if ([txtEmail isFirstResponder]) {
        [txtEmail resignFirstResponder];
    } else if ([txtPassword isFirstResponder]) {
        [txtPassword resignFirstResponder];
    }
    
    [self showLoading:@"Login..."];
    
    [NSThread detachNewThreadSelector: @selector(postServer) toTarget:self withObject:nil];
    
}

-(void) postServer
{
    NSString* userName = txtEmail.text;
    NSString* password = txtPassword.text;

    NSString *urlString;
    
    urlString = [MyUrl getLoginUrl:userName password:password];
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];

    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:pinResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            [self hideLoading];
            
            NSLog(@"Login success");
            
            NSMutableDictionary * userInfo = [result objectForKey:@"info"];
            NSString * userToken = [result objectForKey:@"token"];
            
            [userInfo setValue:password forKey:@"password"];

            [[NSUserDefaults standardUserDefaults] setObject:[userInfo dictionaryByReplacingNullsWithStrings] forKey:USER_INFO];
            [[NSUserDefaults standardUserDefaults] setValue:userToken forKey:USER_TOKEN];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            GHAppDelegate * appDelegate = APPDELEGATE;
            [appDelegate gotoMainFrame];

            return;
        }
        else {
            NSString * ErrMessage = [result objectForKey:@"message"];
            [self showFail:ErrMessage];

            return;
        }
    }
    
    [self showFail:@"Login Fail"];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];//Dismiss the keyboard.
    //Add action you want to call here.
    
    if (textField == txtPassword) {
        [self onClickGo:nil];
    }
    return YES;
}


-(IBAction) onForgetPassword:(id)sender
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Please input your email address" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        NSString * email = [alertView textFieldAtIndex:0].text;

        [NSThread detachNewThreadSelector: @selector(postForgetPWServer:) toTarget:self withObject:email];
    }
}


-(void) postForgetPWServer:(NSString*) email
{
    if ([txtEmail isFirstResponder]) {
        [txtEmail resignFirstResponder];
    } else if ([txtPassword isFirstResponder]) {
        [txtPassword resignFirstResponder];
    }
    
    NSString* urlResult = [MyUrl getForgetPasswordUrl:email];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlResult];
    
    NSLog(@"result = %@", result);
    
    if (result != nil) {
        BOOL value = [[result objectForKey:@"status"] boolValue];
        if (value == true) {
            
            NSString * ErrMessage = @"You sent successfully. Please check your email";
            [super showMessage:@"" message:ErrMessage delegate:nil firstBtn:@"OK" secondBtn:nil];
        }
        else {
            NSString * ErrMessage = [result objectForKey:@"message"];
            [self showFail:ErrMessage];
        }
    }
    
}


@end
