//
//  PinAnnotation.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/3/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "PinAnnotation.h"


@implementation PinAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}
@end