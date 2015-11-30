//
//  BuyCreditController.h
//  StarClub

#import "BaseViewController.h"

@protocol BuyCreditControllerDelegate

- (void) paymentDone;

@end

@interface BuyCreditController : BaseViewController


@property (nonatomic, strong) id<BuyCreditControllerDelegate> delegate;


@end
