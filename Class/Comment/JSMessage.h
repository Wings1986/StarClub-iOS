//
//  JSMessage.h
//  DynamicCellHeights
//
//  Copyright (c) 2013 John Szumski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSMessage : NSObject

@property(nonatomic, strong)	NSNumber	*uniqueIdentifier;
@property(nonatomic, copy)		NSString	*username;
@property(nonatomic, copy)		NSString	*messageText;
@property(nonatomic, strong)	NSDate		*dateSent;
@property(nonatomic, copy)      NSString    *imageUrl;
@property(nonatomic, assign)	BOOL		hasMedia;

@property(nonatomic, copy)  NSString * content_id;
@property(nonatomic, copy)  NSString * post_type;
@property(nonatomic, copy)  NSString * userId;
@property(nonatomic, copy)  NSString * commentId;


@end
