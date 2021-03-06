//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

#import "NSDictionary+JRAdditions.h"

@implementation NSDictionary (JRAdditions)

- (NSDictionary *) dictionaryByReplacingNullsWithStrings {
    
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary: self];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for (NSString *key in self) {
        const id object = [self objectForKey: key];
        if (object == nul) {
            [replaced setObject: blank forKey: key];
        }
        else if ([object isKindOfClass: [NSDictionary class]]) {
            [replaced setObject: [(NSDictionary *) object dictionaryByReplacingNullsWithStrings] forKey: key];
        }
    }
    return [NSDictionary dictionaryWithDictionary: replaced];
}

@end
