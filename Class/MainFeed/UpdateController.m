//
//  UpdateController.m
//  StarClub
//
//  Created by MAYA on 1/4/14.
//
//

#import "UpdateController.h"

#import "StarTracker.h"
@interface UpdateController ()
{
    IBOutlet UISwitch * swithBtn;
    IBOutlet UITextView * mTextView;
}

@end

@implementation UpdateController

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
    
    
    self.title = @"Updates";
    [StarTracker StarSendView:self.title];
    
    NSLog(@"%@", self.navigationController);

    
    NSString * content = @"Find out when Enrique posts to the app in real time.";
#ifdef ENRIQUE
    content = @"Find out when Enrique posts to the app in real time.";
#elif defined(TYRESE)
    content = @"Find out when Tyrese posts to the app in real time.";
#elif defined(SNOOPY)
    content = @"Find out when Snoop Dogg posts to the app in real time.";
#elif defined(PHOTOGENICE)
    content = @"Find out when Photogenics posts to the app in real time.";
#elif defined(NICOLE)
    content = @"Find out when Nicole posts to the app in real time.";
#else
    content = @"Find out when posts are made to the app in real time.";
#endif
    mTextView.text = content;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [NSThread detachNewThreadSelector: @selector(getPush) toTarget:self withObject:nil];
}
-(IBAction) onClickBack:(id)sender
{
    [self onBack];
}
-(IBAction) onChangeSwitch:(id)sender
{
    [NSThread detachNewThreadSelector: @selector(setPush) toTarget:self withObject:nil];
}

-(void) setPush
{
    
    NSString* tokenString = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    
    NSString * urlString = [MyUrl setPushNotification:tokenString :swithBtn.on];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"push success");
    }
    else {
        NSLog(@"push fail");
    }
}
-(void) getPush
{
    
    NSString * urlString = [MyUrl getPushNotification];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    NSDictionary *result = [JSonParser objectWithString:urlString];
    
    NSLog(@"result = %@", result);
    
    BOOL value = [[result objectForKey:@"status"] boolValue];
    if (value == true) {
        NSLog(@"get push success");
        BOOL enable = [[result objectForKey:@"enable"] boolValue];
        swithBtn.on = enable;
    }
    else {
        NSLog(@"push fail");
    }
}


@end
