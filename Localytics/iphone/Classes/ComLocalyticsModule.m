/**
 * Localytics
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "ComLocalyticsModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
    
#import <Localytics/Localytics.h>

@implementation ComLocalyticsModule

MAKE_SYSTEM_PROP(PROFILE_SCOPE_APP, 0);
MAKE_SYSTEM_PROP(PROFILE_SCOPE_ORG, 1);
/*MAKE_SYSTEM_PROP(DISMISS_BUTTON_LOCATION_LEFT, 0);
MAKE_SYSTEM_PROP(DISMISS_BUTTON_LOCATION_RIGHT, 1);*/

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID
{
	return @"e774230a-3345-4c23-8f61-98569209cfd8";
}

// this is generated for your module, please do not change it
- (NSString*)moduleId
{
	return @"com.localytics";
}

#pragma mark Lifecycle

- (void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
}

- (void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

- (void)applicationDidBecomeActive:(id)arg{}
- (void)applicationWillResign:(id)arg{}

#pragma mark Cleanup

- (void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

- (void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

- (id)plistAppKey:(id)arg{
    return [[NSBundle mainBundle]objectForInfoDictionaryKey:@"LocalyticsAppKey"];
}

#pragma mark - SDK Integration
/** ---------------------------------------------------------------------------------------
 * @name Localytics SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

- (void)autoIntegrate:(NSArray<id> * _Nonnull)args
{
    ENSURE_ARG_COUNT(args, 2)
    
    NSString *appKey = [args objectAtIndex: 0];
    NSDictionary *options = [args objectAtIndex: 1];
    
    if (appKey == nil){
        appKey = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"LocalyticsAppKey"];
    }
    if (appKey) {
        NSDictionary *launchOptions = [[TiApp app] launchOptions];
        [Localytics autoIntegrate:appKey withLocalyticsOptions:options launchOptions:launchOptions];
    }
}

- (void)integrate:(NSArray<id> * _Nonnull)args
{
    NSString *appKey = [args objectAtIndex: 0];
    NSDictionary *options = [args objectAtIndex: 1];
    
    if (appKey == nil){
        appKey = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"LocalyticsAppKey"];
    }
    if (appKey){
        [Localytics integrate:appKey withLocalyticsOptions:options];
    }
}

- (void)openSession:(__unused id)unused
{
    [Localytics openSession];
}
- (void)closeSession:(__unused id)unused
{
    [Localytics closeSession];
    
}

- (void)upload:(__unused id)unused
{
    [Localytics upload];
    
}

#pragma mark - Event Tagging
/** ---------------------------------------------------------------------------------------
 * @name Event Tagging
 *  ---------------------------------------------------------------------------------------
 */

- (void)tagEvent:(id)args{
    NSUInteger count = [args count];
    
    NSString *eventName = nil;
    NSDictionary *attributes = nil;
    NSNumber *customerValueIncrease = nil;
    
    if (count > 0){
        ENSURE_TYPE(args[0], NSString);
        eventName = [TiUtils stringValue:args[0]];
    }
    
    if (count > 1){
        ENSURE_TYPE(args[1], NSDictionary);
        attributes = (NSDictionary *)args[1];
    }
    
    if (count > 2){
        ENSURE_TYPE(args[2], NSNumber);
        customerValueIncrease = (NSNumber *)args[2];
    }
    
    [Localytics tagEvent:eventName attributes:attributes customerValueIncrease:customerValueIncrease];
}

#pragma mark - Tag Screen Method

- (void)tagScreen:(id)arg{
    ENSURE_SINGLE_ARG(arg, NSString);
    [Localytics tagScreen:arg];
}

#pragma mark - Custom Dimensions
/** ---------------------------------------------------------------------------------------
 * @name Custom Dimensions
 *  ---------------------------------------------------------------------------------------
 */

- (void)setCustomDimension:(id)args{
    ENSURE_ARG_COUNT(args, 2);
    NSUInteger dimension = [TiUtils intValue:args[0]];
    ENSURE_TYPE(args[1], NSString);
    NSString *value = [TiUtils stringValue:args[1]];
    
    [Localytics setValue:value forCustomDimension:dimension];
}
- (id)getCustomDimension:(id)arg{
    NSUInteger dimension = [TiUtils intValue:arg];
    
    return [Localytics valueForCustomDimension:dimension];
}

#pragma mark - Identifiers
/** ---------------------------------------------------------------------------------------
 * @name Identifiers
 *  ---------------------------------------------------------------------------------------
 */

- (void)setIdentifier:(id)args{
    ENSURE_ARG_COUNT(args, 2);
    ENSURE_TYPE(args[0], NSString);
    NSString *identifier = [TiUtils stringValue:args[0]];
    ENSURE_TYPE(args[1], NSString);
    NSString *value = [TiUtils stringValue:args[1]];
    
    [Localytics setValue:value forIdentifier:identifier];
}
- (id)getIdentifier:(id)arg{
    ENSURE_SINGLE_ARG(arg, NSString);
    return [Localytics valueForIdentifier:arg];
}

// Pass in a string to set the id or pass in a nil to clear the id
- (void)setCustomerId:(id)arg{
    NSString *customerId = nil;
    
    if (arg != nil){
        ENSURE_TYPE(arg, NSString);
        customerId = arg;
    }

    [Localytics setCustomerId:customerId];
}

// setLocation takes in a dictionary with two keys "latitude" & "longitude"
// which are both expected to be doubles
//- (void)setLocation:(id)arg{
//    ENSURE_SINGLE_ARG(arg, NSDictionary);
//    CLLocationCoordinate2D location;
//    location.latitude = [TiUtils doubleValue:@"latitude" properties:arg];
//    location.longitude = [TiUtils doubleValue:@"longitude" properties:arg];
//    
//    [Localytics setLocation:location];
//}

#pragma mark - Profile
/** ---------------------------------------------------------------------------------------
 * @name Profile
 *  ---------------------------------------------------------------------------------------
 */

- (void)setProfileAttribute:(id)args{
    NSUInteger count = [args count];
    
    NSObject<NSCopying> *value = nil;
    NSString *attribute = nil;
    NSUInteger scope = LLProfileScopeApplication;
    
    if (count > 1){
        ENSURE_TYPE(args[0], NSString);
        attribute = [TiUtils stringValue:args[0]];
        
        value = args[1];
    }
    
    if (count > 2){
        scope = [TiUtils intValue:args[2]];
    }
    
    [Localytics setValue:value forProfileAttribute:attribute withScope:scope];
}

- (void)addProfileAttributesToSet:(id)args{
    NSUInteger count = [args count];
    
    NSArray *values = nil;
    NSString *attribute = nil;
    NSUInteger scope = LLProfileScopeApplication;
    
    if (count > 1){
        ENSURE_TYPE(args[0], NSString);
        attribute = [TiUtils stringValue:args[0]];
        
        ENSURE_TYPE(args[1], NSArray);
        values = (NSArray *)args[1];
    }
    
    if (count > 2){
        scope = [TiUtils intValue:args[2]];
    }
    
    [Localytics addValues:values toSetForProfileAttribute:attribute withScope:scope];
}

- (void)removeProfileAttributesFromSet:(id)args{
    NSUInteger count = [args count];
    
    NSArray *values = nil;
    NSString *attribute = nil;
    NSUInteger scope = LLProfileScopeApplication;
    
    if (count > 1){
        ENSURE_TYPE(args[0], NSString);
        attribute = [TiUtils stringValue:args[0]];

        ENSURE_TYPE(args[1], NSArray);
        values = (NSArray *)args[1];
    }
    
    if (count > 2){
        scope = [TiUtils intValue:args[2]];
    }
    
    [Localytics removeValues:values fromSetForProfileAttribute:attribute withScope:scope];
}

- (void)incrementProfileAttribute:(id)args{
    NSUInteger count = [args count];
    
    NSInteger value = 0;
    NSString *attribute = nil;
    NSUInteger scope = LLProfileScopeApplication;
    
    if (count > 1){
        ENSURE_TYPE(args[0], NSString);
        attribute = [TiUtils stringValue:args[0]];

        value = [TiUtils intValue:args[1]];
    }
    
    if (count > 2){
        scope = [TiUtils intValue:args[2]];
    }
    
    [Localytics incrementValueBy:value forProfileAttribute:attribute withScope:scope];
}

- (void)decrementProfileAttribute:(id)args{
    NSUInteger count = [args count];
    
    NSInteger value = 0;
    NSString *attribute = nil;
    NSUInteger scope = LLProfileScopeApplication;

    if (count > 1){
        ENSURE_TYPE(args[0], NSString);
        attribute = [TiUtils stringValue:args[0]];

        value = [TiUtils intValue:args[1]];
    }
    
    if (count > 2){
        scope = [TiUtils intValue:args[2]];
    }
    
    [Localytics decrementValueBy:value forProfileAttribute:attribute withScope:scope];
}

- (void)deleteProfileAttribute:(id)args{
    NSUInteger count = [args count];
    
    NSString *attribute = nil;
    NSUInteger scope = LLProfileScopeApplication;
    
    if (count > 0){
        ENSURE_TYPE(args[0], NSString);
        attribute = [TiUtils stringValue:args[0]];
    }
    
    if (count > 1){
        scope = [TiUtils intValue:args[1]];
    }
    
    [Localytics deleteProfileAttribute:attribute withScope:scope];
}

#pragma mark - Push
/** ---------------------------------------------------------------------------------------
 * @name Push
 *  ---------------------------------------------------------------------------------------
 */

//- (id)pushToken{
//    return [Localytics pushToken];
//}

// Titanium handles the device token as a string (hex encoded) so we take it in as a string and convert it to NSData
- (void)setPushToken:(id)arg{
    ENSURE_SINGLE_ARG(arg, NSString)
    NSString *titaniumPushToken = arg;

    NSMutableData *pushToken = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i=0; i < [titaniumPushToken length]/2; i++) {
        byte_chars[0] = [titaniumPushToken characterAtIndex:i*2];
        byte_chars[1] = [titaniumPushToken characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [pushToken appendBytes:&whole_byte length:1];
    }
    
    [Localytics setPushToken:pushToken];
}

- (void)handlePushNotificationOpened:(id)arg{
    ENSURE_SINGLE_ARG(arg, NSDictionary)
    NSDictionary *notificationInfo = arg;
    
    //[Localytics handlePushNotificationOpened:notificationInfo];
}

#pragma mark - In-App Message
/** ---------------------------------------------------------------------------------------
 * @name In-App Message
 *  ---------------------------------------------------------------------------------------
 */

// handleTestModeULR will take a URL as String (for Titanium) instead of an NSURL (in Objective-C)
//- (id)handleTestModeURL:(id)arg{
//    ENSURE_SINGLE_ARG(arg, NSString)
//    NSURL *url = [NSURL URLWithString:arg];
//    
//    return NUMBOOL([Localytics handleTestModeURL:url]);
//}

//- (void)setInAppMessageDismissButtonImageWithName:(id)arg{
//    ENSURE_SINGLE_ARG(arg, NSString);
//    
//    [Localytics setInAppMessageDismissButtonImageWithName:arg];
//}
//- (void)setInAppMessageDismissButtonLocation:(id)arg{
//    [Localytics setInAppMessageDismissButtonLocation:[TiUtils intValue:arg]];
//}
//- (id)getInAppMessageDismissButtonLocation:(id)arg{
//    return NUMINT([Localytics inAppMessageDismissButtonLocation]);
//}

- (void)triggerInAppMessage:(id)args{
    NSUInteger count = [args count];
    
    NSString *triggerName = nil;
    NSDictionary *attributes = nil;
    
    if (count > 0){
        ENSURE_TYPE(args[0], NSString);
        triggerName = [TiUtils stringValue:args[0]];
    }
    
    if (count > 1){
        ENSURE_TYPE(args[1], NSDictionary);
        attributes = (NSDictionary *)args[1];
    }
    
    [Localytics triggerInAppMessage:triggerName withAttributes:attributes];
}

- (void)dismissCurrentInAppMessage:(id)args{ [Localytics dismissCurrentInAppMessage]; }

#pragma mark - Developer Options
/** ---------------------------------------------------------------------------------------
 * @name Developer Options
 *  ---------------------------------------------------------------------------------------
 */

- (id)isLoggingEnabled:(id)arg{
    return NUMBOOL([Localytics isLoggingEnabled]);
}
- (void)setLoggingEnabled:(id)arg{
    [Localytics setLoggingEnabled:[TiUtils boolValue:arg]];
}

//- (id)isCollectingAdvertisingIdentifier{
//    return NUMBOOL([Localytics isCollectingAdvertisingIdentifier]);
//}
//- (void)setCollectAdvertisingIdentifier:(id)arg{
//    [Localytics setCollectAdvertisingIdentifier:[TiUtils boolValue:arg]];
//}

- (id)isOptedOut:(id)arg{
    return NUMBOOL([Localytics isOptedOut]);
}
- (void)setOptedOut:(id)arg{
    [Localytics setOptedOut:[TiUtils boolValue:arg]];
}

- (id)isTestModeEnabled:(id)arg{
    return NUMBOOL([Localytics isTestModeEnabled]);
}
- (void)setTestModeEnabled:(id)arg{
    [Localytics setTestModeEnabled:[TiUtils boolValue:arg]];
}

- (void)setOptions:(id)arg{
    ENSURE_ARG_COUNT(arg, 1)
    ENSURE_TYPE(arg[0], NSDictionary)
    [Localytics setOptions: (NSDictionary*) arg[0]];
}

- (id)getInstallId:(id)args{
    return [Localytics installId];
}
- (id)getLibraryVersion:(id)args{
    return [Localytics libraryVersion];
}
- (id)getAppKey:(id)args{
    return [Localytics appKey];
}

@end
