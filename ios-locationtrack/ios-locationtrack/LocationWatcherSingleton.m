//
//  LocationWatcherSingleton.m
//  locationtest
//
//  Created by ozgend on 9/19/13.
//  Copyright (c) 2013 denolk. All rights reserved.
//

#import "LocationWatcherSingleton.h"


@interface LocationWatcherSingleton()
- (BOOL) checkLocationService;
- (void) initializeLocationManager;
- (void) initializeTimer;
- (void) timerTarget;
- (void) sendLocation:(CLLocation *)location;
- (void) displayMessage:(NSString *)text withTitle :(NSString *)title;
@end

@implementation LocationWatcherSingleton
@synthesize lastLocation,locationUploader,locationManager;

static LocationWatcherSingleton* _shared = nil;

+ (LocationWatcherSingleton*)shared {
    @synchronized([LocationWatcherSingleton class]) {
        if (!_shared) {
            _shared=[[self alloc] init];
        }
        return _shared;
    }
    return nil;
}

+ (id) alloc {
    @synchronized([LocationWatcherSingleton class]) {
        NSAssert(_shared == nil, @"Attempted to allocate a second instance of a singleton.");
        _shared = [super alloc];
        return _shared;
    }
    return nil;
}

- (BOOL)checkLocationService{
    if([CLLocationManager locationServicesEnabled] == NO){
        [self displayMessage:@"Location service is disabled" withTitle:@"Error"];
        return NO;
    }
    
    if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized){
        [self displayMessage:@"Location service is not authorized" withTitle:@"Error"];
        return NO;
    }
    
    [self displayMessage:@"Location service is starting" withTitle:@"Info"];
    
    return YES;
}

-(id)init {
    self = [super init];
    if (self != nil) {
        // initialize stuff here
    }   return self;
}

- (void) initializeLocationManager{
    if(locationManager==nil){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        NSLog(@"location manager initialized");
    }
}

- (void)initializeTimer{
    if (locationUploader == nil) {
        locationUploader = [[NSTimer alloc] init];
        locationUploader = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                            target:self
                                                          selector:@selector(timerTarget)
                                                          userInfo:nil
                                                           repeats:YES];
        NSLog(@"location uploader timer initialized");
    }
}

- (void) startListening{
    BOOL status = [self checkLocationService];
    if (status) {
        [self initializeLocationManager];
        
        if (UPLOAD_MODE == USE_TIMER) {
            [self initializeTimer];
        }
        [locationManager startUpdatingLocation];
        NSLog(@"started listening location changes");
    }
}

- (void)stopListening{
    [locationManager stopUpdatingLocation];
    if (UPLOAD_MODE == USE_TIMER) {
        [locationUploader invalidate];
    }
    NSLog(@"stopped listening location changes");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    lastLocation = [locations lastObject];
    NSLog(@"location update: %@ %f %f",lastLocation.timestamp, lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
    
    
    
    if (UPLOAD_MODE == USE_IMMEDIATE) {
        [self sendLocation: lastLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location update failed");
}

- (void)timerTarget{
    [NSThread detachNewThreadSelector:@selector(sendLocation:) toTarget:self withObject:lastLocation];
}

- (void)sendLocation:(CLLocation *)location{
    @autoreleasepool {
        NSLog(@"uploading location");
        @try {
            NSString *serialized = [NSString stringWithFormat:@"{\"device\":\"%@\",\"lat\":\"%f\",\"long\":\"%f\"}",[[UIDevice currentDevice] name],location.coordinate.latitude,location.coordinate.longitude];
            
            NSData *requestData = [NSData dataWithBytes: [serialized UTF8String] length: [serialized length]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: @"http://192.168.6.119:1188/alive"]];
            [request setHTTPMethod: @"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
            [request setHTTPBody: requestData];
            
            NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
            NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
            NSLog(@"upload result: %@",response);
        }
        @catch (NSException* ex) {
            NSLog(@"upload error: %@",ex);
        }
    }
}

- (void)displayMessage:(NSString *)text withTitle :(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil ];
    [alert show];
}

@end
