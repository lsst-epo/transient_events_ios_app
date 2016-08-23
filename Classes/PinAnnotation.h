//
//  PinAnnotation.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/3/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/**
 @brief Object used to create an annotated pin for a Map View
 
 This object implements the MKAnnotation protocol to create an
 object which can be used as a pin on a map view.
 
 This object is used to creat the Red pin which shows the current
 coordinate location on the map.
 
 */

@interface PinAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
} 
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; //!< Coordinates in CLLocationCoordinate2D format
@property (nonatomic, retain) NSString *title; //!< Title to display on pin - typically longitude and latitude
@property (nonatomic, retain) NSString *subtitle; //!< Subtitle to display on pin - typically altitude
-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
//- (NSString *)subtitle;
//- (NSString *)title;



@end
