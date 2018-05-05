/**
 * Localytics
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import <CoreLocation/CoreLocation.h>

@interface ComLocalyticsModule : TiModule <CLLocationManagerDelegate>
{
  KrollCallback *_monitoringCallback;
  CLLocationManager *_beaconLocationManager;
  NSMutableDictionary<NSString *, CLBeacon *> *_beaconProximities;
}

@end
