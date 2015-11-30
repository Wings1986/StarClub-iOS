//
//  GHSidebarMenuCell.m

#import "GHMenuCell.h"
#import "Constants.h"


#pragma mark -
#pragma mark Constants
NSString const *kSidebarCellTextKey = @"CellText";
NSString const *kSidebarCellImageKey = @"CellImage";

#pragma mark -
#pragma mark Implementation
@implementation GHMenuCell

#pragma mark Memory Management
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.clipsToBounds = YES;
        self.backgroundColor = SIDE_MENU_COLOR_BACKGROUND;

		UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = SIDE_MENU_COLOR_BACKGROUND_VIEW;
		self.selectedBackgroundView = bgView;
		
		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageView setClipsToBounds:YES];
		
		self.textLabel.font = [UIFont fontWithName:FONT_NAME size:([UIFont systemFontSize] * 1.3f)];
//		self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
//		self.textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		self.textLabel.textColor =  SIDE_MENU_COLOR_TEXT;
        
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = SIDE_MENU_COLOR_TOPLINE; 
		[self.textLabel.superview addSubview:topLine];
		
//		UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
//		topLine2.backgroundColor = [UIColor colorWithRed:(54.0f/255.0f) green:(61.0f/255.0f) blue:(77.0f/255.0f) alpha:1.0f];
//		[self.textLabel.superview addSubview:topLine2];
		
//		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
//		bottomLine.backgroundColor = [UIColor colorWithRed:(204.0f/255.0f) green:(204.0f/255.0f) blue:(204.0f/255.0f) alpha:1.0f];
//		[self.textLabel.superview addSubview:bottomLine];
	}
	return self;
}

#pragma mark UIView
- (void)layoutSubviews {
	[super layoutSubviews];
	self.textLabel.frame = CGRectMake(55.0f, 0.0f, 250.0f, 43.0f);
	self.imageView.frame = CGRectMake(6.0f, 3.0f, 37.0f, 37.0f);
}

@end
