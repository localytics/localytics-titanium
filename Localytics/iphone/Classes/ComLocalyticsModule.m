/**
 * Localytics
 *
 * Created by Localytics
 * Copyright (c) 2015-present Localytics. All rights reserved.
 */

#import "ComLocalyticsModule.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import <Localytics/Localytics.h>

@implementation ComLocalyticsModule

MAKE_SYSTEM_PROP(PROFILE_SCOPE_APP, 0);
MAKE_SYSTEM_PROP(PROFILE_SCOPE_ORG, 1);

#pragma mark Internal

- (id)moduleGUID
{
  return @"e774230a-3345-4c23-8f61-98569209cfd8";
}

- (NSString *)moduleId
{
  return @"com.localytics";
}

#pragma mark Cleanup

- (void)dealloc
{
  RELEASE_TO_NIL(_beaconLocationManager);
  RELEASE_TO_NIL(_monitoringCallback);
  RELEASE_TO_NIL(_beaconProximities);

  [super dealloc];
}

#pragma Public APIs

- (NSString *)plistAppKey:(id)arg
{
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LocalyticsAppKey"];
}

#pragma mark - Beacons

- (void)startMonitoring:(id)value
{
  if (_beaconLocationManager != nil) {
    TiExceptionThrowWithNameAndReason(@"Beacon error", @"Attempted to start monitoring that already started", @"The location manager or monitoring callback have already been set. Call \"stopMonitoring()\" before attempting to start monitoring again", CODELOCATION);
    return;
  }

  // Cleanup
  RELEASE_TO_NIL(_monitoringCallback);
  RELEASE_TO_NIL(_beaconLocationManager);
  RELEASE_TO_NIL(_beaconProximities);

  // Initialize
  _beaconLocationManager = [[CLLocationManager alloc] init];
  [_beaconLocationManager setDelegate:self];
  _beaconProximities = [[NSMutableDictionary alloc] init];
  CLBeaconRegion *_beaconRegion = nil;

  // Handle both dictionary and single arg for backwards compatibility
  if ([value isKindOfClass:[NSDictionary class]]) {
    NSString *uuid = [value objectForKey:@"uuid"];
    NSString *identifier = [value objectForKey:@"identifier"];
    _monitoringCallback = [[value objectForKey:@"callback"] retain];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                       identifier:identifier];
  } else {
    NSString *ESTIMOTE_UUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    NSString *ESTIMATE_IDENTIFIER = @"Estimote Beacons";

    DebugLog(@"[WARN] No beacon UUID and identifier provided. Using default UUID and identifier:\n- UUID: %@\n - Identifier: %@", ESTIMOTE_UUID, ESTIMATE_IDENTIFIER);
    DebugLog(@"[WARN] Call this method with an object parameter, e.g. { uuid: 'BEACON_UUID', identifier: 'BEACON_IDENTIFIER'} for a more flexible solution");

    ENSURE_SINGLE_ARG(value, KrollCallback);
    _monitoringCallback = [value retain];

    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:ESTIMOTE_UUID]
                                                       identifier:ESTIMATE_IDENTIFIER];
  }

  [_beaconLocationManager startRangingBeaconsInRegion:_beaconRegion];
}

- (void)stopMonitoring:(id)unused
{
  NSSet<CLRegion *> *rangedRegions = [_beaconLocationManager rangedRegions];

  for (CLRegion *region in rangedRegions) {
    [_beaconLocationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
  }

  // Clean up
  [_beaconLocationManager setDelegate:nil];
  RELEASE_TO_NIL(_beaconLocationManager);
  RELEASE_TO_NIL(_monitoringCallback);
}

#pragma mark - SDK Integration

/** ---------------------------------------------------------------------------------------
 * @name Localytics SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

- (void)autoIntegrate:(NSArray<id> *_Nonnull)args
{
  ENSURE_ARG_COUNT(args, 2)

  NSString *appKey = [args objectAtIndex:0];
  NSDictionary *options = [args objectAtIndex:1];

  if (appKey == nil) {
    DebugLog(@"[WARN] Passing the Localytics app-key via the Info.plist has been deprecated for security reasons.");
    DebugLog(@"[WARN] Please pass the app-key as the first argument of this method instead.");

    appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LocalyticsAppKey"];
  }
  if (appKey) {
    NSDictionary *launchOptions = [[TiApp app] launchOptions];
    [Localytics autoIntegrate:appKey withLocalyticsOptions:options launchOptions:launchOptions];
  }
}

- (void)integrate:(NSArray<id> *_Nonnull)args
{
  NSString *appKey = [args objectAtIndex:0];
  NSDictionary *options = [args objectAtIndex:1];

  if (appKey == nil) {
    DebugLog(@"[WARN] Passing the Localytics app-key via the Info.plist has been deprecated for security reasons.");
    DebugLog(@"[WARN] Please pass the app-key as the first argument of this method instead.");

    appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LocalyticsAppKey"];
  }
  if (appKey) {
    [Localytics integrate:appKey withLocalyticsOptions:options];
  }
}

- (void)openSession:(id)unused
{
  [Localytics openSession];
}

- (void)closeSession:(id)unused
{
  [Localytics closeSession];
}

- (void)upload:(id)unused
{
  [Localytics upload];
}

- (void)pauseDataUploading:(id)value
{
  [Localytics pauseDataUploading:[TiUtils boolValue:value]];
}

- (void)setPrivacyOptedOut:(id)value
{
  [Localytics setPrivacyOptedOut:[TiUtils boolValue:value]];
}

- (void)setCustomerIdWithPrivacyOptedOut:(id)args
{
  NSString *cid = [args objectAtIndex:0];
  BOOL optedOut = [TiUtils boolValue:[args objectAtIndex:1]];

  [Localytics setCustomerId:cid privacyOptedOut:optedOut];
}

#pragma mark - Event Tagging

/** ---------------------------------------------------------------------------------------
 * @name Event Tagging
 *  ---------------------------------------------------------------------------------------
 */

- (void)tagEvent:(id)args
{
  NSUInteger count = [args count];

  NSString *eventName = nil;
  NSDictionary *attributes = nil;
  NSNumber *customerValueIncrease = nil;

  if (count > 0) {
    ENSURE_TYPE(args[0], NSString);
    eventName = [TiUtils stringValue:args[0]];
  }

  if (count > 1) {
    ENSURE_TYPE(args[1], NSDictionary);
    attributes = (NSDictionary *)args[1];
  }

  if (count > 2) {
    ENSURE_TYPE(args[2], NSNumber);
    customerValueIncrease = (NSNumber *)args[2];
  }

  [Localytics tagEvent:eventName attributes:attributes customerValueIncrease:customerValueIncrease];
}

#pragma mark - Tag Screen Method

- (void)tagScreen:(id)arg
{
  ENSURE_SINGLE_ARG(arg, NSString);
  [Localytics tagScreen:arg];
}

#pragma mark - Custom Dimensions

/** ---------------------------------------------------------------------------------------
 * @name Custom Dimensions
 *  ---------------------------------------------------------------------------------------
 */

- (void)setCustomDimension:(id)args
{
  ENSURE_ARG_COUNT(args, 2);
  NSUInteger dimension = [TiUtils intValue:args[0]];
  ENSURE_TYPE(args[1], NSString);
  NSString *value = [TiUtils stringValue:args[1]];

  [Localytics setValue:value forCustomDimension:dimension];
}

- (NSString *)getCustomDimension:(id)arg
{
  NSUInteger dimension = [TiUtils intValue:arg];

  return [Localytics valueForCustomDimension:dimension];
}

#pragma mark - Identifiers

/** ---------------------------------------------------------------------------------------
 * @name Identifiers
 *  ---------------------------------------------------------------------------------------
 */

- (void)setIdentifier:(id)args
{
  ENSURE_ARG_COUNT(args, 2);
  ENSURE_TYPE(args[0], NSString);
  NSString *identifier = [TiUtils stringValue:args[0]];
  ENSURE_TYPE(args[1], NSString);
  NSString *value = [TiUtils stringValue:args[1]];

  [Localytics setValue:value forIdentifier:identifier];
}

- (NSString *)getIdentifier:(id)arg
{
  ENSURE_SINGLE_ARG(arg, NSString);
  return [Localytics valueForIdentifier:arg];
}

// Pass in a string to set the id or pass in a nil to clear the id
- (void)setCustomerId:(id)arg
{
  NSString *customerId = nil;

  if (arg != nil) {
    ENSURE_TYPE(arg, NSString);
    customerId = arg;
  }

  [Localytics setCustomerId:customerId];
}

// setLocation takes in a dictionary with two keys "latitude" & "longitude"
// which are both expected to be doubles
- (void)setLocation:(id)arg
{
  ENSURE_SINGLE_ARG(arg, NSDictionary);
  CLLocationCoordinate2D location;
  location.latitude = [TiUtils doubleValue:@"latitude" properties:arg];
  location.longitude = [TiUtils doubleValue:@"longitude" properties:arg];

  [Localytics setLocation:location];
}

#pragma mark - Profile

/** ---------------------------------------------------------------------------------------
 * @name Profile
 *  ---------------------------------------------------------------------------------------
 */

- (void)setProfileAttribute:(id)args
{
  NSUInteger count = [args count];

  NSObject<NSCopying> *value = nil;
  NSString *attribute = nil;
  NSUInteger scope = LLProfileScopeApplication;

  if (count > 1) {
    ENSURE_TYPE(args[0], NSString);
    attribute = [TiUtils stringValue:args[0]];

    value = args[1];
  }

  if (count > 2) {
    scope = [TiUtils intValue:args[2]];
  }

  [Localytics setValue:value forProfileAttribute:attribute withScope:scope];
}

- (void)addProfileAttributesToSet:(id)args
{
  NSUInteger count = [args count];

  NSArray *values = nil;
  NSString *attribute = nil;
  NSUInteger scope = LLProfileScopeApplication;

  if (count > 1) {
    ENSURE_TYPE(args[0], NSString);
    attribute = [TiUtils stringValue:args[0]];

    ENSURE_TYPE(args[1], NSArray);
    values = (NSArray *)args[1];
  }

  if (count > 2) {
    scope = [TiUtils intValue:args[2]];
  }

  [Localytics addValues:values toSetForProfileAttribute:attribute withScope:scope];
}

- (void)removeProfileAttributesFromSet:(id)args
{
  NSUInteger count = [args count];

  NSArray *values = nil;
  NSString *attribute = nil;
  NSUInteger scope = LLProfileScopeApplication;

  if (count > 1) {
    ENSURE_TYPE(args[0], NSString);
    attribute = [TiUtils stringValue:args[0]];

    ENSURE_TYPE(args[1], NSArray);
    values = (NSArray *)args[1];
  }

  if (count > 2) {
    scope = [TiUtils intValue:args[2]];
  }

  [Localytics removeValues:values fromSetForProfileAttribute:attribute withScope:scope];
}

- (void)incrementProfileAttribute:(id)args
{
  NSUInteger count = [args count];

  NSInteger value = 0;
  NSString *attribute = nil;
  NSUInteger scope = LLProfileScopeApplication;

  if (count > 1) {
    ENSURE_TYPE(args[0], NSString);
    attribute = [TiUtils stringValue:args[0]];

    value = [TiUtils intValue:args[1]];
  }

  if (count > 2) {
    scope = [TiUtils intValue:args[2]];
  }

  [Localytics incrementValueBy:value forProfileAttribute:attribute withScope:scope];
}

- (void)decrementProfileAttribute:(id)args
{
  NSUInteger count = [args count];

  NSInteger value = 0;
  NSString *attribute = nil;
  NSUInteger scope = LLProfileScopeApplication;

  if (count > 1) {
    ENSURE_TYPE(args[0], NSString);
    attribute = [TiUtils stringValue:args[0]];

    value = [TiUtils intValue:args[1]];
  }

  if (count > 2) {
    scope = [TiUtils intValue:args[2]];
  }

  [Localytics decrementValueBy:value forProfileAttribute:attribute withScope:scope];
}

- (void)deleteProfileAttribute:(id)args
{
  NSUInteger count = [args count];

  NSString *attribute = nil;
  NSUInteger scope = LLProfileScopeApplication;

  if (count > 0) {
    ENSURE_TYPE(args[0], NSString);
    attribute = [TiUtils stringValue:args[0]];
  }

  if (count > 1) {
    scope = [TiUtils intValue:args[1]];
  }

  [Localytics deleteProfileAttribute:attribute withScope:scope];
}

#pragma mark - Push

/** ---------------------------------------------------------------------------------------
 * @name Push
 *  ---------------------------------------------------------------------------------------
 */

// Titanium handles the device token as a string (hex encoded) so we take it in as a string and convert it to NSData
- (void)setPushToken:(id)arg
{
  ENSURE_SINGLE_ARG(arg, NSString)
  NSString *titaniumPushToken = arg;

  NSMutableData *pushToken = [[NSMutableData alloc] init];
  unsigned char whole_byte;
  char byte_chars[3] = { '\0', '\0', '\0' };
  for (int i = 0; i < [titaniumPushToken length] / 2; i++) {
    byte_chars[0] = [titaniumPushToken characterAtIndex:i * 2];
    byte_chars[1] = [titaniumPushToken characterAtIndex:i * 2 + 1];
    whole_byte = strtol(byte_chars, NULL, 16);
    [pushToken appendBytes:&whole_byte length:1];
  }

  [Localytics setPushToken:pushToken];
}

#pragma mark - In-App Message

/** ---------------------------------------------------------------------------------------
 * @name In-App Message
 *  ---------------------------------------------------------------------------------------
 */

- (void)triggerInAppMessage:(id)args
{
  NSUInteger count = [args count];

  NSString *triggerName = nil;
  NSDictionary *attributes = nil;

  if (count > 0) {
    ENSURE_TYPE(args[0], NSString);
    triggerName = [TiUtils stringValue:args[0]];
  }

  if (count > 1) {
    ENSURE_TYPE(args[1], NSDictionary);
    attributes = (NSDictionary *)args[1];
  }

  [Localytics triggerInAppMessage:triggerName withAttributes:attributes];
}

- (void)dismissCurrentInAppMessage:(id)args
{
  [Localytics dismissCurrentInAppMessage];
}

#pragma mark - Developer Options

/** ---------------------------------------------------------------------------------------
 * @name Developer Options
 *  ---------------------------------------------------------------------------------------
 */

- (NSNumber *)isLoggingEnabled:(id)arg
{
  return NUMBOOL([Localytics isLoggingEnabled]);
}
- (void)setLoggingEnabled:(id)arg
{
  [Localytics setLoggingEnabled:[TiUtils boolValue:arg]];
}

- (NSNumber *)isOptedOut:(id)arg
{
  return @([Localytics isOptedOut]);
}

- (void)setOptedOut:(id)arg
{
  [Localytics setOptedOut:[TiUtils boolValue:arg]];
}

- (NSNumber *)isTestModeEnabled:(id)arg
{
  return @([Localytics isTestModeEnabled]);
}

- (void)setTestModeEnabled:(id)arg
{
  [Localytics setTestModeEnabled:[TiUtils boolValue:arg]];
}

- (void)setOptions:(id)arg
{
  ENSURE_ARG_COUNT(arg, 1);
  ENSURE_TYPE(arg[0], NSDictionary);
  [Localytics setOptions:(NSDictionary *)arg[0]];
}

- (NSString *)installId
{
  return [Localytics installId];
}

- (NSString *)libraryVersion
{
  return [Localytics libraryVersion];
}

- (NSString *)appKey
{
  return [Localytics appKey];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  DebugLog(@"[DEBUG] Entered beacon region: %@", region.identifier);
  [_beaconLocationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  DebugLog(@"[DEBUG] Exited beacon region: %@", region.identifier);
  [_beaconLocationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  DebugLog(@"[DEBUG] Started monitoring beacon region: %@", region.identifier);
  [_beaconLocationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
  if (state == CLRegionStateInside) {
    DebugLog(@"[DEBUG] Already inside region %@, starting ranging.", region.identifier);
    [_beaconLocationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
  }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
  DebugLog(@"[DEBUG] Monitoring beacon region %@, failed!", region.identifier);
  DebugLog(@"[ERROR] %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
  DebugLog(@"[DEBUG] %i beacons in range", beacons.count);

  for (CLBeacon *beacon in beacons) {
    DebugLog(@"[DEUG] Beacon = %@, proximity = %lu", beacon.proximityUUID.UUIDString, beacon.proximity)
  }

  [self reportCrossings:beacons inRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
  DebugLog(@"[DEBUG] Ranging beacon region %@, failed!", region.identifier);
  DebugLog(@"[ERROR] %@", error.localizedDescription);
}

#pragma mark Utilities

- (void)reportCrossings:(NSArray<CLBeacon *> *)beacons inRegion:(CLRegion *)region
{
  for (CLBeacon *beacon in beacons) {
    NSString *identifier = [NSString stringWithFormat:@"%@/%@/%@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor];

    CLBeacon *previous = [_beaconProximities objectForKey:identifier];

    if (previous != nil) {
      if (previous.proximity != beacon.proximity) {
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:[self detailsForBeacon:beacon]];
        [event setObject:region.identifier forKey:@"identifier"];
        [event setObject:[self decodeProximity:previous.proximity] forKey:@"fromProximity"];

        [_monitoringCallback call:@[ event ] thisObject:self];
      }
    } else {
      NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:[self detailsForBeacon:beacon]];
      [event setObject:region.identifier forKey:@"identifier"];
      [_monitoringCallback call:@[ event ] thisObject:self];
    }

    [_beaconProximities setObject:beacon forKey:identifier];
  }
}

- (NSDictionary *)detailsForBeacon:(CLBeacon *)beacon
{

  NSString *proximity = [self decodeProximity:beacon.proximity];

  NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    beacon.proximityUUID.UUIDString, @"uuid",
                                                [NSString stringWithFormat:@"%@", beacon.major], @"major",
                                                [NSString stringWithFormat:@"%@", beacon.minor], @"minor",
                                                proximity, @"proximity",
                                                [NSString stringWithFormat:@"%f", beacon.accuracy], @"accuracy",
                                                [NSString stringWithFormat:@"%ld", (long)beacon.rssi], @"rssi",
                                                nil];

  return [details autorelease];
}

- (NSString *)decodeProximity:(int)proximity
{
  switch (proximity) {
  case CLProximityNear:
    return @"near";
    break;
  case CLProximityImmediate:
    return @"immediate";
    break;
  case CLProximityFar:
    return @"far";
    break;
  case CLProximityUnknown:
  default:
    return @"unknown";
    break;
  }
}

@end
