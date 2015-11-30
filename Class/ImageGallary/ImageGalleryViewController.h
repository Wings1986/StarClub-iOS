//
//  ImageGalleryViewController.h
//
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageGalleryViewController : BaseViewController<UIActionSheetDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{

    IBOutlet UIActivityIndicatorView * mLoadingView;
    IBOutlet UIScrollView * mScrollView;
    IBOutlet UIImageView * mImageView;

    IBOutlet UIView * topBar;

    IBOutlet UIView * bottomBar;
    IBOutlet UILabel * lbDescription;
    IBOutlet UILabel * lbComment;
    
    IBOutlet UILabel * lbLike;
    IBOutlet UIButton * btnLike;
}



//- (id) initWithImageURL:(NSString *) url;
- (id) initWithDic:(NSDictionary *) dic;

@end
