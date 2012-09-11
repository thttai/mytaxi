//
//  RTMainViewController.m
//  RunTracker
//
//  Created by Hồng Anh Khoa on 8/16/12.
//  Copyright (c) 2012 Misfit Wearables. All rights reserved.
//

#import "RTMainViewController.h"
#import <AddressBookUI/ABAddressFormatting.h>

@interface RTMainViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end

@implementation RTMainViewController
{
    CLLocationManager *locationManager;
    CGFloat distance;
    BOOL tracking;
    CLLocation *currentLocation;
    NSMutableArray *path;
    MKPolyline *line;
}
@synthesize m_addressLabel;
@synthesize m_notificationLabel;
@synthesize mapView;
@synthesize distanceLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        distance = 0;
        path = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive) 
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setDistanceLabel:nil];
    [self setM_addressLabel:nil];
    [self setM_notificationLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [locationManager startUpdatingLocation];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (currentLocation != nil && tracking)
    {
        distance += [newLocation distanceFromLocation:oldLocation];
        distanceLabel.text = [NSString stringWithFormat:@"%.1f m", distance];
        [path addObject:newLocation];
        if (line != nil)
        {
            [self.mapView removeOverlay:line];
        }
        CLLocationCoordinate2D *points = malloc(sizeof(CLLocationCoordinate2D) * [path count]);
        for (int i = 0; i < [path count]; i++)
        {
            points[i] = ((CLLocation *)[path objectAtIndex:i]).coordinate;
        }
        line = [MKPolyline polylineWithCoordinates:points count:[path count]];
        [self.mapView addOverlay:line];
        free(points);
    }
    currentLocation = newLocation;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:line];
    lineView.fillColor = [UIColor redColor];
    lineView.strokeColor = [UIColor redColor];
    lineView.lineWidth = 3;
    
    return lineView;
}

- (void)applicationWillResignActive
{
    if (!tracking) 
    {
        [locationManager stopUpdatingLocation];
    }
}

- (void)applicationDidBecomeActive
{
    [locationManager startUpdatingLocation];
}

- (IBAction)start:(UIButton *)sender 
{
//    if (tracking) 
//    {
//        tracking = NO;
//        [sender setTitle:@"Start" forState:UIControlStateNormal];
//    }
//    else
//    {
//        tracking = YES;
//        [sender setTitle:@"Stop" forState:UIControlStateNormal];
//    }
}

- (IBAction)FindLocation:(id)sender {
//    BOOL isShowLocation = self.mapView.showsUserLocation;
//    MKUserLocation * location = self.mapView.userLocation;
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray * placemarks, NSError * error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
//            [self displayError:error];
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
//        [self displayPlacemarks:placemarks];
        if ([placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *dic = placemark.addressDictionary;
            NSLog(@"name %@", placemark.name);
            NSLog(@"locality %@", placemark.locality);
            NSLog(@"country %@", placemark.country);
            NSLog(@"administrativeArea %@", placemark.administrativeArea);
            NSLog(@"areasOfInterest %@", placemark.areasOfInterest);
            NSLog(@"inlandWater %@", placemark.inlandWater);
            NSLog(@"ISOcountryCode %@", placemark.ISOcountryCode);
            NSLog(@"ocean %@", placemark.ocean);
            NSLog(@"postalCode %@", placemark.postalCode);
            NSLog(@"thoroughfare %@", placemark.thoroughfare);
            NSLog(@"subThoroughfare %@", placemark.subThoroughfare);
            NSLog(@"subLocality %@", placemark.subLocality);
            NSLog(@"subAdministrativeArea %@", placemark.subAdministrativeArea);
            NSLog(@"addressDictionary %@", placemark.addressDictionary);
            
            // Add a More Info button to the annotation's view.
            NSString *addLine = [[dic valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            [self.m_addressLabel setText:addLine];
        }
    } ];
}
@end
