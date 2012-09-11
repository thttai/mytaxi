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
    else if (currentLocation == nil)
    {
        [self getAddressFromLocation:newLocation];
    }
    
    currentLocation = newLocation;
    [self plotTaxiPosition:newLocation.coordinate];
    
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
}

- (void)getAddressFromLocation:(CLLocation*)location {
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray * placemarks, NSError * error) {
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

-(void)plotTaxiPosition:(CLLocationCoordinate2D)userCoordinate
{
    for (id<MKAnnotation> annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[RTMapPoint class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    CGPoint nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
    CGPoint swPoint = CGPointMake((mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));
    
    //Then transform those point into lat,lng values
    CLLocationCoordinate2D neCoord = [mapView convertPoint:nePoint toCoordinateFromView:mapView];
    CLLocationCoordinate2D swCoord = [mapView convertPoint:swPoint toCoordinateFromView:mapView];
    
    // Loop
    for (int i = 0; i < NUM_TAXI; i++) {
        double latRange = [self randomFloatBetween:neCoord.latitude andBig:swCoord.latitude];
        double longRange = [self randomFloatBetween:neCoord.longitude andBig:swCoord.longitude];
        
        // Add new waypoint to map
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latRange, longRange);
        NSString *taxiType = @"4 Seats";
        if(i >= NUM_TAXI_4SEATS)
            taxiType = @"7 Seats";
        
        RTMapPoint *mapPoint = [[RTMapPoint alloc] initWithName:taxiType address:@"" coordinate:location];
        [mapView addAnnotation:mapPoint];
        
    }
}

-(double)randomFloatBetween:(double)smallNumber andBig:(double)bigNumber {
    double diff = bigNumber - smallNumber;
    return (((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier;
    if ([annotation isKindOfClass:[RTMapPoint class]]) {
        UIImage *img;
        if([((RTMapPoint*)annotation).name isEqualToString:@"7 Seats"])
        {
            identifier = @"7Seats";
            img = [UIImage imageNamed:@"car2.png"];
        } else {
            identifier = @"4Seats";
            img = [UIImage imageNamed:@"car.png"];
        }
        
        MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(pinAnnotation == nil)
        {
            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else
        {
            pinAnnotation.annotation = annotation;
        }
        
        pinAnnotation.enabled = YES;
        pinAnnotation.canShowCallout = YES;
        pinAnnotation.image = img;
        return pinAnnotation;
    }
    
    return nil;
}

@end
