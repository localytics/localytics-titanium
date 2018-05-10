/**
 * Localytics
 *
 * Created by Localytics
 * Copyright (c) 2015-present Localytics. All rights reserved.
 */

#import "TiModule.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComLocalyticsModule : TiModule <CLLocationManagerDelegate> {
  KrollCallback *_monitoringCallback;
  CLLocationManager *_beaconLocationManager;
  NSMutableDictionary<NSString *, CLBeacon *> *_beaconProximities;
}

- (void)startMonitoring:(id)callback;

- (void)stopMonitoring:(id)unused;

#pragma mark - SDK Integration

- (void)autoIntegrate:(NSArray<id> *_Nonnull)args;

- (void)integrate:(NSArray<id> *_Nonnull)args;

- (void)openSession:(__unused id)unused;

- (void)closeSession:(__unused id)unused;

- (void)upload:(__unused id)unused;

#pragma mark - Event Tagging

- (void)tagEvent:(id)args;

#pragma mark - Tag Screen Method

- (void)tagScreen:(id)arg;

#pragma mark - Custom Dimensions

- (void)setCustomDimension:(id)args;

- (id)getCustomDimension:(id)arg;

#pragma mark - Identifiers

- (void)setIdentifier:(id)args;

- (id)getIdentifier:(id)arg;

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

- (id)isLoggingEnabled:(id)arg;

- (void)setLoggingEnabled:(id)arg;

- (id)isOptedOut:(id)arg;

- (void)setOptedOut:(id)arg;

- (id)isTestModeEnabled:(id)arg;

- (void)setTestModeEnabled:(id)arg;

- (void)setOptions:(id)arg;

- (id)getInstallId:(id)args;

- (id)getLibraryVersion:(id)args;

- (id)getAppKey:(id)args;

NS_ASSUME_NONNULL_END

@end
