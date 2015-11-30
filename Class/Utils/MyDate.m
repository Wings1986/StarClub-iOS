//
//  Utils.m
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyDate.h"

@implementation MyDate


+(NSDate*) dateFromString:(NSString*) string : (int) option{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    
    if (option == DATE_DATE) {
        [dateFormat setDateFormat:@"yyy-MM-dd"];
    } else if (option == DATE_TIME) {
        [dateFormat setDateFormat:@"HH:mm"];
    } else {
        [dateFormat setDateFormat:@"yyy-MM-dd HH:mm"];
    }
    
    return [dateFormat dateFromString: string];
    
} 
+(NSString*) getDateString:(NSDate*) date : (int) option{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    
    if (option == DATE_DATE) {
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
    } else if (option == DATE_TIME) {
        [dateFormat setDateFormat:@"HH:mm"];
    } else {
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    NSString* strDate = [dateFormat stringFromDate: date];
    return strDate;
}

+(NSString*) convertDate:(NSString*) string : (int) option
{
    NSDate * date = [self dateFromString:string :DATE_DATE];
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    
    if (option == DATE_ENG_DATE) {
        [dateFormat setDateFormat:@"MMM d yyyy"];
    }
    else if (option == DATE_ENG_MONTH){
        [dateFormat setDateFormat:@"MMM d"];
    }
    
    NSString* strDate = [dateFormat stringFromDate: date];
    return strDate;

}

@end
