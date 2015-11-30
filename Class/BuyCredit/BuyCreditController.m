//
//  BuyCreditController.m
//  StarClub
//

#import "BuyCreditController.h"
#import "IAPHelper.h"

#import "ASIFormDataRequest.h"
#import "NSDictionary+JRAdditions.h"

#import "StarTracker.h"

//#import "PayPalMobile.h"
//
//#warning "Enter your credentials"
//#define kPayPalClientId @"YOUR CLIENT ID HERE"
//#define kPayPalReceiverEmail @"YOUR_PAYPAL_EMAIL@yourdomain.com"


//@interface BuyCreditController ()<PayPalPaymentDelegate>
@interface BuyCreditController ()
{
    IBOutlet UIButton   * button1;
    IBOutlet UIButton   * button2;
    IBOutlet UIButton   * button3;
    IBOutlet UIButton   * button4;
    
    IBOutlet UILabel     * lbCreditLeft;
    
    NSTimer * timer;
    
    int m_nSelBtn;
} 

@property (strong, nonatomic) IAPHelper *iapHelper;
@property (strong, nonatomic) SKProduct *subscription1, *subscription2, *subscription3, *subscription4;


//@property(nonatomic, strong, readwrite) NSString *environment;
//@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
//@property(nonatomic, strong, readwrite) PayPalPayment *completedPayment;


@end

@implementation BuyCreditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Optimization: Prepare for display of the payment UI by getting network work done early
//    [PayPalPaymentViewController setEnvironment:self.environment];
//    [PayPalPaymentViewController prepareForPaymentUsingClientId:kPayPalClientId];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    


    self.title = @"StarCredits";
    
    [StarTracker StarSendView:self.title];
    
    UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    [btnCancel setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = btnItemLeft;
    
    
    UIButton * btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 32)];
    [btnEdit setImage:[UIImage imageNamed:@"btn_buy.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickBuy:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * btnItemEdit = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem = btnItemEdit;
    
    
    /////////////////////
//    self.acceptCreditCards = YES;
//    self.environment = PayPalEnvironmentNoNetwork;

    ////////////////////////////////
    
    m_nSelBtn = 0;
    [self changeButtonState];
    
    
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    lbCreditLeft.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"credit"]];
    
    NSMutableSet *purchaseIds = [NSMutableSet set];
    [purchaseIds addObject:purchaseID1];
//    [purchaseIds addObject:purchaseID2];
//    [purchaseIds addObject:purchaseID3];
//    [purchaseIds addObject:purchaseID4];
    
    if ([purchaseIds count] > 0) {
        self.iapHelper = [[IAPHelper alloc] initWithProductIdentifiers:purchaseIds];
        [self.iapHelper requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                [products enumerateObjectsUsingBlock:^(SKProduct *productItem, NSUInteger productIdx, BOOL *stop) {
                    if ([productItem.productIdentifier isEqualToString:purchaseID1]) {
                        self.subscription1 = productItem;
                    } else if ([productItem.productIdentifier isEqualToString:purchaseID2]) {
                        self.subscription2 = productItem;
                    } else if ([productItem.productIdentifier isEqualToString:purchaseID3]) {
                        self.subscription3 = productItem;
                    } else if ([productItem.productIdentifier isEqualToString:purchaseID4]) {
                        self.subscription4 = productItem;
                    } else {
                    }
                }];
            }
        }];
    }
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseSuccess:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFail:) name:IAPHelperProductFailedNotification object:nil];

}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPHelperProductFailedNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeButtonState {
    
    if (m_nSelBtn == 0) {
        [button1 setSelected:YES];
        [button2 setSelected:NO];
        [button3 setSelected:NO];
        [button4 setSelected:NO];
    }
    else if (m_nSelBtn == 1) {
        [button1 setSelected:NO];
        [button2 setSelected:YES];
        [button3 setSelected:NO];
        [button4 setSelected:NO];
    }
    else if (m_nSelBtn == 2) {
        [button1 setSelected:NO];
        [button2 setSelected:NO];
        [button3 setSelected:YES];
        [button4 setSelected:NO];
    }
    else if (m_nSelBtn == 3) {
        [button1 setSelected:NO];
        [button2 setSelected:NO];
        [button3 setSelected:NO];
        [button4 setSelected:YES];
    }

}
- (IBAction) onClickCancel:(id)sender {
    [StarTracker StarSendEvent:@"App Event" :@"Credits" : @"Cancelled"];
    [self onBack];
}
-(IBAction) onClickButton1:(id)sender {
    [StarTracker StarSendEvent:@"App Event" :@"Credits" : @"Buy Option 1"];
    m_nSelBtn = 0;
    [self changeButtonState];
}
-(IBAction) onClickButton2:(id)sender {
    [StarTracker StarSendEvent:@"App Event" :@"Credits" : @"Buy Option 2"];
    m_nSelBtn = 1;
    [self changeButtonState];
    
}
-(IBAction) onClickButton3:(id)sender {
    [StarTracker StarSendEvent:@"App Event" :@"Credits" : @"Buy Option 3"];
    m_nSelBtn = 2;
    [self changeButtonState];
    
}
-(IBAction) onClickButton4:(id)sender {
        [StarTracker StarSendEvent:@"App Event" :@"Credits" : @"Buy Option 4"];
    m_nSelBtn = 3;
    [self changeButtonState];
}

- (IBAction) onClickBuy:(id)sender {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
//                                                    message: @"Please choose credit option"
//                                                   delegate: self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"Credit Card", @"In-app Purchase", nil];
//    alert.tag = 105;
//    [alert show];
    
     [self onPayInApp];
    
}

/*
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 105) {
        if (buttonIndex == 1) { // credit
            [self onPayCredit];
        }
        else if (buttonIndex == 2) {
            [self onPayInApp];
        }
    }
}
*/

-(void) onPayInApp
{
    [StarTracker StarSendEvent:@"App Event" :@"Credits" : @"Pay via In-App"];
    if (m_nSelBtn == 0) {
        if (self.subscription1) {

            [super showLoading:@"Loading..."];

            [self.iapHelper buyProduct:self.subscription1];
        }
    } else if (m_nSelBtn == 1) {
        if (self.subscription2) {
            [self.iapHelper buyProduct:self.subscription2];
        }
    } else if (m_nSelBtn == 2) {
        if (self.subscription3) {
            [self.iapHelper buyProduct:self.subscription3];
        }
    } else if (m_nSelBtn == 3) {
        if (self.subscription4) {
            [self.iapHelper buyProduct:self.subscription4];
        }
    }
}

/*
- (void) onPayCredit
{
    // Remove our last completed payment, just for demo purposes.
    self.completedPayment = nil;
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.currencyCode = @"USD";
//    payment.amount = [[NSDecimalNumber alloc] initWithString:@"9.95"];
//    payment.shortDescription = @"Hipster t-shirt";

    if (m_nSelBtn == 0) {
        if (self.subscription1) {
            payment.amount = self.subscription1.price;
            payment.shortDescription = self.subscription1.localizedTitle;
        }
    } else if (m_nSelBtn == 1) {
        if (self.subscription2) {
            payment.amount = self.subscription2.price;
            payment.shortDescription = self.subscription2.localizedTitle;
        }
    } else if (m_nSelBtn == 2) {
        if (self.subscription3) {
            payment.amount = self.subscription3.price;
            payment.shortDescription = self.subscription3.localizedTitle;
        }
    } else if (m_nSelBtn == 3) {
        if (self.subscription4) {
            payment.amount = self.subscription4.price;
            payment.shortDescription = self.subscription4.localizedTitle;
        }
    }

    
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
        
        return;
    }
    
    // Any customer identifier that you have will work here. Do NOT use a device- or
    // hardware-based identifier.
    NSString *customerId = @"user-11723";
    
    // Set the environment:
    // - For live charges, use PayPalEnvironmentProduction (default).
    // - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
    // - For testing, use PayPalEnvironmentNoNetwork.
    [PayPalPaymentViewController setEnvironment:self.environment];
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:kPayPalClientId
                                                                                                 receiverEmail:kPayPalReceiverEmail
                                                                                                       payerId:customerId
                                                                                                       payment:payment
                                                                                                      delegate:self];
    paymentViewController.hideCreditCardButton = !self.acceptCreditCards;
    
    // Setting the languageOrLocale property is optional.
    //
    // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
    // its user interface according to the device's current language setting.
    //
    // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
    // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
    // to use that language/locale.
    //
    // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
    paymentViewController.languageOrLocale = @"en";
    
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark - Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    self.completedPayment = completedPayment;
    
    // here
    [self gotoSuccess];
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel {
    NSLog(@"PayPal Payment Canceled");
    self.completedPayment = nil;
    
    // here
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/
#pragma mark -
#pragma In App purchase

- (void)restoreProc
{
    [self.iapHelper restoreCompletedTransactions];
}

- (void)purchaseSuccess:(NSNotification *)notification
{
    
    [StarTracker StarSendEvent:@"App Event" :@"Credits" : notification.object];
    
    NSString *purchasedId = notification.object;
    
    if ([purchasedId isEqualToString:purchaseID1]) {
        
    } else if ([purchasedId isEqualToString:purchaseID2]) {
        
    } else if ([purchasedId isEqualToString:purchaseID3]) {
        
    } else if ([purchasedId isEqualToString:purchaseID4]) {
        
    }
    
    [self gotoSuccess];
    
    [super hideLoading];
    [super showWithCustomView:@"Purchase Success"];
}

- (void)purchaseFail:(NSNotification *)notification
{
//    NSString *purchasedId = notification.object;
    [super showFail:@"Purchase Fail"];

}

#pragma mark -

- (void) gotoSuccess
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDone) userInfo:nil repeats:NO];
}
- (void) timerDone {
    [timer invalidate];
    
    [self paymentDone];
    
}

-(void) paymentDone
{
    
    [super showLoading:@"Uploading..."];

    int nCredit = 100;
    if (m_nSelBtn == 0) {
        nCredit = 100;
    } else if (m_nSelBtn == 1) {
        nCredit = 1000;
    } else if (m_nSelBtn == 2) {
        nCredit = 2500;
    } else if (m_nSelBtn == 3) {
        nCredit = 5000;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:USER_INFO]];
    
    int oldCredit = [[userInfo objectForKey:@"credit"] intValue];
    
    nCredit += oldCredit;
    
    // upload
    NSString *url = [MyUrl getUpdateUser];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:[NSString stringWithFormat:@"%d",CID] forKey:@"cid"];
    [request setPostValue:TOKEN forKey:@"token"];
    NSLog(@"token = %@", TOKEN);
    [request setPostValue:USERID forKey:@"user_id"];
    NSLog(@"userId = %@", USERID);
    [request setPostValue:[NSString stringWithFormat:@"%d", nCredit] forKey:@"credit"];
        NSLog(@"credit = %d", nCredit);
    [request setPostValue:DEVICETOKEN forKey:@"ud_token"];
    NSLog(@"ud_token = %@", DEVICETOKEN);
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];

}

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
    
    [StarTracker StarSendEvent:@"App Event" :@"Credits" :@"Update User DB with Amount"];
    [self hideLoading];

    NSString *responseString = [request responseString];
    NSLog(@"result = %@", responseString);
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:responseString];
    
    NSLog(@"result = %@", result);
    
    BOOL status = [[result objectForKey:@"status"] boolValue];
    if (status == true) {
        int nCredit = 100;
        if (m_nSelBtn == 0) {
            nCredit = 100;
        } else if (m_nSelBtn == 1) {
            nCredit = 1000;
        } else if (m_nSelBtn == 2) {
            nCredit = 2500;
        } else if (m_nSelBtn == 3) {
            nCredit = 5000;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:USER_INFO]];
        
        int oldCredit = [[userInfo objectForKey:@"credit"] intValue];
        
        nCredit += oldCredit;
        
        [userInfo setObject:[NSNumber numberWithInt:nCredit] forKey:@"credit"];
        [defaults setValue:[userInfo dictionaryByReplacingNullsWithStrings] forKey:USER_INFO];
        [defaults synchronize];

        
        [self.delegate paymentDone];
        [self onBack];
    }
    
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    [StarTracker StarSendEvent:@"App Event" :@"Credits" :@"Update DB Error"];
    
    [self showFail:@"Network Communication Error Uploading Credits"];
}

@end
