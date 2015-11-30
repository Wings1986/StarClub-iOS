//
//  SignInController.h
//  GHSidebarNav
//
//  Created by MAYA on 12/31/13.
//
//

#import <UIKit/UIKit.h>

@interface SignInController : BaseViewController<UITextFieldDelegate>
{
    IBOutlet UITextField * txtEmail;
    IBOutlet UITextField * txtPassword;
}

@end
