//
//  RTMainViewController.h
//  RunTracker
//
//  Created by Hồng Anh Khoa on 8/16/12.
//  Copyright (c) 2012 Misfit Wearables. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "RTMapPoint.h"

#define METERS_PER_MILE 100
#define NUM_TAXI_7SEATS 3
#define NUM_TAXI_4SEATS 4
#define NUM_TAXI NUM_TAXI_7SEATS + NUM_TAXI_4SEATS

@interface RTMainViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *m_addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_notificationLabel;
- (IBAction)FindLocation:(id)sender;

@end
