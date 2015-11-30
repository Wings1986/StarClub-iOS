//
//  AddPhotoController.h
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//


@protocol AddPhotoContollerDelegate

- (void) addPhotoPostDone;

@end

@interface AddPhotoController : BaseViewController

@property (nonatomic, strong) id<AddPhotoContollerDelegate> delegate;

@end
