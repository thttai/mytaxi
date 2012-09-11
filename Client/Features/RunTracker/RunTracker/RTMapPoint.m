//
//  RTMapPoint.m
//  RunTracker
//
//  Created by Tai Truong on 9/11/12.
//  Copyright (c) 2012 Misfit Wearables. All rights reserved.
//

#import "RTMapPoint.h"

@implementation RTMapPoint

@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init]) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
    }
    
    return self;
}

- (NSString *)title
{
    if ([_name isKindOfClass:[NSNull class]]) {
        return @"Unknow charge";
    }
    return _name;
}

- (NSString *)subtitle
{
    return _address;
}

@end
