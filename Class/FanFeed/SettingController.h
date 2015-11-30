//
//  SettingController.h
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import <UIKit/UIKit.h>
#import "AvatarController.h"


@interface SettingController : RootViewController<AvatarControllerDelegate>
{
    IBOutlet UIView       * viewMain;
    IBOutlet UIScrollView * viewScroll;
    IBOutlet UIImageView  * ivAvatar;
    IBOutlet UITextField * tfFullName;
    IBOutlet UITextField * tfBirthday;
    IBOutlet UITextField * tfCity;
    IBOutlet UITextField * tfState;
    IBOutlet UITextField * tfCountry;
    IBOutlet UITextField * tfPassword;
    IBOutlet UITextField * tfEmail;
    
    IBOutlet UIView* viewSubDate;
    IBOutlet UIDatePicker * pvDate;
    
    IBOutlet UIButton   *btnMale;
    IBOutlet UIButton   *btnFemale;
    GENDER  curGender;
    
    IBOutlet UILabel * lbCreditNum;
    IBOutlet UIButton * btnBuyMore;
    
    IBOutlet UISwitch * swFacebook;
    IBOutlet UISwitch * swTwitter;
    
    IBOutlet UILabel * lbVersion;
    
    
    BOOL date_visible;
    BOOL country_visible;
    
    BOOL keyboardVisible;
    CGPoint offset;
    CGRect originalFrame;
    
    
    // country list
    IBOutlet UIView* viewSubCounty;
    IBOutlet UIPickerView * pvCountry;
    NSMutableArray * countriesArray;

}
@end
