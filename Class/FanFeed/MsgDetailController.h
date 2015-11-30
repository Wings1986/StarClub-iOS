//
//  MsgDetailController.h
//  StarClub

#import "BaseViewController.h"


@protocol MsgDetailControllerDelegate

- (void) msgDetailsDone;

@end

@interface MsgDetailController : BaseViewController

@property (nonatomic, strong) id<MsgDetailControllerDelegate> delegate;

-(id) initWithMessageDetail:(NSDictionary *) detail;


@end
