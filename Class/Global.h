//
//  Global.h
//  LocationWeather
//
//  Created by Yuan Luo on 4/24/13.
//  Copyright (c) 2013 Sun Zhe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPDELEGATE     [UIApplication sharedApplication].delegate


#define GLOBAL  [Global Instance]

#define kBgQueue dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define USER_INFO       @"USERINFO"
#define USER_TOKEN      @"USER_TOKEN"


#define FULL_WIDTH      320

#define HEIGHT_HEADER   49
#define HEIGHT_TITLE    34
#define HEIGHT_IMAGE    239
#define HEIGHT_MSG_ONE  19
#define HEIGHT_MSG_OFFSET  5
#define HEIGHT_SHARE    38
#define HEIGHT_SPACE    20
#define HEIGHT_BANNER   50

#define TITLE_WIDTH     308
#define TITLE_POS_X     7
#define TITLE_MARGIN    7




#define CONTENTID               @"content_id"
#define POSTTYPE                @"post_type"
#define ID_PHOTO_URL            @"PHOTO_URL"
#define ID_PHOTO_CAPTION        @"PHOTO_CAPTION"


#define NOTI_SHOW_MAINFEED      @"NOTI_SHOW_MAINFEED"


#define AVATAR_IMAGE_SIZE       100
#define POST_IMAGE_SIZE         700


typedef enum _UserType {
	FAN = -1,
    ADMIN_CMS = 0,
    ADMIN_POST = 1,
    ADMIN_DELETE = 2,
} UserType;

typedef enum _FEED_TYPE {
    TYPE_ALL = 0,
    TYPE_TEXT,
    TYPE_PHOTO,
    TYPE_VIDEO,
    TYPE_QUIZ,
    TYPE_BANNER,
    TYPE_BAR,
}FEED_TYPE;

typedef enum _GENDER{
    NONE = -1,
    MALE = 0,
    FOMALE,
}GENDER;

@interface Global : NSObject


@property (nonatomic, strong) NSMutableArray * g_arrShopItem;


+(Global*) Instance;
-(void) initVal;

+(int) getUserType;

@end
