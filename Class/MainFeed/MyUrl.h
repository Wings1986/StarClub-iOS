//
//  MyUrl.h
//  StarClub
//
//  Created by MAYA on 1/7/14.
//
//

#import <Foundation/Foundation.h>



#ifdef ENRIQUE
#define CID 7

#define SERVER              @"http://cms.enrique.starsite.com"
#define SERVER_URL          @"http://cms.enrique.starsite.com/index.php/api?"

#elif defined(FOOTBALL)

#define SERVER              @"http://cms.football.starsite.com"
#define SERVER_URL          @"http://cms.football.starsite.com/index.php/api?"
#define CID 19

#elif defined(SUAVESAYS)

#define CID 21

#define SERVER              @"http://cms.suavesays.starsite.com"
#define SERVER_URL          @"http://cms.suavesays.starsite.com/index.php/api?"


#elif defined(GEEK)

#define SERVER              @"http://cms.geek.starsite.com"
#define SERVER_URL          @"http://cms.geek.starsite.com/index.php/api?"
#define CID 1

#elif defined(MARVEL)

#define SERVER              @"http://cms.marvel.starsite.com"
#define SERVER_URL          @"http://cms.marvel.starsite.com/index.php/api?"
#define CID 18



#elif defined(ENRIQUEDEV)

#define SERVER              @"http://dev.cms.enrique.starsite.com"
#define SERVER_URL          @"http://dev.cms.enrique.starsite.com/index.php/api?"
#define CID 16
//#define CID 7


#elif defined(SCOTT)
#define CID 1

#define SERVER              @"http://cms.lorddisick.starsite.com"
#define SERVER_URL          @"http://cms.lorddisick.starsite.com/index.php/api?"

#elif defined(STARDEMO)
#define CID 17

#define SERVER                @"http://cms.stardemo.starsite.com"
#define SERVER_URL            @"http://cms.stardemo.starsite.com/index.php/api?"

#elif defined(NICOLE)
    #define CID 3

    #define SERVER                @"http://cms.nicole.starsite.com"
    #define SERVER_URL            @"http://cms.nicole.starsite.com/index.php/api?"

#elif defined(TYRESE)
    #define CID 1

    #define SERVER              @"http://cms.tyrese.starsite.com"
    #define SERVER_URL          @"http://cms.tyrese.starsite.com/index.php/api?"

#elif defined(SNOOPY)
    #define CID 7

    #define SERVER              @"http://sccmsstaging.starsite.com"
    #define SERVER_URL          @"http://sccmsstaging.starsite.com/index.php/api?"

#elif defined(PHOTOGENICS)
    #define CID 17
    #define SERVER              @"http://sccmsstaging.starsite.com"
    #define SERVER_URL          @"http://sccmsstaging.starsite.com/index.php/api?"

#else
    #define CID 0

#endif




#define TOKEN   [[NSUserDefaults standardUserDefaults] objectForKey:USER_TOKEN]
#define USERID  [[[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO] objectForKey:@"id"]

#define DEVICETOKEN [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]

@interface MyUrl : NSObject


+ (NSString *)getLoginUrl:(NSString *)email password:(NSString *)password;
+ (NSString *)getSignUpUrl;
+ (NSString *)getUpdateUser;

+ (NSString *)getMainFeedUrl:(NSString *)postType;
+ (NSString *)getMainFeedUrl:(NSString *)postType page:(int) page;
+ (NSString *)getCommunityFeedUrl:(NSString *)postType;
+ (NSString *)getCommunityFeedUrl:(NSString *)postType page:(int) page;
+ (NSString *)getCommunityFeedFollowedUrl:(NSString *)postType;
+ (NSString *)getCommunityFeedFollowedUrl:(NSString *)postType page:(int) page;


+ (NSString *)getTourDate;
+ (NSString *)getRanking;
+ (NSString *)getRanking:(int) page;
+ (NSString *)getUserSearch:(NSString*) search;
+ (NSString *)getLikeUser:(NSString*) postType : (NSString*) contentId page:(int) page;

+ (NSString *)getPhotoGallery;
+ (NSString *)getPhotoGallery:(int) page;
+ (NSString *)getVideoGallery;
+ (NSString *)getVideoGallery:(int) page;


+ (NSString *)getShop;
+ (NSString *)getMusics;

+ (NSString *)getUserProfile:(int) page;
+ (NSString *)getUserInfo:(NSString *) userID page:(int) page;

+ (NSString *)getFollowUsersByMe:(int) page;
+ (NSString *)getFollowUsersFollowedMe:(int) page;

+ (NSString *)getDeleteFeed:(NSString*) postType : (NSString*) contentId;


+ (NSString *)getComment:(NSString *)postType contentId:(NSString*) contentId page:(int) page;
+ (NSString *)addComment:(NSString *)postType contentId:(NSString*) contentId comment:(NSString*) comment count:(int) commentCount;
+ (NSString *)deleteComment:(NSString *)postType contentId:(NSString*) contentId commentId:(NSString*) commentId count:(int) commentCount;

+ (NSString *)addLike:(NSString *)postType contentId:(NSString*) contentId like:(int) like;

+ (NSString *)getLock:(NSString *)postType contentId:(NSString*) contentId;

+ (NSString *)getPushNotification;
+ (NSString *)setPushNotification:(NSString *)deviceToken : (int) enable;

+ (NSString *)getQuizAnswer:(NSString *) quizId  questionCount:(int) questionCount answerCount:(int) answerCount;
+ (NSString *)getPollAnswer:(NSString *) answerId questionId:(NSString *) questionId;

+ (NSString *)sendMessage:(NSString *) receiverId  text:(NSString *) text;
+ (NSString *)getMessage:(int) page;
+ (NSString *)readMessage:(NSString *) mailId;

+ (NSString *)getAddText:(NSString *) text;
+ (NSString *)getAddImageUrl;
+ (NSString *)getAddVideoUrl;

+ (NSString *)setFollowing:(NSString *)followingID;
+ (NSString *)setUnFollowing:(NSString *)followingID;

+ (NSString *)setBlockFan:(NSString *)fanId;
+ (NSString *)setUnblockFan:(NSString *)fanId;

+ (NSString *)getExtraInfo:(NSString *) postType : (NSString *) contentId;
+ (NSString *)getQuizData:(NSString *) postType : (NSString *) contentId;

+ (NSString *)getHelp;
+ (NSString *)getAdminList;
+ (NSString *)getForgetPasswordUrl:(NSString *) email;

+ (NSString *)getDeepLink:(NSString*) postType : (NSString*) contentId;


+ (NSString *)getDraftFeedUrl:(NSString *)postType page:(int) page;
+ (NSString *)setPublish:(NSString *)postType contentId:(NSString*) contentId;
+ (NSString *)setApprove:(NSString *)postType contentId:(NSString*) contentId like:(int) like;
+ (NSString *)getApprovalUser:(NSString*) postType : (NSString*) contentId page:(int) page;

@end
