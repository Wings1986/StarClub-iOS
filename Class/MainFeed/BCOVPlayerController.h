//
//  BCOVPlayerController.h
//

#import <UIKit/UIKit.h>

// import the SDK master header
#import <BCOVPlayerSDK.h>
#import <ReactiveCocoa/RACEXTScope.h>


@protocol BCOVPlaybackController;

@class BCOVCatalogService;
@class BCOVMediaRequestFactory;


@interface BCOVPlayerController : BaseViewController<BCOVPlaybackControllerDelegate>
{

}

@property (strong, nonatomic) id<BCOVPlaybackController> controller;

@property (strong, nonatomic) BCOVCatalogService *catalog;
@property (strong, nonatomic) BCOVMediaRequestFactory *mediaRequestFactory;


- (id) initWithVideoURL:(NSString *) url videoId:(NSString*) videoId;

@end
