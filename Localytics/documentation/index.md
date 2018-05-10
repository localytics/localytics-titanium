# Localytics Module

## Description

Localytics is a closed-loop app analytics and marketing platform that helps brands acquire, engage, and retain users.

## Accessing the Localytics Module

To access this module from JavaScript, you would do the following:

var localytics = require("com.localytics");

The localytics variable is a reference to the Module object.

## Usage
See app.js for usage.

## Author
Localytics. For support email [support@localytics.com](mailto:support@localytics.com).

## Installing
* Follow the steps at http://docs.appcelerator.com/titanium/3.0/#!/guide/Using_a_Module to add the localytics module to your project

## Integration
#### Android
* Open tiapp.xml in the XML editor mode. Add a `<manifest>` section to the `<android>` section if you have not already done so.
* In the `<application>` tag in the manifest add the following:
```
<meta-data android:name="LOCALYTICS_APP_KEY" android:value="YOUR-APP-KEY"/>
```
* In the `<manifest>` section, add the following
```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```
* If you're using Localytics Push Messaging, also include the following permissions. NOTE: Replace YOUR.PACKAGE.NAME with your package name (i.e. com.yourcompany.yourapp)
``` 
<uses-permission android:name="android.permission.GET_ACCOUNTS" />
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
<permission android:name="YOUR.PACKAGE.NAME.permission.C2D_MESSAGE"
    android:protectionLevel="signature" />
<uses-permission android:name="YOUR.PACKAGE.NAME.permission.C2D_MESSAGE" />
```
* If you're using Localytics Push Messaging, add the sender ID property at the top-level (same level as `id` and `name`). NOTE: Replace YOUR_PROJECT_NUMBER with the number from your Google API Project. See the instructions [here](https://support.localytics.com/Android_SDK_integration#Push_Notifications) for setting up your Google API Project and configuring the server API key in the Localytics Dashboard.
```
<property name="com.localytics.android_push_sender_id">YOUR_PROJECT_NUMBER</property>
```
* Also for Localytics Push Messaging, add the following within the `<application>` tag. NOTE: Replace YOUR.PACKAGE.NAME with your package name (i.e. com.yourcompany.yourapp). This should match the `id` property in tiapp.xml.
```
<service android:name="com.localytics.gcm.GCMIntentService"/>
<receiver
    android:name="com.localytics.gcm.GCMBroadcastReceiver"
    android:permission="com.google.android.c2dm.permission.SEND">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <category android:name="android.intent.category.HOME"/>
    </intent-filter>
    <intent-filter>
        <action android:name="com.google.android.c2dm.intent.RECEIVE"/>
        <category android:name="YOUR.PACKAGE.NAME"/>
    </intent-filter>
    <intent-filter>
        <action android:name="com.google.android.c2dm.intent.REGISTRATION"/>
        <category android:name="YOUR.PACKAGE.NAME"/>
    </intent-filter>
</receiver>
```
*  If you're using Localytics Acquisition Tracking, add registration for the Localytics Referral Receiver to your application tag.
```
<receiver android:name="com.localytics.android.ReferralReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="com.android.vending.INSTALL_REFERRER" />
    </intent-filter>
</receiver>
```
* If you're using Localytics Attribution for advertising campaigns, add the Ti.Map module to your project. Though you may not be using maps, this module contains the Google Play Services library which is necessary for attribution tracking.
```
<modules>
    <!-- Add this line to your modules section -->
    <module platform="android">ti.map</module>
</modules>
```
#### iOS
* Open tiapp.xml in the XML editor mode. Add a `<plist>` section to the `<ios>` section if you have not already done so.
* Within the `<plist>` section add a `<dict>` section. In the `<dict>` section add the following:
```
<key>LocalyticsAppKey</key>
<string>YOUR-APP-KEY</string>
```
* If you're using Localytics Push messaging, be sure to follow the instructions [here](http://docs.appcelerator.com/titanium/3.0/#!/guide/Configuring_push_services-section-37551713_Configuringpushservices-ConfiguringpushservicesforiOSdevices) for configuring push for iOS devices.

### Automatic
ANDROID NOTE: This approach is only supported by Ice Cream Sandwich (Android 4.0, API level 14) and later.
* in `app.js` before calling `window.open();` add the following code
```
var localytics = require('com.localytics');
localytics.autoIntegrate();
```
* If you are using push, add this line of code as well 
```
var localyticsIOS = require('com.localytics.ios');
if (Ti.Platform.osname === 'android') {
    localytics.registerPush();
} else {
    localyticsIOS.registerPush();
}
```

* The CommonJS package com.localytics.ios is as follow. It basically calls setPushToken after registering Push the standard way

```
exports.registerPush = function() {
    if (Ti.Platform.name == "iPhone OS") {
        var localytics = require('com.localytics');
        // Check if the device is running iOS 8 or later
        if (parseInt(Ti.Platform.version.split(".")[0]) >= 8) {

            // Wait for user settings to be registered before registering for push notifications
            Ti.App.iOS.addEventListener('usernotificationsettings', function registerForPush() {

                // Remove event listener once registered for push notifications
                Ti.App.iOS.removeEventListener('usernotificationsettings', registerForPush);

                Ti.Network.registerForPushNotifications({
                    success : function(e) {
                        localytics.setPushToken(e.deviceToken);
                    }
                });
            });

            // Register notification types to use
            Ti.App.iOS.registerUserNotificationSettings({
                types : [
                    Ti.App.iOS.USER_NOTIFICATION_TYPE_ALERT,
                    Ti.App.iOS.USER_NOTIFICATION_TYPE_SOUND,
                    Ti.App.iOS.USER_NOTIFICATION_TYPE_BADGE
                ]
            });
        }

        // For iOS 7 and earlier
        else {
            Ti.Network.registerForPushNotifications({
                // Specifies which notifications to receive
                types : [Ti.Network.NOTIFICATION_TYPE_BADGE,
                    Ti.Network.NOTIFICATION_TYPE_ALERT,
                    Ti.Network.NOTIFICATION_TYPE_SOUND
                ],
                success : function(e) {
                    localytics.setPushToken(e.deviceToken);
                }
            });
        }
    }
};
```


### Manual

##### Android

For Android manual integration, you need to add the following to every window that you open:
```
var win = new Window();
var localytics = require('com.localytics');
if (Ti.Platform.osname, === 'android') {
    win.activity.onCreate = function(e) {
        localytics.integrate();
    };
    win.activity.onResume = function(e) {
        localytics.openSession();
        localytics.upload();
        localytics.setInAppMessageDisplayActivity(win.activity);
    };
    win.activity.onPause = function(e) {
        localytics.dismissCurrentInAppMessage();
        localytics.clearInAppMessageDisplayActivity();
        localytics.closeSession();
        localytics.upload();
    };
}
localytics.registerPush(); // If you are using push
win.open();
```
#### iOS
For iOS, you just need to register app-level events callbacks in your app.js:
```
var localytics = require('com.localytics');
if (Ti.Platform.name == "iPhone OS") {
    localytics.integrate();
    localytics.openSession();
    localytics.upload();
    Titanium.App.addEventListener('pause', function (e) {
        localytics.dismissCurrentInAppMessage();
        localytics.closeSession();
        localytics.upload();
    });
    Titanium.App.addEventListener('resume', function (e) {
        localytics.openSession();
        localytics.upload();
    });
    Titanium.App.addEventListener('resumed', function (e) {
        localytics.openSession();
        localytics.upload();
    });
}
localytics.registerPush(); // If you are using push
localytics.pauseDataUploading() // Optional: Become GDPR complient by offering to pause data uploading
```
## License
Copyright (c) 2015, Char Software, Inc. d/b/a Localytics
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Neither the nametag of Char Software, Inc., Localytics nor the names of its 
contributors may be used to endorse or promote products derived from this
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY CHAR SOFTWARE, INC. D/B/A LOCALYTICS ''AS IS'' AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL CHAR SOFTWARE, INC. D/B/A LOCALYTICS BE LIABLE 
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
copyright: Copyright (c) 2015 Char Software Inc.
