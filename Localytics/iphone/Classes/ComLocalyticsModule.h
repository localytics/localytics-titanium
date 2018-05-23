/**
 * Localytics
 *
 * Created by Localytics
 * Copyright (c) 2015-present Localytics. All rights reserved.
 */

#import "TiModule.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComLocalyticsModule : TiModule <CLLocationManagerDelegate, UIApplicationDelegate> {
  CLLocationManager *_beaconLocationManager;
  NSMutableDictionary<NSString *, CLBeacon *> *_beaconProximities;
}

- (void)startMonitoring:(id)callback;

- (void)stopMonitoring:(id)unused;

- (NSNumber *)isMonitoring:(__unused _Nullable id)unused;

#pragma mark - SDK Integration

- (void)autoIntegrate:(NSArray<id> *_Nonnull)args;

- (void)integrate:(NSArray<id> *_Nonnull)args;

- (void)openSession:(__unused id)unused;

- (void)closeSession:(__unused id)unused;

- (void)upload:(__unused id)unused;

- (void)pauseDataUploading:(id)value;

#pragma mark - Event Tagging

- (void)tagEvent:(id)args;

#pragma mark - Tag Screen Method

- (void)tagScreen:(id)arg;

#pragma mark - Custom Dimensions

- (void)setCustomDimension:(id)args;

- (NSString *)getCustomDimension:(id)arg;

#pragma mark - Identifiers

- (void)setIdentifier:(id)args;

- (NSString *)getIdentifier:(id)arg;

- (void)setCustomerId:(id)arg;

- (void)setLocation:(id)arg;

#pragma mark - Profile

- (void)setProfileAttribute:(id)args;

- (void)addProfileAttributesToSet:(id)args;

- (void)removeProfileAttributesFromSet:(id)args;

- (void)incrementProfileAttribute:(id)args;

- (void)decrementProfileAttribute:(id)args;

- (void)deleteProfileAttribute:(id)args;

#pragma mark - Push

- (void)setPushToken:(id)arg;

#pragma mark - In-App Message

- (void)triggerInAppMessage:(id)args;

- (void)dismissCurrentInAppMessage:(id)args;

#pragma mark - Developer Options

- (NSNumber *)isLoggingEnabled:(id)arg;

- (void)setLoggingEnabled:(id)arg;

- (NSNumber *)isOptedOut:(id)arg;

- (void)setOptedOut:(id)arg;

- (NSNumber *)isTestModeEnabled:(id)arg;

- (void)setTestModeEnabled:(id)arg;

- (void)setOptions:(id)arg;

- (NSString *)installId;

- (NSString *)libraryVersion;

- (NSString *)appKey;

NS_ASSUME_NONNULL_END

@end
