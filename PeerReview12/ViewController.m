//
//  ViewController.m
//  PeerReview12
//
//  Created by Ananta Shahane on 23/08/17.
//  Copyright © 2017 Ananta Shahane. All rights reserved.
//

#import "ViewController.h"
#import "MapKit/MapKit.h"

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *TrackSwitch;
@property (weak, nonatomic) IBOutlet UILabel *LocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *StatusLabel;
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UIButton *CheckStatus;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *currentAnnotation;
@property (strong, nonatomic) MKPointAnnotation *Inspire;
@property (strong, nonatomic) CLCircularRegion *geoRegion;
@property (assign, nonatomic) BOOL MapIsMoving;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
    [self setupLocationManager];
    [self addCurrentAnnotation];
    [self checkPermissions];
    [self setupInsipre];
    self.MapIsMoving = NO;
    [self InitialiseGeoRegion];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupInsipre
{
    self.Inspire = [[MKPointAnnotation alloc] init];
    self.Inspire.coordinate = CLLocationCoordinate2DMake(21.153397, 79.078544);
    self.Inspire.title = @"iNSPiRE";
    [self.MapView addAnnotation:self.Inspire];
}

-(void) setupUI
{
    self.TrackSwitch.enabled = NO;
    self.StatusLabel.text =@"";
    self.LocationLabel.text = @"";
    self.CheckStatus.enabled = NO;
}

-(void) setupLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 3;
    
    CLLocationCoordinate2D noLocation;
    noLocation.latitude = 23;
    noLocation.longitude = 73;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:region];
    [self.MapView setRegion:adjustedRegion animated:YES];
}

-(void) checkPermissions
{
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == YES)
    {
        CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
        if(currentStatus == kCLAuthorizationStatusAuthorizedAlways || currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            self.TrackSwitch.enabled = YES;
        }
        else
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    else
    {
        self.StatusLabel.text = @"GPS not supported";
    }
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    if(currentStatus == kCLAuthorizationStatusAuthorizedAlways || currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        self.TrackSwitch.enabled = YES;
    }
}

-(void) InitialiseGeoRegion
{
    self.geoRegion = [[CLCircularRegion alloc] initWithCenter:self.Inspire.coordinate radius:10 identifier:@"iNSPiRE"];
}

- (IBAction)SwitchClicked:(id)sender {
    if([self.TrackSwitch isOn])
    {
        self.MapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
        self.CheckStatus.enabled = YES;
        [self.locationManager startMonitoringForRegion:self.geoRegion];

    }
    else
    {
        self.MapView.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
        self.CheckStatus.enabled = NO;
        [self.locationManager stopMonitoringForRegion:self.geoRegion];
    }
}

-(void) addCurrentAnnotation
{
    self.currentAnnotation = [[MKPointAnnotation alloc] init];
    self.currentAnnotation.coordinate = CLLocationCoordinate2DMake(23, 73);
    self.currentAnnotation.title = @"My Location";
}

-(void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    self.MapIsMoving = YES;
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.MapIsMoving = NO;
}

-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *note;
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"iNSPiRE";
    note.alertBody = @"Get iPhone 6s for Rs 19,060 for students.";
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
}

-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UILocalNotification *note;
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"iNSPiRE";
    note.alertBody = @"See you later.";
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.currentAnnotation.coordinate = locations.lastObject.coordinate;
    if(!self.MapIsMoving)
    {
        [self centerMap:self.currentAnnotation];
    }
}

-(void) centerMap: (MKPointAnnotation * ) location
{
    [self.MapView setCenterCoordinate:location.coordinate];
}

- (IBAction)CheckStatusClicked:(id)sender
{
    [self.locationManager requestStateForRegion:self.geoRegion];
}

-(void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region
{
    switch (state) {
        case CLRegionStateUnknown:
            self.StatusLabel.text = @"Unknown";
            break;
        case CLRegionStateInside:
            self.StatusLabel.text = @"In the zone";
            self.LocationLabel.text = @"Welcome to iNSPiRE, iPad Pro 2017 now available.";
            break;
        case CLRegionStateOutside:
            self.StatusLabel.text = @"Away";
            self.LocationLabel.text = @"See you later.";
            break;
        default:
            break;
    }
}

@end
