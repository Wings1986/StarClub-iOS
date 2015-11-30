//
//  Constants.h
//  GHSidebarNav
//
//  Created by MAYA on 12/30/13.
//
//

#ifndef _Constants_h
#define _Constants_h

//============================ DEFINE  =============================================

/*  BrightCove Define
    If you do not need BrightCove, Please comment that define
*/
#define BRIGHT_SDK
//#define BRIGHT_SDK

/*  DFP for Google ADS
        If you do not need DFP, Please comment that define
*/
#define GOOGLE_DFP
#define GOOGLE_DFP_SWIPE



// Now defined in Xcode Targets PreProcessor

//#define ENRIQUE     @"Enrique"
//#define TYRESE        @"Tyrese"
//#define SNOOPY      @"Snoop Dogg"
//#define PHOTOGENICE @"Photogenics"
//#define NICOLE     @"Nicole"
//#define STARDEMO     @"Stardemo"



#ifdef ENRIQUE

    #define DEEPLINK_APP_URL    @"com.myapp.starclub.enrique"   //  ONLY lower case here !!!
    #define DEEPLINK_WEB_URL    @"http://enrique.starsite.com/#homefeed"
    #define SHARE_APP_LOGO      @"http://cms.enrique.starsite.com/assets/enrique-logo.jpg"

    #define BC_FB_PLAYWINURL    @"http://enrique.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

    #define MENU_MAIN_FEED      @"All Access"
    #define MENU_DRAFT          @"Draft View"
    #define MENU_COMMUNITY      @"Community"
    #define MENU_TOUR           @"Tour Dates"
    #define MENU_QUIZ           @"Polls & Contests"
    #define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



   #ifdef GOOGLE_DFP

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

    #else
        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

    #endif  // GOOGLE_DFP

#endif  // ENRIQUE

#ifdef SUAVESAYS

#define DEEPLINK_APP_URL    @"com.myapp.starclub.suavesays"   //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://suavesays.starsite.com/#homefeed"
#define SHARE_APP_LOGO      @"http://cms.suavesays.starsite.com/assets/suavesays-logo.jpg"

#define BC_FB_PLAYWINURL    @"http://suavesays.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"Community"
#define MENU_TOUR           @"Tour Dates"
#define MENU_QUIZ           @"Polls & Contests"
#define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



#ifdef GOOGLE_DFP

#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#else
#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#endif  // GOOGLE_DFP

#endif  // SUAVESAYS


#ifdef FOOTBALL

#define DEEPLINK_APP_URL    @"com.myapp.starclub.football"   //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://football.starsite.com/#homefeed"
#define SHARE_APP_LOGO      @"http://cms.football.starsite.com/assets/football-logo.jpg"
#define BC_FB_PLAYWINURL    @"http://football.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"Community"
#define MENU_TOUR           @"Events"
#define MENU_QUIZ           @"Polls & Contests"
#define MENU_MUSIC          @"Audio"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



#ifdef GOOGLE_DFP

#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#else
#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#endif  // GOOGLE_DFP

#endif  // FOOTBALL

#ifdef GEEK

#define DEEPLINK_APP_URL    @"com.myapp.starclub.geek"   //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://geek.starsite.com/#homefeed"
#define SHARE_APP_LOGO      @"http://cms.geek.starsite.com/assets/geek-logo.jpg"
#define BC_FB_PLAYWINURL    @"http://geek.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"Community"
#define MENU_TOUR           @"Geeks"
#define MENU_QUIZ           @"Polls & Contests"
#define MENU_MUSIC          @"Audio"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



#ifdef GOOGLE_DFP

#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#else
#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#endif  // GOOGLE_DFP

#endif  // GEEK




#ifdef MARVEL

#define DEEPLINK_APP_URL    @"com.myapp.starclub.marvel"   //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://marvel.starsite.com/#homefeed"
#define SHARE_APP_LOGO      @"http://cms.marvel.starsite.com/assets/marvel-logo.jpg"
#define BC_FB_PLAYWINURL    @"http://marvel.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"Community"
#define MENU_TOUR           @"Events"
#define MENU_QUIZ           @"Polls & Contests"
#define MENU_MUSIC          @"Audio"


#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



#ifdef GOOGLE_DFP

#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#else
#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#endif  // GOOGLE_DFP

#endif  // MARVEL

#ifdef ENRIQUEDEV

#define DEEPLINK_APP_URL    @"com.myapp.starclub.enriquedev"   //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://dev.cms.enrique.starsite.com/enrique/#homefeed"
#define SHARE_APP_LOGO      @"http://dev.cms.enrique.starsite.com/assets/enriquedev-logo.jpg"
#define BC_FB_PLAYWINURL    @"http://dev.cms.enrique.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"Community"
#define MENU_TOUR           @"Tour Dates"
#define MENU_QUIZ           @"Polls & Contests"
#define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



#ifdef GOOGLE_DFP

#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#else
#define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
#define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
#define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
#define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
#define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
#define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
#define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
#define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
#define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
#define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
#define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
#define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
#define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
#define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
#define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

#endif  // GOOGLE_DFP

#endif  // ENRIQUEDEV


#ifdef  SCOTT

#define DEEPLINK_APP_URL    @"com.myapp.starclub.scottdisick"   //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://lorddisick.starsite.com/#homefeed"
#define SHARE_APP_LOGO      @"http://cms.lorddisick.starsite.com/assets/scott-logo.jpg"
#define BC_FB_PLAYWINURL    @"http://lorddisick.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"Community"
#define MENU_TOUR           @"Events"
#define MENU_QUIZ           @"Polls & Quizzes"
#define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



    #ifdef GOOGLE_DFP

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

    #else
        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

    #endif  //GOOGLE_DFP

#endif  // SCOTT


#ifdef TYRESE

    #define DEEPLINK_APP_URL    @"com.myapp.starclub.tyrese"   //  ONLY lower case here !!!
    #define DEEPLINK_WEB_URL    @"http://tyrese.starsite.com/#homefeed"
    #define SHARE_APP_LOGO      @"http://cms.tyrese.starsite.com/assets/tyrese-logo.jpg"
    #define BC_FB_PLAYWINURL    @"http://tyrese.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN


    #define MENU_MAIN_FEED      @"All Access"
    #define MENU_DRAFT          @"Draft View"
    #define MENU_COMMUNITY      @"Community"
    #define MENU_TOUR           @"Events"
    #define MENU_QUIZ           @"Polls & Quizzes"
    #define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";


    #ifdef GOOGLE_DFP

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"

    #else

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"

    #endif  // GOOGLE_DFP

#endif  // TYRESE


#ifdef NICOLE

    #define DEEPLINK_APP_URL    @"com.myapp.starclub.nicole"   //  ONLY lower case here !!!
    #define DEEPLINK_WEB_URL    @"http://nicole.starsite.com/#homefeed"
    #define SHARE_APP_LOGO      @"http://cms.nicole.starsite.com/assets/nicole-logo.jpg"
    #define BC_FB_PLAYWINURL    @"http://nicole.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

    #define MENU_MAIN_FEED      @"All Access"
    #define MENU_DRAFT          @"Draft View"
    #define MENU_COMMUNITY      @"Community"
    #define MENU_TOUR           @"Tour Dates"
    #define MENU_QUIZ           @"Polls & Contests"
    #define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



    #ifdef GOOGLE_DFP

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"

    #else

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"

    #endif  // GOOGLE_DFP

#endif  // NICOLE


#ifdef STARDEMO

#define DEEPLINK_APP_URL    @"com.myapp.starclub.stardemo"   //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://stardemo.starsite.com/#homefeed"
#define SHARE_APP_LOGO      @"http://cms.stardemo.starsite.com/assets/stardemo-logo.jpg"
#define BC_FB_PLAYWINURL    @"http://stardemo.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"Community"
#define MENU_TOUR           @"Events"
#define MENU_QUIZ           @"Polls & Quizzes"
#define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";



#ifdef GOOGLE_DFP

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"

#else

        #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/7509760071"
        #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/3079560472"
        #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/4556293671"
        #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/7509760071"

#endif // GOOGLE_DFP

#endif  //  STARDEMO


#ifdef PHOTOGENICS

#define DEEPLINK_APP_URL    @"com.myapp.starclub.photogenics"    //  ONLY lower case here !!!
#define DEEPLINK_WEB_URL    @"http://photogenics.starsite.com/#homefeed"
#define SHARE_APP_LOGO      @"http://cms.photogenics.starsite.com/assets/photogenics-logo.jpg"
#define BC_FB_PLAYWINURL    @"http://photogenics.starsite.com/viewvideo.php?video="

//    #define DISABLE_BC_FB_WIN

#define MENU_MAIN_FEED      @"All Access"
#define MENU_DRAFT          @"Draft View"
#define MENU_COMMUNITY      @"New Models"
#define MENU_TOUR           @"Events"
#define MENU_QUIZ           @"Polls & Quizzes"
#define MENU_MUSIC          @"Music Player"

#define AVIARY_API_KEY          @"2af581758300d42b";    // Key registered as STARCLUB APP at Aviary
#define AVIARY_SECRET_KEY       @"68ed531242ca912a";


        #ifdef GOOGLE_DFP

            #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
            #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
            #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
            #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
            #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
            #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
            #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
            #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
            #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
            #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
            #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
            #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
            #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
            #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
            #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

            #else
            #define ADMOB_COMMUNITY_ID_1        @"ca-app-pub-7963321383486508/7860883674"
            #define ADMOB_COMMUNITY_ID_2        @"ca-app-pub-7963321383486508/1001702873"
            #define ADMOB_COMMUNITY_ID_3        @"ca-app-pub-7963321383486508/2478436077"
            #define ADMOB_HOME_ID_1             @"ca-app-pub-7963321383486508/6523751270"
            #define ADMOB_HOME_ID_2             @"ca-app-pub-7963321383486508/7048236476"
            #define ADMOB_HOME_ID_3             @"ca-app-pub-7963321383486508/8524969671"
            #define ADMOB_PHOTO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/4972966074"
            #define ADMOB_PHOTO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/3955169275"
            #define ADMOB_PHOTO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/5431902476"
            #define ADMOB_PHOTO_GRID_ID_1       @"ca-app-pub-7963321383486508/3496232870"
            #define ADMOB_PHOTO_GRID_ID_2       @"ca-app-pub-7963321383486508/6908635670"
            #define ADMOB_PHOTO_GRID_ID_3       @"ca-app-pub-7963321383486508/8385368878"
            #define ADMOB_VIDEO_GALLARY_ID_1    @"ca-app-pub-7963321383486508/6449699270"
            #define ADMOB_VIDEO_GALLARY_ID_2    @"ca-app-pub-7963321383486508/2338835278"
            #define ADMOB_VIDEO_GALLARY_ID_3    @"ca-app-pub-7963321383486508/3815568470"

        #endif  // GOOGLE_DFP

#endif  // PHOTOGENICS





/*
 1. Please set bundle ID

 2. Please set facebook ID and name on Plist file
 */

//====================================================================================




//#define TEST_LAYOUT


#ifdef TEST_LAYOUT

    #define FONT_NAME       @"HelveticaNeue-Light"
    #define FONT_NAME_BOLD  @"HelveticaNeue-Medium"

    #define FONT_SIZE_CAPTION   15.0f
    #define FONT_QUIZ_TITLE     19.0f
    #define FONT_POLL_TITLE     19.0f

    #define STATUS_BAR_STYLE                    UIStatusBarStyleLightContent animated:NO
    #define MAIN_FRAME_COLOR_BACKGROUND         [UIColor blackColor]
    #define UINAVIGATION_BAR_COLOR_BARTINT      [UIColor blackColor]
    #define UINAVIGATION_BAR_COLOR_TINT         [UIColor whiteColor]
    #define NAVIGATION_BAR_COLOR_BARTINT        [UIColor blueColor]
    #define NAVIGATION_BAR_COLOR_TINT           [UIColor yellowColor]
    #define NAVIGATION_BAR_TRANSLUCENT          NO

    #define SIDE_MENU_COLOR_BACKGROUND          [UIColor blackColor]
    #define SIDE_MENU_COLOR_BACKGROUND_VIEW     [UIColor colorWithRed:(50.0f/255.0f) green:(50.0f/255.0f) blue:(50.0f/255.0f) alpha:1.0f]
    #define SIDE_MENU_COLOR_TEXT                [UIColor whiteColor]
    #define SIDE_MENU_COLOR_TOPLINE             [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0]
    #define SIDE_SEARCH_COLOR_BACKGROUND_VIEW   [UIColor whiteColor]
    #define SIDE_SEARCH_COLOR_BACKGROUND        [UIColor blackColor]
    #define SIDE_SEARCH_COLOR_TEXT              [UIColor colorWithRed:(0.0f/255.0f) green:(0.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f]

#else

    #define FONT_NAME       @"HelveticaNeue-Light"
    #define FONT_NAME_BOLD  @"HelveticaNeue-Medium"




    #define FONT_SIZE_CAPTION   15.0f

    #define FONT_QUIZ_TITLE     17.0f
    #define FONT_QUIZ_QUESTION  17.0f
    #define FONT_QUIZ_RESULT    17.0f
    #define FONT_QUIZ_RESULT_COLOR  [UIColor redColor]

    #define FONT_POLL_TITLE     17.0f
    #define FONT_POLL_RESULT    14.0f


    #define STATUS_BAR_STYLE                    UIStatusBarStyleDefault animated:NO

    #define MAIN_FRAME_COLOR_BACKGROUND         [UIColor whiteColor]
    #define UINAVIGATION_BAR_COLOR_BARTINT      [UIColor whiteColor]
    #define UINAVIGATION_BAR_COLOR_TINT         [UIColor blackColor]
    #define NAVIGATION_BAR_COLOR_BARTINT        [UIColor blueColor]
    #define NAVIGATION_BAR_COLOR_TINT           [UIColor whiteColor]
    #define NAVIGATION_BAR_TRANSLUCENT          NO

    #define SIDE_MENU_COLOR_BACKGROUND          [UIColor whiteColor]
    #define SIDE_MENU_COLOR_BACKGROUND_VIEW     [UIColor colorWithRed:(230.0f/255.0f) green:(230.0f/255.0f) blue:(230.0f/255.0f) alpha:1.0f]
    #define SIDE_MENU_COLOR_TEXT                [UIColor blackColor]
    #define SIDE_MENU_COLOR_TOPLINE             [UIColor colorWithRed:(204.0f/255.0f) green:(204.0f/255.0f) blue:(204.0f/255.0f) alpha:1.0f];
    #define SIDE_SEARCH_COLOR_BACKGROUND_VIEW   [UIColor whiteColor]
    #define SIDE_SEARCH_COLOR_BACKGROUND        [UIColor whiteColor]
    #define SIDE_SEARCH_COLOR_TEXT              [UIColor colorWithRed:(0.0f/255.0f) green:(0.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f]

#endif


#endif
