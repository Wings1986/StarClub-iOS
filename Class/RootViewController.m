//
//  RootViewController.m
//  StarClub
//
//  Created by MAYA on 11/20/11.
//

#import "RootViewController.h"


#pragma mark Private Interface

@interface RootViewController ()
- (void)revealSidebar;
@end

#pragma mark Implementation
@implementation RootViewController{
@private

}

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    
    NSString * nibName = nil;
    if ([title isEqual:@"Settings"]) {
        if ([Global getUserType] != FAN) {
            nibName = @"SettingController_admin";
        } else {
            nibName = @"SettingController";
        }
    }
    
   if (self = [super initWithNibName:nibName bundle:nil]) {

		self.title = title;
        
		_revealBlock = [revealBlock copy];
        
        UIButton * btnMenu = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59, 40)];
        [btnMenu setImage:[UIImage imageNamed:@"btn_slider_menu"] forState:UIControlStateNormal];
        [btnMenu addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * btnItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
        self.navigationItem.leftBarButtonItem = btnItem;
        
	}
    
	return self;
}

#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    bLoaded = NO;
}


- (void)revealSidebar {
	_revealBlock();
}



@end
