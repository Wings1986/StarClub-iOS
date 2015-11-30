//
//  SettingController.m
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import "SettingController.h"
#import "MyDate.h"
#import "AvatarController.h"
#import "GHAppDelegate.h"
#import "DLImageLoader.h"

#import "ASIFormDataRequest.h"
#import "NSDictionary+JRAdditions.h"
#import "BuyCreditController.h"

#import "StarTracker.h"
#import <FacebookSDK/FacebookSDK.h>

#import "FBShareController.h"

@interface SettingController ()<BuyCreditControllerDelegate>
{
    BOOL bOld_social_fb;
    BOOL bOld_social_tw;
    
    BOOL m_bClickFB;
}
@end

@implementation SettingController

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
    
    self.title = @"Settings";
    [StarTracker StarSendView:self.title];
    
    
//    UITapGestureRecognizer *tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChooseImage:)];
//    tapGestureUser.numberOfTapsRequired = 1;
//    ivAvatar.userInteractionEnabled = YES;
//    [ivAvatar addGestureRecognizer:tapGestureUser];
//    [ivAvatar setImage:[UIImage imageNamed:@"demo-avatar"]];

    if ([Global getUserType] == FAN) {
        [self setCountryList];
    }
}
- (void) onChooseImage:(UITapGestureRecognizer*) recognize
{
    AvatarController * pController = [[AvatarController alloc] initWithGotoReturn];
    pController.delegate = self;
    [self onPush:pController];
}
#pragma mark ChooseImage Delegate
-(void) setAvatarImage:(UIImage *)_image
{
    [ivAvatar setImage:_image];
}

-(void) setCountryList{
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    countriesArray = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    
    for (NSString *countryCode in countryCodes)
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
        
        country = [country stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [countriesArray addObject: country];
    }
    
    [countriesArray sortUsingSelector:@selector(compare:)];
    
    //    NSLog(@"country list = %@", countriesArray);
}

- (void) changePassword
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Can you change password?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    // Alert style customization
    [[av textFieldAtIndex:0] setSecureTextEntry:YES];
    [[av textFieldAtIndex:1] setSecureTextEntry:YES];
    
    [[av textFieldAtIndex:0] setPlaceholder:@"Old Password"];
    [[av textFieldAtIndex:1] setPlaceholder:@"New Password"];
    
    [av show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // OK
        NSString * oldPassword = [alertView textFieldAtIndex:0].text;
        NSString * newPassword = [alertView textFieldAtIndex:1].text;
        
        if (oldPassword.length < 1) {
            [self showMessage:@"Attention!" message:@"Please input old password" delegate:nil firstBtn:nil secondBtn:@"OK"];
            return;
        }
        if (newPassword.length < 1) {
            [self showMessage:@"Attention!" message:@"Please input new password" delegate:nil firstBtn:nil secondBtn:@"OK"];
            return;
        }
        
        if ([oldPassword isEqualToString:tfPassword.text]) {
            tfPassword.text = newPassword;
            [self showMessage:@"" message:@"Password changed!" delegate:nil firstBtn:nil secondBtn:@"OK"];
            return;
        }
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
    
    
    [self setInterface];
    
    if ([Global getUserType] == FAN) {
        /* add sub views(date, country) */
        viewSubDate.frame = CGRectMake(0, self.view.frame.size.height + 88, viewSubDate.frame.size.width, viewSubDate.frame.size.height);
        [self.view addSubview:viewSubDate];
        
        viewSubCounty.frame = CGRectMake(0, self.view.frame.size.height + 88, viewSubCounty.frame.size.width, viewSubCounty.frame.size.height);
        [self.view addSubview:viewSubCounty];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
        
        UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
        [btnEdit setImage:[UIImage imageNamed:@"btn_save"] forState:UIControlStateNormal];
        [btnEdit addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
        self.navigationItem.rightBarButtonItem = btnItemEdit;
    }
    
    
    viewScroll.frame = viewMain.frame;
    if ([Global getUserType] != FAN) {
        viewScroll.contentSize = CGSizeMake(320, viewMain.frame.size.height);
    } else {
        viewScroll.contentSize = CGSizeMake(320, 695);
    }

}

-(void) setInterface{
    // set version
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    lbVersion.text = [NSString stringWithFormat:@"version : %@", version];
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    if (userInfo == nil) {
        return;
    }
    
    if ([Global getUserType] == FAN) {
        NSString * imageUrl = [userInfo objectForKey:@"img_url"];
        if (imageUrl != nil && imageUrl.length > 0) {
            [DLImageLoader loadImageFromURL:imageUrl
                                  completed:^(NSError *error1, NSData *imgData) {
                                      if (error1 == nil) {
                                          // if we have no errors
                                          UIImage * image = [UIImage imageWithData:imgData];
                                          [ivAvatar setImage:image];
                                      } else {
                                          // if we got error when load image
                                      }
                                  }];
        }
        
        NSString * userName = [userInfo objectForKey:@"name"];
        if (userName != nil && userName.length > 0) {
            tfFullName.text = userName;
        }
        NSString * email = [userInfo objectForKey:@"email"];
        if (email != nil && email.length > 0) {
            tfEmail.text = email;
        }
        NSString * password = [userInfo objectForKey:@"password"];
        if (password != nil && password.length > 0) {
            if ([password isEqualToString:@"0"]) {
                tfPassword.textColor = [UIColor grayColor];
                tfPassword.enabled = NO;
            } else {
                tfPassword.text = password;
            }
        }
        NSString * birthday = [userInfo objectForKey:@"birthday"];
        if (birthday != nil && birthday.length > 0) {
            if (![birthday isEqualToString:@"0000-00-00"]) {
                tfBirthday.text = birthday;
            }
            else {
                NSArray * arry1 = [[MyDate getDateString: [NSDate date] : DATE_DATE] componentsSeparatedByString:@"-"];
                NSString * birthday1 = [NSString stringWithFormat:@"%@-%@-%@", [arry1 objectAtIndex:0], [arry1 objectAtIndex:1], [arry1 objectAtIndex:2]];
                tfBirthday.placeholder = birthday1;
            }
        }
        
        
        curGender = [[userInfo objectForKey:@"gender"] intValue];
        [self changeGenderButton];
        
        NSString * city = [userInfo objectForKey:@"city"];
        if (city != nil && city.length > 0) {
            tfCity.text = city;
        }
        NSString * state = [userInfo objectForKey:@"state"];
        if (state != nil && state.length > 0) {
            tfState.text = state;
        }
        NSString * country = [userInfo objectForKey:@"country"];
        if (country != nil && country.length > 0) {
            tfCountry.text = country;
        }
        
        int credit = [[userInfo objectForKey:@"credit"] intValue];
        lbCreditNum.text = [NSString stringWithFormat:@"%d", credit];
    }
    
    BOOL bFacebook = [[userInfo objectForKey:@"enable_facebook"] boolValue];
    BOOL bTwitter  = [[userInfo objectForKey:@"enable_twitter"] boolValue];
    swFacebook.on = bFacebook;
    swTwitter.on = bTwitter;
}

#pragma mark ---- button event ------

#pragma mark Save

-(void) onSave:(id)sender
{
    NSString * userName = tfFullName.text;
    NSString * password = tfPassword.text;
    NSString * email = tfEmail.text;
    NSString * birthday = tfBirthday.text;
    NSString * gender = [NSString stringWithFormat:@"%d", curGender];
    NSString * city = tfCity.text;
    NSString * state = tfState.text;
    NSString * country = tfCountry.text;
    NSString * cridit = lbCreditNum.text;
    
    if (userName == nil && userName.length < 1) {
        [self showMessage:@"Warning!" message:@"Please input User Name" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    if (email == nil && email.length < 1) {
        [self showMessage:@"Warning!" message:@"Please input Email" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    if (password == nil && password.length < 6) {
        [self showMessage:@"Warning!" message:@"Please input Password at least 6" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    
    [self showLoading:@"Registering..."];
    
    NSString *url = [MyUrl getUpdateUser];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:[NSString stringWithFormat:@"%d",CID] forKey:@"cid"];
    [request setPostValue:TOKEN forKey:@"token"];
    [request setPostValue:USERID forKey:@"user_id"];
    [request setPostValue:userName forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:cridit forKey:@"credit"];
    
    
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
    
    NSData *imgData = [[NSData alloc] initWithData: UIImageJPEGRepresentation(ivAvatar.image, 1.0)];
    if (imgData != nil) {
        [request setData:imgData withFileName:@"picture.jpeg" andContentType:@"image/jpeg" forKey:@"picture"];
    }
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];
    
}

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
    
    [self hideLoading];
    
    NSString *responseString = [request responseString];
    NSLog(@"result = %@", responseString);
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:responseString];
    
    NSLog(@"result = %@", result);
    
    BOOL status = [[result objectForKey:@"status"] boolValue];
    if (status == true) {
        NSMutableDictionary * userInfo = [result objectForKey:@"info"];
        
        [userInfo setValue:tfPassword.text forKey:@"password"];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[userInfo dictionaryByReplacingNullsWithStrings] forKey:USER_INFO];
        [defaults setValue:TOKEN forKey:USER_TOKEN];
        [defaults synchronize];
        
    }
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    [self showFail];
}

#pragma mark -

-(IBAction) onBuyMore:(id)sender
{
    BuyCreditController * pController = [[BuyCreditController alloc] init];
    pController.delegate = self;
    [self onPush:pController];
//    [super gotoBuyCredit];
}

- (void) paymentDone {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary * userInfo = [defaults objectForKey:USER_INFO];
    int credit = [[userInfo objectForKey:@"credit"] intValue];
    
    lbCreditNum.text = [NSString stringWithFormat:@"%d", credit];
}

-(IBAction) onSignOut:(id)sender
{
    GHAppDelegate * appDelegate = APPDELEGATE;
    [appDelegate signOut];
    [appDelegate gotoLogInFrame];
}

-(IBAction) next:(id)sender
{
    UITextField * tf = (UITextField*) sender;
    if ([tf isFirstResponder]) {
        [tf resignFirstResponder];
    }
}

- (IBAction) onMale:(id)sender{
    curGender = MALE;
    [self changeGenderButton];
}
- (IBAction) onFemale:(id)sender{
    curGender = FOMALE;
    [self changeGenderButton];
}
- (void) changeGenderButton{
    
    if (curGender == MALE) {
        [btnMale setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        [btnFemale setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    } else if (curGender == FOMALE){
        [btnMale setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        [btnFemale setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
    } else {
        [btnMale setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        [btnFemale setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    }
}
-(IBAction) onChangedBirthday:(id) sender{
    NSDate * getDate = pvDate.date;
    
    NSArray * arry = [[MyDate getDateString: getDate : DATE_DATE] componentsSeparatedByString:@"-"];
    NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:0], [arry objectAtIndex:1], [arry objectAtIndex:2]];
    
    tfBirthday.text = birthday;
}

-(IBAction) onDateDone:(id) sender{
    [self hideDateView];
}
-(IBAction) onCountryDone:(id) sender{
    [self hideCountryView];
}
-(IBAction) onChangedFacebook:(id)sender
{
    bOld_social_fb = !swFacebook.on;
    
    [self uploadSocialShare];
}
-(IBAction) onChangedTwitter:(id)sender
{
    bOld_social_tw = !swTwitter.on;
    
    [self uploadSocialShare];
}

- (IBAction)onClickFacebook:(id)sender {
 
    FBShareController * pController = [[FBShareController alloc] init];
    [super onPush:pController];
}


-(void) uploadSocialShare
{
    [super showLoading:@"Setting..."];
    
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

    [request setPostValue:[NSNumber numberWithBool:swFacebook.on] forKey:@"enable_facebook"];
    [request setPostValue:[NSNumber numberWithBool:swTwitter.on] forKey:@"enable_twitter"];
    
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
        [userInfo setValue:[NSNumber numberWithBool:swFacebook.on] forKey:@"enable_facebook"];
        [userInfo setValue:[NSNumber numberWithBool:swTwitter.on] forKey:@"enable_twitter"];
        [defaults setObject:userInfo forKey:USER_INFO];
        [defaults synchronize];
        
        bOld_social_fb = swFacebook.on;
        bOld_social_tw = swTwitter.on;
        
        return;
    }
    
    [super showFail:@"NetWork fail"];
}

- (void)failSocialShare:(ASIHTTPRequest *)request{
    
    [super showFail:@"NetWork fail"];

    swFacebook.on = bOld_social_fb;
    swTwitter.on = bOld_social_tw;
}


-(void) keyboardDidShow: (NSNotification *)notif
{
    if (keyboardVisible)
	{
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
    
    offset = viewScroll.contentOffset;
    
    // Resize the scroll view to make room for the keyboard
	CGRect viewFrame = viewScroll.frame;
	originalFrame = viewFrame;
	viewFrame.size.height -= (keyboardSize.height-TOOLBAR_HEIGHT);
	viewScroll.frame = viewFrame;
    
    
    CGRect textFieldRect;
    for (UITextField *tfField in viewScroll.subviews) {
        if ([tfField isFirstResponder]) {
            textFieldRect = [tfField frame];
        }
    }
    
    textFieldRect = CGRectMake(textFieldRect.origin.x, textFieldRect.origin.y + 10, textFieldRect.size.width, textFieldRect.size.height);
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];
    
	
	// Keyboard is now visible
	keyboardVisible = YES;
}

-(void) keyboardDidHide: (NSNotification *)notif
{
	// Is the keyboard already shown
	if (!keyboardVisible)
	{
		return;
	}
	
	// Reset the frame scroll view to its original value
	viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;
	
	// Keyboard is no longer visible
	keyboardVisible = NO;
    
}


#pragma mark ------- Delegate ---------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
	
    if ([textField isEqual:tfPassword]) {
        [textField resignFirstResponder];
        shouldEdit = NO;
        
        [self changePassword];
    }
    else if ([textField isEqual:tfBirthday]) {
        [textField resignFirstResponder];
        
		shouldEdit = NO;
        [self hideCountryView];
		[self showDateview];
        
    } else if ([textField isEqual:tfCountry]) {
        
        [textField resignFirstResponder];
        
		shouldEdit = NO;
        [self hideDateView];
        [self showCountryView];
        
        
        NSString* country = tfCountry.text;
        
        int jj = [countriesArray indexOfObject:country];
        if (jj == NSNotFound) {
            jj = 0;
        }
        [pvCountry selectRow:jj
                 inComponent:0 animated:YES];
        
        [pvCountry reloadAllComponents];
        
    } else {
        [self hideDateView];
        [self hideCountryView];
	}
	
	return shouldEdit;
}


#pragma mark ---------- View Contry ---------
- (void)hideCountryView
{
    if (!country_visible) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    
    viewSubCounty.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
    [UIView commitAnimations];
    
    viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;
    
    country_visible = NO;
}

- (void)showCountryView
{
    
    for (UITextField *textField in viewScroll.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
    
    if (keyboardVisible) {
        return;
    }
    
    if (country_visible) {
        return;
    }
    
	
    [viewSubCounty setHidden:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewSubCounty.frame = CGRectMake(0, self.view.frame.size.height-260, 320, 260);
    
    [UIView commitAnimations];
    
    
    // Scroll view
    CGRect viewFrame = viewScroll.frame;
	originalFrame = viewFrame;
	viewFrame.size.height -= viewSubCounty.frame.size.height;
	viewScroll.frame = viewFrame;
    
    CGRect textFieldRect = tfCountry.frame;
	
    textFieldRect.origin.y += (10);
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];
    
    
    country_visible = YES;
    
}


#pragma mark -------- View Date
- (void)hideDateView
{
    if (!date_visible) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    
    viewSubDate.frame = CGRectMake(0, self.view.frame.size.height, viewSubDate.frame.size.width, viewSubDate.frame.size.height);
    
    [UIView commitAnimations];
    
    viewScroll.frame = originalFrame;
	
	// Reset the scrollview to previous location
	viewScroll.contentOffset = offset;
    
    date_visible = NO;
}

- (void)showDateview
{
    
    for (UITextField *textField in viewScroll.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
	
    if (keyboardVisible) {
        return;
    }
    
    if (tfBirthday.text.length != 0) {
        if ([tfBirthday.text isEqualToString:@"0000-00-00"]) {
            NSArray * arry = [[MyDate getDateString: [NSDate date] : DATE_DATE] componentsSeparatedByString:@"-"];
            NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:0], [arry objectAtIndex:1], [arry objectAtIndex:2]];

            pvDate.date = [MyDate dateFromString: birthday :DATE_DATE];
        }
        else {
            NSArray * arry = [tfBirthday.text componentsSeparatedByString:@"-"];
            NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:0], [arry objectAtIndex:1], [arry objectAtIndex:2]];

            pvDate.date = [MyDate dateFromString: birthday :DATE_DATE];
        }
        
    }
    
    if (date_visible) {
        return;
    }
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewSubDate.frame = CGRectMake(0, self.view.frame.size.height-viewSubDate.frame.size.height, viewSubDate.frame.size.width, viewSubDate.frame.size.height);
    
    [UIView commitAnimations];
    
    
    // Scroll view
    CGRect viewFrame = viewScroll.frame;
	originalFrame = viewFrame;
	viewFrame.size.height -= viewSubDate.frame.size.height;
	viewScroll.frame = viewFrame;
    
    CGRect textFieldRect = tfBirthday.frame;
	
    textFieldRect.origin.y += (10);
	[viewScroll scrollRectToVisible:textFieldRect animated:YES];
    
    date_visible = YES;
    
}

#pragma mark ------------------ picker view ----------

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == pvCountry) {
        return 1;
    }
    return 0;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == pvCountry) {
        int count = [countriesArray count];
        return count;
    }
    
    return 0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (pickerView == pvCountry) {
        return 300;
    }
    
    return 0;
}
-(UIView *)pickerView:(UIPickerView *)zonepickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    static const int kReusableTag = 1;
    if (view.tag != kReusableTag) {
        CGRect frame = CGRectZero;
        frame.size = [zonepickerView rowSizeForComponent:component];
        frame = CGRectInset(frame, 4.0, 4.0);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        view = label;
        view.tag = kReusableTag;
        view.opaque = NO;
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
    }
    
    UILabel *textLabel = (UILabel*)view;
    
    if (zonepickerView == pvCountry)
    {
        textLabel.text = [countriesArray objectAtIndex:row];
    }
    
	return view;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView == pvCountry){
        
        if (component == 0) {
            NSString * country = [countriesArray objectAtIndex:row];
            
            tfCountry.text = country;
        }
    }
    
}
@end
