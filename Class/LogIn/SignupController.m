//
//  SignupController.m
//  StarClub
//
//  Created by MAYA on 12/31/13.
//
//

#import "SignupController.h"
#import "MyDate.h"
#import "GHAppDelegate.h"

#import "ASIFormDataRequest.h"
#import "SBJsonParser.h"

#import "NSDictionary+JRAdditions.h"
#import "UIImagePickerController+NonRotating.h"

#import "StarTracker.h"


@interface SignupController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@end

@implementation SignupController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithImageName:(UIImage *)_image
{
    self = [super init];
    if (self) {
        self.m_imgAvatar = _image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [StarTracker StarSendView:@"Sign-Up"];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
    
    self.automaticallyAdjustsScrollViewInsets = false;
//    [self setCountryList];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Create Profile";
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_signup.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickNext:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    
    // init
    UITapGestureRecognizer *tapGestureUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChooseImage:)];
    tapGestureUser.numberOfTapsRequired = 1;
    ivAvatar.userInteractionEnabled = YES;
    [ivAvatar addGestureRecognizer:tapGestureUser];

//    NSArray * arry = [[MyDate getDateString: [NSDate date] : DATE_DATE] componentsSeparatedByString:@"-"];
//    NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:0], [arry objectAtIndex:1], [arry objectAtIndex:2]];
//    tfBirthday.text = birthday;
    
//    curGender = MALE;
//    [self changeGenderButton];

    
    
    /* add sub views(date, country) */
//    viewSubDate.frame = CGRectMake(0, self.view.frame.size.height + 88, viewSubDate.frame.size.width, viewSubDate.frame.size.height);
//    [self.view addSubview:viewSubDate];
//    
//    viewSubCounty.frame = CGRectMake(0, self.view.frame.size.height + 88, viewSubCounty.frame.size.width, viewSubCounty.frame.size.height);
//    [self.view addSubview:viewSubCounty];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];


	originalFrame = CGRectMake(0, 0, viewMain.frame.size.width, viewMain.frame.size.height);
    viewScroll.contentSize = CGSizeMake(320, 436);
    viewScroll.frame = CGRectMake(0, 0, viewMain.frame.size.width, viewMain.frame.size.height);
    
    [viewMain addSubview:viewScroll];
}

/*
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
*/

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---- button event ------
-(IBAction) onClickBack:(id)sender
{
    [self onBack];
}

-(IBAction) onClickNext:(id)sender
{
    NSString * firstName = tfFullName.text;
    NSString * lastName = tfLastName.text;
    NSString * userName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSString * password = tfPassword.text;
    NSString * email = tfEmail.text;
    
    if (firstName == nil || firstName.length < 1) {
        [self showMessage:@"Warning!" message:@"Please input First Name" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    if (lastName == nil || lastName.length < 1) {
        [self showMessage:@"Warning!" message:@"Please input Last Name" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    if (email == nil || email.length < 1) {
        [self showMessage:@"Warning!" message:@"Please input Email" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
    if (password == nil || password.length < 6) {
        [self showMessage:@"Warning!" message:@"Please input Password (min. 6 Chars.)" delegate:nil firstBtn:@"OK" secondBtn:nil];
        return;
    }
//    if (birthday == nil && birthday.length < 1) {
//        [self showMessage:@"Warning!" message:@"Please input your birthday" delegate:nil firstBtn:@"OK" secondBtn:nil];
//        return;
//    }
//    if (city == nil && city.length < 1) {
//        [self showMessage:@"Warning!" message:@"Please input city" delegate:nil firstBtn:@"OK" secondBtn:nil];
//        return;
//    }
//    if (state == nil && state.length < 1) {
//        [self showMessage:@"Warning!" message:@"Please input state" delegate:nil firstBtn:@"OK" secondBtn:nil];
//        return;
//    }
//    if (country == nil && country.length < 1) {
//        [self showMessage:@"Warning!" message:@"Please input country" delegate:nil firstBtn:@"OK" secondBtn:nil];
//        return;
//    }
    
    
    if ([tfFullName isFirstResponder]) {
        [tfFullName resignFirstResponder];
    } else if ([tfLastName isFirstResponder]) {
        [tfLastName resignFirstResponder];
    } else if ([tfEmail isFirstResponder]) {
        [tfEmail resignFirstResponder];
    } else if ([tfPassword isFirstResponder]) {
        [tfPassword resignFirstResponder];
    }
    
    [self showLoading:@"Registering..."];
    
    NSString *url = [MyUrl getSignUpUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:@"0" forKey:@"facebook"];
    [request setPostValue:[NSString stringWithFormat:@"%d", CID] forKey:@"cid"];
    [request setPostValue:userName forKey:@"username"];
    [request setPostValue:firstName forKey:@"firstname"];
    [request setPostValue:lastName forKey:@"lastname"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:DEVICETOKEN forKey:@"ud_token"];
    
//    if (birthday.length > 0) {
//        [request setPostValue:birthday forKey:@"birthday"];
//    }
//    if (gender.length > 0){
//        [request setPostValue:gender forKey:@"gender"];
//    }
//    if (city.length > 0) {
//        [request setPostValue:city forKey:@"city"];
//    }
//    if (state.length > 0) {
//        [request setPostValue:state forKey:@"state"];
//    }
//    if (country.length > 0) {
//        [request setPostValue:country forKey:@"country"];
//    }
    
    NSData *imgData = [[NSData alloc] initWithData: UIImageJPEGRepresentation(self.m_imgAvatar, 1.0)];
    if (imgData != nil) {
        [request setData:imgData withFileName:@"picture.jpeg" andContentType:@"image/jpeg" forKey:@"picture"];
    }
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];

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

        NSMutableDictionary * userInfo = [result objectForKey:@"info"];
        NSString * userToken = [result objectForKey:@"token"];
        
        [userInfo setValue:tfPassword.text forKey:@"password"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[userInfo dictionaryByReplacingNullsWithStrings] forKey:USER_INFO];
        [defaults setValue:userToken forKey:USER_TOKEN];
        [defaults synchronize];
        
        GHAppDelegate * appDelegate = APPDELEGATE;
        [appDelegate gotoMainFrame];
        
        return;
    }
    else  {
        NSString * ErrMessage = [result objectForKey:@"message"];
        [self showFail:ErrMessage];
        
        return;
    }
    
    [self showFail:@"Please Check Network Connection."];
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    NSLog(@"result = %@", responseString);

    [self hideLoading];
}


-(IBAction) next:(id)sender
{
    UITextField * tf = (UITextField*) sender;
    if ([tf isFirstResponder]) {
        [tf resignFirstResponder];
    }
    
//    if ([tfFullName isFirstResponder]) {
//		[tfEmail becomeFirstResponder];
//	}else if ([tfEmail isFirstResponder]){
//        [tfPassword becomeFirstResponder];
//    }else if ([tfPassword isFirstResponder]){
//        [tfP]
//    }
}

- (void) onChooseImage:(UITapGestureRecognizer*) recognize
{
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Upload Profile Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"From Camera Roll", @"Take Photo", nil];
    [action showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self onClickCameraRoll:nil];
    }
    else if (buttonIndex == 1) {
        [self onClickTakePhoto:nil];
    }
}

-(IBAction) onClickCameraRoll:(id)sender
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [imagePicker setAllowsEditing:YES];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    
}
-(IBAction) onClickTakePhoto:(id)sender
{
    if( ![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
        return;
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [imagePicker setAllowsEditing:YES];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.m_imgAvatar = [image copy];
    
    int width = self.m_imgAvatar.size.width;
    int height = self.m_imgAvatar.size.height;
    int minValue = MIN(width, height);
    
    float newWidth = minValue > AVATAR_IMAGE_SIZE ? AVATAR_IMAGE_SIZE : minValue;
    float newHeight = height * newWidth/width;
    
    CGSize size = CGSizeMake(newWidth, newHeight);
    
    self.m_imgAvatar = [self.m_imgAvatar imageResize:self.m_imgAvatar andResizeTo:size];
    
    [ivAvatar setImage:self.m_imgAvatar];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



/*
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
    } else {
        [btnMale setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        [btnFemale setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
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
*/

-(void) keyboardDidShow: (NSNotification *)notif
{
    if (keyboardVisible)
	{
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
    
    offset = viewScroll.contentOffset;

    // Resize the scroll view to make room for the keyboard
    
    CGRect viewFrame = originalFrame;
	viewFrame.size.height -= keyboardSize.height;
	viewScroll.frame = viewFrame;

    
    CGRect textFieldRect;
    for (UITextField *tfField in viewScroll.subviews) {
        if ([tfField isFirstResponder]) {
            textFieldRect = [tfField frame];
        }
    }
    
    CGRect rt = CGRectMake(textFieldRect.origin.x, textFieldRect.origin.y + 10.0 + 64.0f, textFieldRect.size.width, textFieldRect.size.height);
	[viewScroll scrollRectToVisible:rt animated:YES];
//    [viewScroll scrollRectToVisible:textFieldRect animated:YES];

	
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
/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldEdit = YES;
	
    if ([textField isEqual:tfBirthday]) {
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
	
    textFieldRect.origin.y += (40);
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
    
    if (date_visible) {
        return;
    }
    
    if (tfBirthday.text.length != 0) {
        NSArray * arry = [tfBirthday.text componentsSeparatedByString:@"-"];
        NSString * birthday = [NSString stringWithFormat:@"%@-%@-%@", [arry objectAtIndex:0], [arry objectAtIndex:1], [arry objectAtIndex:2]];
        
        pvDate.date = [MyDate dateFromString: birthday :DATE_DATE];
    }
    

    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    
    viewSubDate.frame = CGRectMake(0, self.view.frame.size.height-260, viewSubDate.frame.size.width, viewSubDate.frame.size.height);
    
    [UIView commitAnimations];
    
    
    // Scroll view
    CGRect viewFrame = originalFrame;
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
 */
@end
