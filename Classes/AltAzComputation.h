//
//  AltAzComputation.h
//  Transient Events
//
//  Created by Bruce E Truax on 10/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Computes altitude and azimuth of an object given RA, DEC and DATE
 
 Inherits from NSObject
 
 RA and DEC are set using either the initWithRA:DEC: initializer or by setting
 the RA and DEC properties.  When altitude and azimuth are accessed they call
 the private compute: method which reads the current date and then computes the
 RA and DEC.  The maxAltitude method returns the maximumAltitude that a particular
 object will attain at the current longitude and latitude.
 
 NOTE:  Longitude and latitude are read from userDefaults at the time the object 
 is created. 
 */


@interface AltAzComputation : NSObject {
	NSUserDefaults	*userDefaults;
	double			RA;
	double			DEC;
	double			altitude;
	double			azimuth;
	double			longitude;
	double			latitude;
	NSDate			*J2000EpochDate;
}

@property (nonatomic, retain) 	NSDate	*J2000EpochDate; //!< UTDate referenced to noon on Jan 1 2000
@property (assign)				double			RA; //!< Right Ascension - required input value
@property (assign)				double			DEC; //!< Declination - required input value
@property (readonly)			double			altitude; //!< result value
@property (readonly)			double			azimuth; //!< result value

- (id)init; //!< Default initializer
- (id)initWithRA:(double)rightAscension DEC:(double)declination; //!< convenience initializer allowing setting of RA and DEC
- (double)maxAltitude; //!< Computes the maximum altitude of object

@end
