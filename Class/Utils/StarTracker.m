//
//  StarTracker.m
//  StarClub
//
//  Created by Ian Cartwright on 16.05.14.
//
//

#import "StarTracker.h"

//#import "NSUserDefaults.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "PiwikTracker.h"

#import "Base64.h"
#import "QuantcastMeasurement.h"







#ifdef ENRIQUE
    #define GA_PROPERTY_ID @"UA-46624794-3"
    #define STAR_TRACKER_ID @"8"
    #define STAR_TRACKER_AUTH_TOKEN  @"4d1ff0386c1933bcb68ad517a6573d1e"
    #define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
    #define QUANTCAST_ID        @"EI App"
#endif

#ifdef GEEK
#define GA_PROPERTY_ID @"UA-46624794-3"
#define STAR_TRACKER_ID @"8"
#define STAR_TRACKER_AUTH_TOKEN  @"4d1ff0386c1933bcb68ad517a6573d1e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
#define QUANTCAST_ID        @"Geek App"
#endif

#ifdef FOOTBALL
#define GA_PROPERTY_ID @"UA-46624794-3"
#define STAR_TRACKER_ID @"8"
#define STAR_TRACKER_AUTH_TOKEN  @"4d1ff0386c1933bcb68ad517a6573d1e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
#define QUANTCAST_ID        @"Football App"
#endif

#ifdef MARVEL
#define GA_PROPERTY_ID @"UA-46624794-3"
#define STAR_TRACKER_ID @"8"
#define STAR_TRACKER_AUTH_TOKEN  @"4d1ff0386c1933bcb68ad517a6573d1e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
#define QUANTCAST_ID        @"Marvel App"
#endif

#ifdef ENRIQUEDEV
#define GA_PROPERTY_ID @"UA-46624794-3"
#define STAR_TRACKER_ID @"8"
#define STAR_TRACKER_AUTH_TOKEN  @"4d1ff0386c1933bcb68ad517a6573d1e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
#define QUANTCAST_ID        @"EI App"
#endif

#ifdef PHOTOGENICS
#define GA_PROPERTY_ID @"UA-46624794-3"
#define STAR_TRACKER_ID @"8"
#define STAR_TRACKER_AUTH_TOKEN  @"4d1ff0386c1933bcb68ad517a6573d1e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
#define QUANTCAST_ID        @"Photogenics App"
#endif

#ifdef SCOTT
#define GA_PROPERTY_ID @"UA-46624794-3"
#define STAR_TRACKER_ID @"8"
#define STAR_TRACKER_AUTH_TOKEN  @"4d1ff0386c1933bcb68ad517a6573d1e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
#define QUANTCAST_ID        @"Scott Disick App"
#endif

#ifdef TYRESE
    #define GA_PROPERTY_ID @"UA-46624794-8"
    #define STAR_TRACKER_ID @"9"
    #define STAR_TRACKER_AUTH_TOKEN @"4d1ff0386c1933bcb68ad517a6573d1e"
    #define QUANTCAST_KEY       @"0no4ke096ler55tf-0q3dsg2cb72n34y9"
    #define QUANTCAST_ID        @"Tyrese App"
#endif

#ifdef SUAVESAYS
#define GA_PROPERTY_ID @"UA-46624794-8"
#define STAR_TRACKER_ID @"9"
#define STAR_TRACKER_AUTH_TOKEN @"4d1ff0386c1933bcb68ad517a6573d1e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-0q3dsg2cb72n34y9"
#define QUANTCAST_ID        @"Suavesays App"
#endif

#ifdef NICOLE
#define GA_PROPERTY_ID @"UA-46624794-8"
#define STAR_TRACKER_ID @"4"
#define STAR_TRACKER_AUTH_TOKEN @"f2c47655b3c9a089b74c4c82b8b0161e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-yvv900r2h8855hk4"
#define QUANTCAST_ID        @"Nicole App"
#endif

#ifdef STARDEMO
#define GA_PROPERTY_ID @"UA-46624794-8"
#define STAR_TRACKER_ID @"4"
#define STAR_TRACKER_AUTH_TOKEN @"f2c47655b3c9a089b74c4c82b8b0161e"
#define QUANTCAST_KEY       @"0no4ke096ler55tf-0q3dsg2cb72n34y9"
#define QUANTCAST_ID        @"Stardemo App"
#endif

static NSString *const kGaPropertyId = GA_PROPERTY_ID;

static NSString * const StarTrackerTestServerURL = @"http://reports.starsite.com/";
static NSString * const StarTrackerProductionServerURL = @"http://reports.starsite.com/";
static NSString * const StarTrackerTestSiteID = STAR_TRACKER_ID;
static NSString * const StarTrackerProductionSiteID = STAR_TRACKER_ID;
static NSString * const StarTrackerTestAuthenticationToken = STAR_TRACKER_AUTH_TOKEN;
static NSString * const StarTrackerProductionAuthenticationToken = STAR_TRACKER_AUTH_TOKEN;





@implementation StarTracker




+ (void)StarRunStatus :(int)status :(NSString *)Catagory :(NSString *)Action : (NSString *)Label {

    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    
    if (status == DID_LAUNCH) {
        
        
        
//  Init Pwik first
        
        NSLog(@"Init Piwik");
        
  //          [[NSUserDefaults standardUserDefaults] registerDefaults:@{PiwikAskedForPermissonKey : @(NO)}];

            // Initialize the Piwik Tracker
            // Use different Piwik server urls and tracking site data depending on if building for test or production.
            #ifdef DEBUG
            [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:StarTrackerTestServerURL] siteID:StarTrackerTestSiteID authenticationToken:StarTrackerTestAuthenticationToken];
            #else
            [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:StarTrackerProductionServerURL] siteID:StarTrackerProductionSiteID authenticationToken:StarTrackerProductionAuthenticationToken];
            #endif

            // Configure the tracker
            //  [PiwikTracker sharedInstance].debug = YES; // Uncomment to print event to the console instead of sending it to the Piwik server
            //  [PiwikTracker sharedInstance].dispatchInterval = 0;

            // Do not track anything until the user give consent
//            if (![[NSUserDefaults standardUserDefaults] boolForKey:PiwikAskedForPermissonKey]) {
 //               [PiwikTracker sharedInstance].optOut = YES;
 //           }
        
        [PiwikTracker sharedInstance].dispatchInterval = 30;
        [PiwikTracker sharedInstance].optOut = NO;
        [PiwikTracker sharedInstance].debug = NO;
 //       [PiwikTracker sharedInstance].sampleRate = 80.0;
        [[PiwikTracker sharedInstance] setIncludeLocationInformation :NO];
        
        [[PiwikTracker sharedInstance]  sendEventWithCategory:Catagory action:Action label:Label];

        
// Now Google
        
        
        /*
         *  Google Analysis V3
         */
        
        
        // Initialize tracker.
        
            NSLog(@"Init GA");
            
            id tracker = [[GAI sharedInstance] trackerWithTrackingId:kGaPropertyId];
            
            // CAUTION: Setting session control directly on the tracker persists the
            // value across all subsequent hits, until it is manually set to null.
            // This should never be done in normal operation.
            //
            // [tracker set:kGAISessionControl value:@"start"];
        
#ifdef DEBUG
            [[GAI sharedInstance] setDryRun:NO];
#else
            [[GAI sharedInstance] setDryRun:NO];
#endif
        
            // Instead, send a single hit with session control to start the new session.
            
            // Set the log level to verbose.
            [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
            [[GAI sharedInstance] setDispatchInterval:30];
            
            
            // Now Send Event
            [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:Catagory
                                    action:Action
                                    label:Label
                                    value:nil] set:@"start" forKey:kGAISessionControl] build]];
            
            [[GAI sharedInstance] dispatch];
        
        
        
        // Now Quantcast
        

        [[QuantcastMeasurement sharedInstance] beginMeasurementSessionWithAPIKey:QUANTCAST_KEY
                                                                  userIdentifier:userInfo[@"id"] labels:nil];
        
        
        // Next command ?

        } else if (status == DID_TERMINATE || status == IS_ACTIVE || status == IS_BACKGROUND || status == DID_SIGNOUT || status == DID_SIGNIN) {

            // Now Piwik
        [[PiwikTracker sharedInstance]  sendEventWithCategory:Catagory action:Action label:Label];
        
            
            // Now GA
            id tracker = [[GAI sharedInstance] trackerWithTrackingId:kGaPropertyId];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:Catagory
                                                                  action:Action
                                                                   label:Label
                                                                   value:nil] build]];
                
                [[GAI sharedInstance] dispatch];

        }
    
        // Now Quantcast
        if (status == DID_SIGNIN) {
           [[QuantcastMeasurement sharedInstance] recordUserIdentifier:userInfo[@"id"] withLabels:nil];
        }
}


+ (void)StarSendView :(NSString *) View {
    
    // Now Piwik
    [[PiwikTracker sharedInstance] sendView: View];
    
    // Now GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:View
                                                      forKey:kGAIScreenName] build]];
    
    }


+ (void)StarSendEvent : (NSString *)Catagory : (NSString *)Action : (NSString *)Label { //class method. Logs different events
    
    
        // Now Piwik
        [[PiwikTracker sharedInstance]  sendEventWithCategory:Catagory action:Action label:Label];
        
        
        // Now GA
        id tracker = [[GAI sharedInstance] trackerWithTrackingId:kGaPropertyId];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:Catagory
                                                              action:Action
                                                               label:Label
                                                               value:nil] build]];
        
        [[GAI sharedInstance] dispatch];



     }


@end

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"&",
//                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end
