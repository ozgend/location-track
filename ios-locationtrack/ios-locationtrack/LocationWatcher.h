//
//  LocationHelper.h
//  locationtest
//
//  Created by ozgend on 9/18/13.
//  Copyright (c) 2013 denolk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"

@interface LocationWatcher : NSObject <CLLocationManagerDelegate>

@property (nonatomic,retain) NSTimer *locationUploader ;
@property (nonatomic,retain) CLLocationManager *locationManager ;
@property (nonatomic,retain) CLLocation *lastLocation;

- (void) startListening;
- (void) stopListening;

@end
