//
//  AddTextController.h
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//

@protocol AddTextContollerDelegate

- (void) addTextPostDone;

@end

@interface AddTextController : BaseViewController

@property (nonatomic, strong) id<AddTextContollerDelegate> delegate;

@end
