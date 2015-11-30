//
//  FeedTextCell.h
//
//  Created by MAYA on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTextCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *viewUser;
@property (strong, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lbUserName;
@property (strong, nonatomic) IBOutlet UILabel *lbTimeStamp;
@property (strong, nonatomic) IBOutlet UILabel *lbLikeNum;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;

@property (strong, nonatomic) IBOutlet UILabel * lbText;
@property (strong, nonatomic) IBOutlet UIView *viewLock;
@property (strong, nonatomic) IBOutlet UILabel *lbLockNum;

@property (strong, nonatomic) IBOutlet UIView * viewMsg;
@property (strong, nonatomic) IBOutlet UIImageView *ivMessage1;
@property (strong, nonatomic) IBOutlet UILabel *lbMessage1;
@property (strong, nonatomic) IBOutlet UILabel *lbMsgTimeStamp1;

@property (strong, nonatomic) IBOutlet UIImageView *ivMessage2;
@property (strong, nonatomic) IBOutlet UILabel *lbMessage2;
@property (strong, nonatomic) IBOutlet UILabel *lbMsgTimeStamp2;

@property (strong, nonatomic) IBOutlet UIImageView *ivMessage3;
@property (strong, nonatomic) IBOutlet UILabel *lbMessage3;
@property (strong, nonatomic) IBOutlet UILabel *lbMsgTimeStamp3;


@property (strong, nonatomic) IBOutlet UILabel *lbComment;
@property (strong, nonatomic) IBOutlet UIButton *btnComment;
@property (strong, nonatomic) IBOutlet UIButton *btnAddComment;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;

@property (strong, nonatomic) IBOutlet UIImageView *ivShareIcon;
@property (strong, nonatomic) IBOutlet UILabel *lbApprove;

@end
