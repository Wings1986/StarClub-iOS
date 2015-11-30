//
//  JSMessageCell.m
//  DynamicCellHeights
//
//  Copyright (c) 2013 John Szumski. All rights reserved.
//

#import "JSMessageCell.h"
#import "JSMessage.h"
#import "NSDate+TimeAgo.h"
#import "JSLabel.h"

#import "UIImage+JSMessagesView.h"
#import "DLImageLoader.h"




const CGFloat JSMessageCellMessageFontSize = 15.0f;
const CGFloat JSMessageCellUsernameFontSize = 15.0f;
const CGFloat JSMessageCellTimestampFontSize = 12.0f;
const CGFloat JSMessageCellPadding = 10.0f;
const CGFloat JSMessageCellAvatarWidth = 60.0f;
const CGFloat JSMessageCellAvatarHeight = 60.0f;
const CGFloat JSMessageCellMediaIconWidth = 30.0f;
const CGFloat JSMessageCellMediaIconHeight = 24.0f;


@implementation JSMessageCell

#pragma mark - Class methods

+ (CGFloat)minimumHeightShowingMediaIcon:(BOOL)showingMedia {
	if (showingMedia) {
		return JSMessageCellPadding +
			   JSMessageCellMediaIconHeight +
			   JSMessageCellPadding +
                [@"JS" sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:FONT_NAME size:JSMessageCellTimestampFontSize]}].height +
			   JSMessageCellPadding;
	}
	
	return JSMessageCellAvatarHeight + JSMessageCellPadding*2;
}


#pragma mark - View lifecycle

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	
	self.accessoryType = UITableViewCellAccessoryNone;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	self.avatarView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"demo-avatar"] circleImageWithSize:kJSAvatarSize]];
//    self.avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demo-avatar"]];
	[self.contentView addSubview:self.avatarView];
	
	self.usernameLabel = [[JSLabel alloc] init];
	self.usernameLabel.font = [UIFont fontWithName:FONT_NAME_BOLD size:JSMessageCellUsernameFontSize];
	self.usernameLabel.textColor = [UIColor blackColor];
	self.usernameLabel.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.usernameLabel];
	
	self.messageTextLabel = [[JSLabel alloc] init];
	self.messageTextLabel.font = [UIFont fontWithName:FONT_NAME size:JSMessageCellMessageFontSize];
	self.messageTextLabel.textColor = [UIColor darkGrayColor];
	self.messageTextLabel.numberOfLines = 0;
	self.messageTextLabel.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.messageTextLabel];
	
	self.timestampLabel = [[UILabel alloc] init];
	self.timestampLabel.font = [UIFont fontWithName:FONT_NAME size:JSMessageCellTimestampFontSize];
	self.timestampLabel.textColor = [UIColor lightGrayColor];
	self.timestampLabel.textAlignment = NSTextAlignmentRight;
	self.timestampLabel.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.timestampLabel];
	
	self.mediaIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media-icon"]];
	[self.contentView addSubview:self.mediaIconView];

	return self;
}

- (void)setMessage:(JSMessage *)message {
	_message = message;
	
	self.usernameLabel.text = message.username;
	self.messageTextLabel.text = message.messageText;
	self.timestampLabel.text = [message.dateSent timeAgo];
    
    NSString * imageUrl = message.imageUrl;
    [DLImageLoader loadImageFromURL:imageUrl
                          completed:^(NSError *error, NSData *imgData) {
                              if (error == nil) {
                                  // if we have no errors
                                  UIImage * image = [[UIImage imageWithData:imgData] circleImageWithSize:kJSAvatarSize];
//                                  UIImage * image = [UIImage imageWithData:imgData];
                                  [self.avatarView setImage:image];
                              }
                          }];

}

@end
