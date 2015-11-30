//
//  SignupController.h
//  StarClub
//
//  Created by MAYA on 12/31/13.
//
//

#import "BaseViewController.h"



@interface SignupController : BaseViewController
{
    IBOutlet UIView       * viewMain;
    IBOutlet UIScrollView * viewScroll;
    IBOutlet UIImageView  * ivAvatar;
    IBOutlet UITextField * tfFullName;
    IBOutlet UITextField * tfLastName;
    IBOutlet UITextField * tfPassword;
    IBOutlet UITextField * tfEmail;
    
//    IBOutlet UIView* viewSubDate;
//    IBOutlet UIDatePicker * pvDate;
    
//    IBOutlet UIButton   *btnMale;
//    IBOutlet UIButton   *btnFemale;
//    GENDER  curGender;
    
//    BOOL date_visible;
//    BOOL country_visible;
    
    BOOL keyboardVisible;
    CGPoint offset;
    CGRect originalFrame;
    
    
    // country list
//    IBOutlet UIView* viewSubCounty;
//    IBOutlet UIPickerView * pvCountry;
//    NSMutableArray * countriesArray;

}

@property(nonatomic, strong) UIImage * m_imgAvatar;

- (id)initWithImageName:(UIImage *)_image;


@end
