//
//  AddCommentController.h
//  StarClub
//
//  Created by MAYA on 1/10/14.
//
//

#import "BaseViewController.h"

@protocol AddCommentControllerDelegate

- (void) addCommentDone;

@end

@interface AddCommentController : BaseViewController

@property (nonatomic, strong) id<AddCommentControllerDelegate> delegate;


-(id) initWithData:(NSDictionary*) dic;


@end
