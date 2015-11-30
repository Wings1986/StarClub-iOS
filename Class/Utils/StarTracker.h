//
//  StarTracker.h
//  StarClub
//
//  Created by Ian Cartwright on 16.05.14.
//
//

#import <Foundation/Foundation.h>


enum RUN_STATUS {
    DID_LAUNCH,
    DID_TERMINATE,
    DID_SIGNOUT,
    DID_SIGNIN,
    IS_ACTIVE,
    IS_BACKGROUND,
};

@interface StarTracker : NSObject


+ (void)StarRunStatus :(int)status  : (NSString *)Catagory : (NSString *)Action : (NSString *)Label ; //class method. Logs different run time status

+ (void)StarSendView :(NSString *) View; //class method. Logs different screen views

+ (void)StarSendEvent : (NSString *)Catagory : (NSString *)Action : (NSString *)Label ; //class method. Logs different events

@end


@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
