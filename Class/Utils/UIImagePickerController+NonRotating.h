
#import <Foundation/Foundation.h>

@interface UIImagePickerController (NonRotating)

- (BOOL)shouldAutorotate;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
