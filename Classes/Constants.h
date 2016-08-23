/*
 *  Constants.h
 *  Transient Events
 *
 *  Created by Bruce E Truax on 9/2/09.
 *  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
 *
 */

/**
 @brief  Constants used throughoug Transient Events
 
 Contains various constants used throughout the program.  All .m files should import
 this file.
*/

//time splash screen is visible in seconds (must be an integer)
#define	kSplashScreenDisplayTime 2

#define kBuildStyle @"EMPTY"
#define kNotificationServer
#ifdef DEBUG
	#define kBuildStyle @"Debug Vers."
#endif
#ifdef DEVELOPMENT 
	#define kBuildStyle @"Devel Vers."
#endif
#ifdef RELEASE
	#define kBuildStyle @"Version"
#endif
#ifdef ADHOC
	#define kBuildStyle @"AdHoc Vers."
#endif

#ifdef SANDBOX
	#define kNotificationServer @"SANDBOX"
#else
	#define kNotificationServer @"PRODUCTION"
#endif


//#define LOGGING
#undef LOGGING

//UserDefault Keys
#define	kLocationLatitudeKey	@"LocationLatitudeKey"
#define kLocationLongitudeKey	@"LocationLongitudeKey"
#define kLimitingMagnitudeKey	@"LimitingMagnitudeKey"
#define kLocationNameKey		@"LocationNameKey"
#define kLimitingMagnitudeUpperLimitKey	@"LimitingMagnitudeUpperLimit"
#define kLimitingMagnitudeLowerLimitKey	@"LimitingMagnitudeLowerLimit"
#define kEventAgeKey			@"EventAgeKey"
#define kEventTypesKey			@"EventTypesKey"
#define	kRAFormatKey			@"RAFormatKey"
#define kVisibleObjectsOnlyKey	@"VisibleObjectsOnlyKey"
#define kEventThumbnailsKey		@"EventThumbnailsKey"
#define kAlertsOnKey			@"AlertsOnKey"
#define	kLocationAltitudeKey	@"LocationAltitudeKey"
#define kEventAgeMaxiumumAgeKey	@"EventAgeMaximumAgeKey"
#define	kHistoryKey				@"HistoryKey"
#define kMinAltitudeKey			@"MinumumAltitudeKey"
#define kMinimumAltitudeLowerLimitKey @"MinimumAltitudeLowerLimitKey"
#define kMinimumAltitudeUpperLimitKey @"MinimumAltitudeUpperLimitKey"
#define kPrimaryEventServerKey	@"PrimaryServerURLSettingKey"
#define kAlertStreamKey			@"AlertStreamKey"
#define kAlertEventIDKey		@"AlertEventIDKey"
#define kFirstRunKey			@"FirstRunKey"
#define kTakeSurveyKey			@"TakeSurveyKey"
#define kWifiNotificationTitle  @"3G Warning"

//UserDefaultValues

#define kLocationLatitudeDefault	31.9640917
#define kLocationLongitudeDefault	-111.599803
#define	kLocationAltitudeDefault	2100.0
#define	kLimitingMagnitudeDefault	18.0
#define	kLimitingMagnitudeLowerLimitDefault	23.0
#define kLimitingMagnitudeUpperLimitDefault	8.0
#define kEventAgeDefault			60
#define kEventTypesDefault			@"Unknown"
#define kRAFormatDefault			0
#define	kVisibleObjectsOnlyDefault	NO
#define kEventThumbnailsDefault		NO
#define	kAlertsOnDefault			NO
#define kEventAgeMaxiumumAgeDefault	100
#define	kMinimumAltitudeDefault		0
#define kMinimumAltitudeLowerLimit	0.0
#define kMinimumAltitudeUpperLimit	80.0
#define kLocationNameDefault		@"Kitt Peak"
#define kNumberOfSurveyReminders	5
#define	kShowSurveyTab				100000
#define kMaxCommentLength			2500

#define kRAFormatHMS	0
#define kRAFormatDecDeg	1

#define kPrimaryServerURL			@"http://lsst-tes.tuc.noao.edu/jsonQuery/"
//#define kPrimaryServerURL			@"http://www.skyalert.org/jsonQuery/"

#define kPushGateway				@"gateway.sandbox.push.apple.com"
#define kPushGatewayPort			2195

#define kPushServerURL				@"http://lsst-tes.tuc.noao.edu/registerDevice/"
#define kSurveyURL					@"http://lsst-tes.tuc.noao.edu/survey/"

#define kStreams					@"CRTS,CRTS2,CRTS3"

#define kHistoryAge 3*24*60*60 //3 days
//#define kHistoryAge 1000 
//Settings TableView cases

#define	kLocationCase		0
#define	kMagnitudeLimitCase	100
#define	kEventTypesCase		101
#define	kEventAgeCase		102
#define kMinAltitudeCase	103
#define kRAFormatCase		104
#define	kVisibleObjectsOnlyCase	105
#define kEventThumbnailsCase	106
#define kAlertsCase			200
#define kAboutCase			300

#define kTableViewRowHeight	60

//Notification Keys
#define kReloadNotification		@"NeedsReload"
#define kRefreshNotification	@"NeedsRefresh"
#define kAlertOccurredNotification @"AlertOccurred"

#define kEventListHelpFile		@"EventListHelp"
#define kBookmarkListHelpFile	@"BookmarkListHelp"
#define kSettingsListHelpFile	@"SettingsHelp"

#define kURLTimeoutInterval		60.0
#define kTableViewSize			375.0

//JSON keys
#define kDeclinationKey			@"Dec"
#define kRightAscensionKey		@"RA"
#define kEventIDKey				@"triggerIVORN"
#define kReferenceImageURLKey	@"referenceImageURL"
#define kEventTimeKey			@"firstEventTime"
#define kAlertTimeKey			@"triggerEventTime"
#define kTypeKey				@"type"
#define kMagnitudeKey			@"magnitude"
#define	kFreshImageURLKey		@"freshImageURL"
#define kFinderChartPageURLKey	@"findingChart"
#define kAttributionKey			@"attribution"
#define kFindingChartImageKey	@"findingChartImage"
#define kResumptionTokenKey		@"resumptionToken"
#define	kStreamKey				@"stream"

#define kURLForSkyAlert         @"http://skyalert.org/"
#define kURLForCRTS             @"http://crts.caltech.edu/"


#define kNavBarColor			[UIColor colorWithRed:.010 green:.045 blue:.27 alpha:1.0]
#define	kMapControlColor		[UIColor blueColor];
#define kTableViewBackgroundImage @"BGtelescope.jpg"
#define kTableEvenRowColor		[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75]
#define kTableOddRowColor	[UIColor colorWithRed:0.832 green:0.832 blue:0.832 alpha:.75]
#define kTableSettingsTableOddRowColor [UIColor colorWithRed:233/256.0 green:241/256.0 blue:246/256.0 alpha:.75]
#define kTextLabelFont      [UIFont fontWithName:@"Georgia-Bold" size:18]
#define kDetailTextLabelFont [UIFont fontWithName:@"Georgia" size:16]
#define kSettingsTextLabelFont [UIFont fontWithName:@"Georgia" size:16]
#define kSettingsDetailTextLabelFont [UIFont fontWithName:@"Georgia" size:14]
#define kDetailTextColor		[UIColor colorWithRed:.266	green:.285	blue:.5 alpha:1.0]
#define kIsVisibleObjectColor	[UIColor colorWithRed:57.0/256	green:97.0/256	blue:104.0/256 alpha:1.0]
#define kWillBeVisibleObjectColor	[UIColor colorWithRed:155.0/256	green:126.0/256	blue:69.0/256 alpha:1.0]
#define kWontBeVisibleObjectColor	[UIColor colorWithRed:126.0/256	green:40.0/256	blue:49.0/256 alpha:1.0]
#define kVisitedAlpha			0.7
#define kNotVisitedAlpha		1.0
#define kSettingsTableBackgroundColor [UIColor colorWithRed:10.0/256	green:56.0/256	blue:111.0/256 alpha:0.5]
#define kLocationListTextLabelColor  [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75]
#define kLocationListDetailTextLabelColor [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.5]
#define kSurveyItemColor [UIColor colorWithRed:0.0/256	green:213.0/256	blue:209.0/256 alpha:1.0]

#define kOddSurveyButtonBackgroundColor			[UIColor colorWithRed:255.0/256	green:255.0/256	blue:255.0/256 alpha:1.0]
#define kEvenSurveyButtonBackgroundColor		[UIColor colorWithRed:201.0/256	green:210.0/256	blue:254.0/256 alpha:1.0]
#define kSelectedSurveyButtonBackgroundColor	[UIColor colorWithRed:31.0/256	green:55.0/256	blue:110.0/256 alpha:1.0]
#define kSurveyItemTextColor					[UIColor colorWithRed:70.0/256	green:99.0/256	blue:149.0/256 alpha:1.0]

#define kWebViewAlpha			0.5

//Survey questions answer keys
#define kQuestion1Key	@"Question1Key"
#define kQuestion2Key	@"Question2Key"
#define	kQuestion3Key	@"Question3Key"
