//
//  AvatarController.h
//  StarClub
//
//  Created by MAYA on 12/31/13.
//
//

#import "BaseViewController.h"

@protocol AvatarControllerDelegate

-(void) setAvatarImage:(UIImage*) _image;

@end


@interface AvatarController : BaseViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIImageView * ivChoose;
    
    
}
@property (nonatomic, assign) BOOL   m_bGotoNext;
@property (nonatomic, strong) id<AvatarControllerDelegate> delegate;

-(id) initWithGotoReturn;

@end
