//
//  AltAzComputation.m
//  Transient Events
//
//  Created by Bruce E Truax on 10/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "AltAzComputation.h"
#import "Constants.h"


@implementation AltAzComputation
@synthesize				RA;
@synthesize				DEC;
@synthesize				altitude;
@synthesize				azimuth;
@synthesize				J2000EpochDate;

/**
 If this initilizer is used then RA and DEC must be
 set explicitly prior to accessing result values.
 */

- (id)init{
	//get longitude and latitude from user defaults
	userDefaults = [NSUserDefaults standardUserDefaults];
	longitude = [userDefaults doubleForKey:kLocationLongitudeKey];
	latitude  = [userDefaults doubleForKey:kLocationLatitudeKey];
	//compute the J2000 epoch date.  The internal reference date is Jan 1 2001.  2000
	//was a leap year and the 2000 epoch date was therefore 365.5 days prior to Jan 1, 2001.

	J2000EpochDate = [NSDate dateWithTimeIntervalSinceReferenceDate:-365.5*24*60*60];
//	NSLog(@"ReferenceDate = %@",[J2000EpochDate description]);
	self.RA = 0.0;
	self.DEC = 0.0;
	altitude = 0.00;
	azimuth = 0.00;
	[super init];
	return self;
}
/**
 Call this initializer with the RA and DEC used for the computation.
 Immediately after calling this initializer the altitude, azimuth and
 maxAltitude accessors can be called to computer the relevant values.
 */
- (id)initWithRA:(double)rightAscension DEC:(double)declination{
	userDefaults = [NSUserDefaults standardUserDefaults];
	longitude = [userDefaults doubleForKey:kLocationLongitudeKey];
	latitude  = [userDefaults doubleForKey:kLocationLatitudeKey];
	//compute the J2000 epoch date.  The internal reference date is Jan 1 2001.  2000
	//was a leap year and the 2000 epoch date was therefore 365.5 days prior to Jan 1, 2001.
	J2000EpochDate = [NSDate dateWithTimeIntervalSinceReferenceDate:-365.5*24*60*60];
//	NSLog(@"ReferenceDate = %@",[J2000EpochDate description]);
	self.RA = 0.0;
	self.DEC = 0.0;
	altitude = 0.00;
	azimuth = 0.00;
	//set the RA and DEC values
	self.RA = rightAscension;
	self.DEC = declination;
	[super init];
	return self;
	
}

- (void)compute{
	//get the current time
	double days = [[NSDate date] timeIntervalSinceDate:J2000EpochDate]/86400.0;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
	//OK now we have the time from midnight in a string.
//	NSLog(@"Time = %@   GMT Time = %@",[[NSDate date] description], dateString);	
	//extract the various time components so we can use them in the computation
	NSArray *timeComponents = [[NSArray alloc] initWithArray:[dateString componentsSeparatedByString:@":"]];
	float  hours, minutes, seconds;
	hours = [[timeComponents objectAtIndex:0] floatValue];
	minutes = [[timeComponents objectAtIndex:1] floatValue];
	seconds = [[timeComponents objectAtIndex:2] floatValue];
	[timeComponents release];
	//compute universal time and local siderial time
	double UT = hours + (minutes/60.0) + (seconds/3600.0);
	double LST = 100.46 + (0.985647 * days) + longitude + 15.0 * UT;
	double tmp;
	LST = modf(LST/360, &tmp)*360.0;
	double HA = LST - RA;
	//Now convert everything to radians
	double DECrad, LATrad, HArad;
	DECrad = M_PI * DEC/180.0;
	LATrad = M_PI * latitude/180.0;
	HArad  = M_PI * HA/180.0;
	double ALT = sin(DECrad)*sin(LATrad) + cos(DECrad)*cos(LATrad)*cos(HArad);
	ALT = asin(ALT);
	
	double A = (sin(DECrad)- sin(ALT)*sin(LATrad))/(cos(LATrad)*cos(ALT));
	A = acos(A);
	altitude = 180*ALT/M_PI;
	azimuth = 180*A/M_PI;
	if (sin(HA)<0) azimuth = 360-azimuth;
	
	[dateFormatter release];
}
/**
 Calls [self compute] and returns altitude as a double.
 */

- (double)altitude{	
	[self compute];
	return altitude;
}
/**
 Calls [self compute] and returns azimuth as a double.
 */


- (double)azimuth{
	[self compute];
	return azimuth;
	
}

/**
 uses RA and DEC to compute the maximum altitude at this particular
 latitude.
 */

- (double)maxAltitude{
	double DECrad, LATrad, HArad;
	DECrad = M_PI * DEC/180.0;
	LATrad = M_PI * latitude/180.0;
	double ALT = sin(DECrad)*sin(LATrad) + cos(DECrad)*cos(LATrad)*cos(HArad);
	ALT = asin(ALT);
	ALT = 180*ALT/M_PI;
	return ALT;
	
}

- (void)dealloc{
	[super dealloc];
}



@end
