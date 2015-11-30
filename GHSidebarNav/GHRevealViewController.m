//
//  GHSidebarViewController.m


#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MyPlayerView.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#import "GHAppDelegate.h"


#pragma mark -
#pragma mark Constants
const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration = 0.25;
const CGFloat kGHRevealSidebarWidth = 260.0f;
const CGFloat kGHRevealSidebarFlickVelocity = 1000.0f;


#pragma mark -
#pragma mark Private Interface
@interface GHRevealViewController ()
@property (nonatomic, readwrite, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readwrite, getter = isSearching) BOOL searching;
- (void)hideSidebar;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHRevealViewController {
@private
	UIView *_sidebarView;
	UIView *_contentView;
	UITapGestureRecognizer *_tapRecog;
    
   	UIPanGestureRecognizer *_panRecog;
}

- (void)setSidebarViewController:(UIViewController *)svc {
	if (_sidebarViewController == nil) {
		svc.view.frame = _sidebarView.bounds;
        svc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_sidebarViewController = svc;
		[self addChildViewController:_sidebarViewController];
		[_sidebarView addSubview:_sidebarViewController.view];
		[_sidebarViewController didMoveToParentViewController:self];
	} else if (_sidebarViewController != svc) {
		svc.view.frame = _sidebarView.bounds;
        svc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[_sidebarViewController willMoveToParentViewController:nil];
		[self addChildViewController:svc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_sidebarViewController
						  toViewController:svc 
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{} 
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_sidebarViewController removeFromParentViewController];
									[svc didMoveToParentViewController:self];
									_sidebarViewController = svc;
								}
		 ];
	}
}

- (void)setContentViewController:(UIViewController *)cvc {
	if (_contentViewController == nil) {
		cvc.view.frame = _contentView.bounds;
		_contentViewController = cvc;
		[self addChildViewController:_contentViewController];
		[_contentView addSubview:_contentViewController.view];
		[_contentViewController didMoveToParentViewController:self];
	} else if (_contentViewController != cvc) {
		cvc.view.frame = _contentView.bounds;
		[_contentViewController willMoveToParentViewController:nil];
		[self addChildViewController:cvc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_contentViewController
						  toViewController:cvc 
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_contentViewController removeFromParentViewController];
									[cvc didMoveToParentViewController:self];
									_contentViewController = cvc;
								}
		];
	}
    
    [_contentView addGestureRecognizer:_panRecog];
}

#pragma mark Memory Management
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.sidebarShowing = NO;
		self.searching = NO;
		_tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSidebar)];
		_tapRecog.cancelsTouchesInView = YES;

        _panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
        
		self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
        CGRect rtBound = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                    self.view.bounds.size.width, self.view.bounds.size.height - TOOLBAR_HEIGHT);
//        CGRect rtBound = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
//                                    self.view.bounds.size.width, self.view.bounds.size.height);
        
		_sidebarView = [[UIView alloc] initWithFrame:rtBound];
		_sidebarView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_sidebarView.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_sidebarView];
		
		_contentView = [[UIView alloc] initWithFrame:rtBound];
		_contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_contentView.backgroundColor = [UIColor clearColor];
		_contentView.layer.masksToBounds = NO;
		_contentView.layer.shadowColor = [UIColor blackColor].CGColor;
		_contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		_contentView.layer.shadowOpacity = 1.0f;
		_contentView.layer.shadowRadius = 2.5f;
		_contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_contentView.bounds].CGPath;
		[self.view addSubview:_contentView];
    }
    return self;
}

-(void) increaseContentSize
{
    CGRect rtBound = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                self.view.bounds.size.width, self.view.bounds.size.height);
    _contentView.frame = rtBound;
}
-(void) decreaseContentSize
{
    CGRect rtBound = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                self.view.bounds.size.width, self.view.bounds.size.height - TOOLBAR_HEIGHT);
    _contentView.frame = rtBound;
}



#pragma mark UIViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

-(BOOL)shouldAutorotate
{
    if (_contentViewController != nil) {
        return [_contentViewController shouldAutorotate];
    } else {
        BOOL bFlag = [super shouldAutorotate];
        return bFlag;
    }
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (_contentViewController == nil) {
        NSInteger nValue =  [super supportedInterfaceOrientations];
        return nValue;
    }
    else {
        
//        NSLog(@"%@", NSStringFromClass([_contentViewController class]));

        return [_contentViewController supportedInterfaceOrientations];
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (_contentViewController == nil) {
        NSInteger nValue =  [super preferredInterfaceOrientationForPresentation];
        return nValue;
    }
    else {
        
//        NSLog(@"%@", NSStringFromClass([_contentViewController class]));
        
        return [_contentViewController preferredInterfaceOrientationForPresentation];
    }
}


#pragma mark Public Methods
- (void)dragContentView:(UIPanGestureRecognizer *)panGesture {
	CGFloat translation = [panGesture translationInView:self.view].x;
	if (panGesture.state == UIGestureRecognizerStateChanged) {
		if (_sidebarShowing) {
			if (translation > 0.0f) {
				_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
				self.sidebarShowing = YES;
			} else if (translation < -kGHRevealSidebarWidth) {
				_contentView.frame = _contentView.bounds;
				self.sidebarShowing = NO;
			} else {
				_contentView.frame = CGRectOffset(_contentView.bounds, (kGHRevealSidebarWidth + translation), 0.0f);
			}
		} else {
			if (translation < 0.0f) {
				_contentView.frame = _contentView.bounds;
				self.sidebarShowing = NO;
			} else if (translation > kGHRevealSidebarWidth) {
				_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
				self.sidebarShowing = YES;
			} else {
				_contentView.frame = CGRectOffset(_contentView.bounds, translation, 0.0f);
			}
		}
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
		CGFloat velocity = [panGesture velocityInView:self.view].x;
		BOOL show = (fabs(velocity) > kGHRevealSidebarFlickVelocity)
			? (velocity > 0)
			: (translation > (kGHRevealSidebarWidth / 2));
		[self toggleSidebar:show duration:kGHRevealSidebarDefaultAnimationDuration];
		
	}
}



- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    // A single tap hides the slide menu
    [self toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];

}

/* The following is from
 http://blog.shoguniphicus.com/2011/06/15/working-with-uigesturerecognizers-uipangesturerecognizer-uipinchgesturerecognizer/
 as mentioned by Nick Harris, in his approach to slide-out navigation:
 http://nickharris.wordpress.com/2012/02/05/ios-slide-out-navigation-code/
 */
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
{
    
    GHAppDelegate * appDelegate = APPDELEGATE;
    if (appDelegate.BCOVVideoIsPlaying)
        return;
    
	// The pan gesture moves horizontally the view
    UIView *piece = _contentView;
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y)];
		if (piece.frame.origin.x < 0) {
			[piece setFrame:CGRectMake(0, piece.frame.origin.y, piece.frame.size.width, piece.frame.size.height)];
		}
		if (piece.frame.origin.x > 320) {
			[piece setFrame:CGRectMake(320, piece.frame.origin.y, piece.frame.size.width, piece.frame.size.height)];
		}
        [gesture setTranslation:CGPointZero inView:[piece superview]];
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded) {
		// Hide the slide menu only if the view is released under a certain threshold, the threshold is lower when the menu is hidden
		float threshold;
		if (self.sidebarShowing == YES) {
			threshold = 270;
		} else {
			threshold = 270/2;
		}
        
		if (_contentView.frame.origin.x < threshold) {
			[self toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
		} else {
			[self toggleSidebar:YES duration:kGHRevealSidebarDefaultAnimationDuration];
		}
	}
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = _contentView;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}


- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"App Status"
                                                           action:@"Toggle Sidebar"
                                                            label:nil
                                                            value:nil] set:@"State Change" forKey:kGAISessionControl] build]];
    
	[self toggleSidebar:show duration:duration completion:^(BOOL finshed){}];
}

- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration completion:(void (^)(BOOL finsihed))completion {
    __weak GHRevealViewController *selfRef = self;
	void (^animations)(void) = ^{
		if (show) {
			_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
			[_contentView addGestureRecognizer:_tapRecog];
//            [_contentView addGestureRecognizer:_panRecog];
            [selfRef.contentViewController.view setUserInteractionEnabled:NO];
		} else {
			if (self.isSearching) {
				_sidebarView.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
			} else {
				[_contentView removeGestureRecognizer:_tapRecog];
//                [_contentView removeGestureRecognizer:_panRecog];
			}
			_contentView.frame = _contentView.bounds;
            [selfRef.contentViewController.view setUserInteractionEnabled:YES];
		}
		selfRef.sidebarShowing = show;
	};
	if (duration > 0.0) {
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:animations
						 completion:completion];
	} else {
		animations();
		completion(YES);
	}
}

- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)srchView duration:(NSTimeInterval)duration {

    
    [self toggleSearch:showSearch withSearchView:srchView duration:duration completion:^(BOOL finished){}];
}

- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)srchView duration:(NSTimeInterval)duration completion:(void (^)(BOOL finsihed))completion {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"App Status"
                                                           action:@"Toggle Search"
                                                            label:nil
                                                            value:nil] set:@"State Change" forKey:kGAISessionControl] build]];
    
	if (showSearch) {
		srchView.frame = self.view.bounds;
	} else {
		_sidebarView.alpha = 0.0f;
        
//		_contentView.frame = CGRectOffset(self.view.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
//		[self.view addSubview:_contentView];
	}
	void (^animations)(void) = ^{
		if (showSearch) {
//			_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
			[_contentView removeGestureRecognizer:_tapRecog];
			[_sidebarView removeFromSuperview];
			self.searchView = srchView;
//			[self.view insertSubview:self.searchView atIndex:0];
            [self.view addSubview:self.searchView];
            [self.view bringSubviewToFront:self.searchView];
		} else {
//			_sidebarView.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
			_sidebarView.alpha = 1.0f;
			[self.view insertSubview:_sidebarView atIndex:0];
			self.searchView.frame = _sidebarView.frame;
//			_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
		}
	};
	void (^fullCompletion)(BOOL) = ^(BOOL finished){
		if (showSearch) {
//			_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetHeight([UIScreen mainScreen].bounds), 0.0f);
//			[_contentView removeFromSuperview];
		} else {
			[_contentView addGestureRecognizer:_tapRecog];
//			[_contentView addGestureRecognizer:_panRecog];
			[self.searchView removeFromSuperview];
			self.searchView = nil;
		}
		self.sidebarShowing = YES;
		self.searching = showSearch;
		completion(finished);
	};
	if (duration > 0.0) {
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:animations
						 completion:fullCompletion];
	} else {
		animations();
		fullCompletion(YES);
	}
}

#pragma mark Private Methods
- (void)hideSidebar {
	[self toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
}

@end
