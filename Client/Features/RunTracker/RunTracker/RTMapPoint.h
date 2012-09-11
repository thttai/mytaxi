//
//  RTMapPoint.h
//  RunTracker
//
//  Created by Tai Truong on 9/11/12.
//  Copyright (c) 2012 Misfit Wearables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RTMapPoint : NSObject <MKAnnotation>

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;

@end
