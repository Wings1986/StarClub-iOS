//
//  AddVideoController.h
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//

#import "BaseViewController.h"

@protocol AddVideoContollerDelegate

- (void) addVideoPostDone;

@end

@interface AddVideoController : BaseViewController

@property (nonatomic, strong) id<AddVideoContollerDelegate> delegate;

@end
