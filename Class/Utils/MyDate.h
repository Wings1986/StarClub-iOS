//
//  MyDate.h
//  StarClub
//
//  Created by MAYA on 4/10/12.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


enum DATE_OPTION {
    DATE_FULL,
    DATE_DATE,
    DATE_TIME,
    DATE_ENG_DATE,
    DATE_ENG_MONTH,
    };


@interface MyDate : NSObject

+(NSDate*) dateFromString:(NSString*) string : (int) option;

+(NSString*) getDateString:(NSDate*) date : (int) option;

+(NSString*) convertDate:(NSString*) string : (int) option;

@end
