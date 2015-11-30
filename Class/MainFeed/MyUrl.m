//
//  MyUrl.m
//  StarClub
//
//  Created by MAYA on 1/7/14.
//
//

#import "MyUrl.h"

@implementation MyUrl


+ (NSString *)getLoginUrl:(NSString *)email password:(NSString *)password
{
    NSString *urlString = @"";
    
    if (DEVICETOKEN == nil) {
        urlString = [[SERVER_URL stringByAppendingFormat:@"option=login&email=%@&password=%@&cid=%d&ud_token=123455", email, password, CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else {
        urlString = [[SERVER_URL stringByAppendingFormat:@"option=login&email=%@&password=%@&cid=%d&ud_token=%@", email, password, CID, DEVICETOKEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSLog(@"login url : %@", urlString);
    
    return urlString;
}
+ (NSString *)getSignUpUrl
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=register"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"signup url : %@", urlString);
    
    return urlString;
}
+ (NSString *)getUpdateUser
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=update_user"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"update user url : %@", urlString);
    
    return urlString;
}


+ (NSString *)getMainFeedUrl:(NSString *)postType
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_main_feed&cid=%d&token=%@&post_type=%@&user_id=%@", CID, TOKEN, postType, USERID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"main feed url : %@", urlString);
    
    return urlString;
}
+ (NSString *)getMainFeedUrl:(NSString *)postType page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_main_feed&cid=%d&token=%@&post_type=%@&user_id=%@&page=%d&comment_count=3", CID, TOKEN, postType, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"main feed url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getCommunityFeedUrl:(NSString *)postType
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_community_feed&cid=%d&token=%@&post_type=%@&user_id=%@", CID, TOKEN, postType, USERID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"community feed url : %@", urlString);
    
    return urlString;
}
+ (NSString *)getCommunityFeedUrl:(NSString *)postType page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_community_feed&cid=%d&token=%@&post_type=%@&user_id=%@&page=%d", CID, TOKEN, postType, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"community feed url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getCommunityFeedFollowedUrl:(NSString *)postType
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_community_of_follow&cid=%d&token=%@&post_type=%@&self_user_id=%@", CID, TOKEN, postType, USERID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getCommunityFeedFollowedUrl: %@", urlString);
    
    return urlString;
}
+ (NSString *)getCommunityFeedFollowedUrl:(NSString *)postType page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_community_of_follow&cid=%d&token=%@&post_type=%@&self_user_id=%@&page=%d", CID, TOKEN, postType, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getCommunityFeedFollowedUrl: %@", urlString);
    
    return urlString;
}


+ (NSString *)getTourDate
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_events&cid=%d&token=%@", CID, TOKEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Tour Date url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getRanking
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_rating&cid=%d&token=%@", CID, TOKEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Ranking url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getRanking:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_rating&cid=%d&token=%@&count=10&page=%d", CID, TOKEN, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Ranking url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getUserSearch:(NSString*) search
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_rating&cid=%d&token=%@&count=0&search=%@", CID, TOKEN, search] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Ranking url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getLikeUser:(NSString*) postType : (NSString*) contentId page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_like_users&cid=%d&post_type=%@&content_id=%@&page=%d&count=10", CID, postType, contentId, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getLike user url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}


+ (NSString *)getPhotoGallery
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_photos&cid=%d&token=%@&user_id=%@", CID, TOKEN, USERID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"photo gallery url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getPhotoGallery:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_photos&cid=%d&token=%@&user_id=%@&count=36&page=%d", CID, TOKEN, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"photo gallery url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getVideoGallery
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_videos&cid=%d&token=%@&user_id=%@", CID, TOKEN, USERID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"video gallery url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getVideoGallery:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_videos&cid=%d&token=%@&user_id=%@&page=%d", CID, TOKEN, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"video gallery url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getShop
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_shops&cid=%d&token=%@", CID, TOKEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"get shops url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getMusics
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_musics&cid=%d&token=%@", CID, TOKEN] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"get music url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getUserProfile:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_user&cid=%d&token=%@&user_id=%@&self_user_id=%@&follow_param=1&page=%d", CID, TOKEN, USERID, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"User profile url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getUserInfo:(NSString *) userID page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_user&cid=%d&token=%@&self_user_id=%@&user_id=%@&follow_param=1&page=%d", CID, TOKEN, USERID, userID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"User url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getFollowUsersByMe:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_followusers_by_me&cid=%d&user_id=%@&count=10&page=%d", CID, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getFollowUsersByMe url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getFollowUsersFollowedMe:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_followusers_followed_me&cid=%d&user_id=%@&count=10&page=%d", CID, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getFollowUsersFollowedMe url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}



+ (NSString *)getDeleteFeed:(NSString*) postType : (NSString*) contentId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=delete_feed&cid=%d&token=%@&user_id=%@&post_type=%@&content_id=%@", CID, TOKEN, USERID, postType, contentId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getDeleteFeed url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)setFollowing:(NSString *)followingID
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=set_followuser&cid=%d&token=%@&user_id=%@&followed_user_id=%@", CID, TOKEN, USERID, followingID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"setFollowing url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)setUnFollowing:(NSString *)followingID
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=set_followuser&cid=%d&token=%@&user_id=%@&followed_user_id=%@&is_unfollow=1", CID, TOKEN, USERID, followingID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"setFollowing url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)setBlockFan:(NSString *)fanId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=set_block&cid=%d&token=%@&self_user_id=%@&user_id=%@", CID, TOKEN, USERID, fanId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"setBlockFan url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)setUnblockFan:(NSString *)fanId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=unset_block&cid=%d&token=%@&self_user_id=%@&user_id=%@", CID, TOKEN, USERID, fanId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"setBlockFan url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}


+ (NSString *)getComment:(NSString *)postType contentId:(NSString*) contentId page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_comment&cid=%d&token=%@&post_type=%@&content_id=%@&page=%d&comment_count=10", CID, TOKEN, postType, contentId, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"get comment url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)addComment:(NSString *)postType contentId:(NSString*) contentId comment:(NSString*) comment count:(int) commentCount
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=set_comment&cid=%d&token=%@&post_type=%@&content_id=%@&user_id=%@&comment=%@&comment_count=%d", CID, TOKEN, postType, contentId, USERID, comment, commentCount] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"add comment url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)deleteComment:(NSString *)postType contentId:(NSString*) contentId commentId:(NSString*) commentId count:(int) commentCount
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=delete_comment&cid=%d&token=%@&user_id=%@&post_type=%@&content_id=%@&comment_id=%@&comment_count=%d", CID, TOKEN, USERID, postType, contentId, commentId, commentCount] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"deleteComment url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)addLike:(NSString *)postType contentId:(NSString*) contentId like:(int) like
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=set_like&cid=%d&token=%@&post_type=%@&content_id=%@&user_id=%@&like=%d", CID, TOKEN, postType, contentId, USERID, like] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"add Like url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getLock:(NSString *)postType contentId:(NSString*) contentId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=buy_content&cid=%d&token=%@&user_id=%@&post_type=%@&content_id=%@", CID, TOKEN, USERID, postType, contentId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getLock url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)sendMessage:(NSString *) receiverId  text:(NSString *) text
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=send_message&cid=%d&token=%@&sender=%@&receiver=%@&message=%@", CID, TOKEN, USERID, receiverId, text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"send message url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getMessage:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_message&cid=%d&token=%@&user_id=%@&count=10&page=%d", CID, TOKEN, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"get message url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)readMessage:(NSString *) mailId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=update_seen&cid=%d&token=%@&mail_id=%@", CID, TOKEN, mailId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"read message url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getQuizAnswer:(NSString *) quizId  questionCount:(int) questionCount answerCount:(int) answerCount
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=quiz_answer&cid=%d&token=%@&user_id=%@&content_id=%@&correct_count=%d&question_count=%d", CID, TOKEN, USERID, quizId, answerCount, questionCount] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getQuizAnswer url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getPollAnswer:(NSString *) answerId questionId:(NSString *) questionId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=poll_answer&cid=%d&token=%@&user_id=%@&answer_id=%@&question_id=%@", CID, TOKEN, USERID, answerId, questionId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getPollAnswer url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}


+ (NSString *)getPushNotification
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_push&cid=%d&token=%@&user_id=%@", CID, TOKEN, USERID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"get push url : %@", urlString);

    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)setPushNotification:(NSString *)deviceToken : (int) enable
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=push_notification&cid=%d&token=%@&user_id=%@&user_token=%@&enable=%d", CID, TOKEN, USERID, deviceToken, enable] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"set push url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];

    return result;
}


+ (NSString *)getAddText:(NSString *) text
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=add_text&cid=%d&token=%@&user_id=%@&description=%@", CID, TOKEN, USERID, text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Add Text url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getAddImageUrl
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=add_photo"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlString;
}
+ (NSString *)getAddVideoUrl
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=add_video"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlString;
}
+ (NSString *)getExtraInfo:(NSString *) postType : (NSString *) contentId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_extradatas&cid=%d&token=%@&user_id=%@&post_type=%@&content_id=%@", CID, TOKEN, USERID, postType, contentId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getExtraInfo url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getQuizData:(NSString *) postType : (NSString *) contentId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_poll_quiz_content&cid=%d&token=%@&&post_type=%@&content_id=%@", CID, TOKEN, postType, contentId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getQuizData url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getHelp
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_helpurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"help url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)getAdminList
{
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_adminlist&cid=%d", CID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getForgetPasswordUrl:(NSString *) email
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=forget_password&cid=%d&email=%@", CID, email] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getForgetPasswordUrl url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getDeepLink:(NSString*) postType : (NSString*) contentId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_post_detail&cid=%d&user_id=%@&post_type=%@&content_id=%@&comment_count=3", CID, USERID, postType, contentId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getDeepLink url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getDraftFeedUrl:(NSString *)postType page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_main_feed&cid=%d&token=%@&post_type=%@&user_id=%@&page=%d&comment_count=3&draft=1", CID, TOKEN, postType, USERID, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"main feed url : %@", urlString);
    
    return urlString;
}

+ (NSString *)setPublish:(NSString *)postType contentId:(NSString*) contentId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=set_publish&cid=%d&post_type=%@&content_id=%@&user_id=%@&time_stamp=1", CID, postType, contentId, USERID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"setPublish url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}
+ (NSString *)setApprove:(NSString *)postType contentId:(NSString*) contentId like:(int) like
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=set_approval&cid=%d&token=%@&post_type=%@&content_id=%@&user_id=%@&approval=%d", CID, TOKEN, postType, contentId, USERID, like] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"add Like url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

+ (NSString *)getApprovalUser:(NSString*) postType : (NSString*) contentId page:(int) page
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"option=get_approval_users&cid=%d&post_type=%@&content_id=%@&page=%d&count=10", CID, postType, contentId, page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getApprovalUser url : %@", urlString);
    
    NSString * result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

@end
