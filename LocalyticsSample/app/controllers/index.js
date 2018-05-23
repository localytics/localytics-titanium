var localytics = require('com.localytics');
var localyticsIOS = require('com.localytics.ios');

function doClick(e) {
    alert($.label.text);    
	localytics.tagEvent('click_hello1');
	localytics.upload();
}

$.index.open();
// This is a test harness for your module
// You should do something interesting in this harness
// to test out the module and to provide instructions
// to users on how to use it by example.


// integrate - must happen before calling win.open();
localytics.autoIntegrate('YOUR_API_KEY');

if (Ti.Platform.osname === 'android') {
	localytics.registerPush();
} else {
	localyticsIOS.registerPush();
}

// developer options
localytics.setLoggingEnabled(true);
localytics.setSessionTimeoutInterval(5);

// set cumstom dimensions and identifiers 
localytics.setCustomDimension(0, 'value_one'); // custom dimension number can be 0 - 9
localytics.getCustomDimension(0);
localytics.setCustomerId('apple@localytics.com');
localytics.setIdentifier("my_identifier", "value");
localytics.getIdentifier("my_identifier");

// event tagging
localytics.tagEvent('test_event');
localytics.tagEvent('test_event_2', {'key': 'value'});
localytics.tagEvent('test_event_3', {'key_3': 'value_3'}, 10);

// screen tagging
localytics.tagScreen("screen_name");

// profiles - implicit application scope
localytics.setProfileAttribute("my_integer_attribute", 1);
localytics.setProfileAttribute("my_integer_array_attribute", [3, 4]);
localytics.setProfileAttribute("my_string_attribute", "test_one");
localytics.setProfileAttribute("my_string_array_attribute", ["test_three", "test_four"]);

localytics.setProfileAttribute("my_date_attribute", new Date());
localytics.setProfileAttribute("my_date_array_attribute", [new Date(), new Date()]);

localytics.addProfileAttributesToSet("my_integer_array_attribute", [1,2]);
localytics.addProfileAttributesToSet("my_string_array_attribute", ["one", 'two']);
localytics.addProfileAttributesToSet("my_date_array_attribute", [new Date(), new Date()]);

localytics.removeProfileAttributesFromSet("my_integer_array_attribute", [1,2]);
localytics.removeProfileAttributesFromSet("my_string_array_attribute", ['one', 'two']);
localytics.removeProfileAttributesFromSet("my_date_array_attribute", [new Date()]);

localytics.incrementProfileAttribute("my_integer_attribute", 5);
localytics.decrementProfileAttribute("my_integer_attribute", 6);

localytics.deleteProfileAttribute("my_integer_attribute");

// profiles - explicit application scope
localytics.setProfileAttribute("my_integer_attribute", 2, localytics.PROFILE_SCOPE_APP);
localytics.setProfileAttribute("my_integer_array_attribute", [5, 6], localytics.PROFILE_SCOPE_APP);
localytics.setProfileAttribute("my_string_attribute", "test_two", localytics.PROFILE_SCOPE_APP);

// profiles - explicit organization scope
localytics.setProfileAttribute("my_string_array_attribute", ["test_five", "test_six"], localytics.PROFILE_SCOPE_ORG);
localytics.setProfileAttribute("my_date_attribute", new Date(), localytics.PROFILE_SCOPE_ORG);
localytics.setProfileAttribute("my_date_array_attribute", [new Date(), new Date()], localytics.PROFILE_SCOPE_ORG);

localytics.addProfileAttributesToSet("my_integer_attribute", [1,2], localytics.PROFILE_SCOPE_ORG);
localytics.addProfileAttributesToSet("my_string_array_attribute", ["one", 'two'], localytics.PROFILE_SCOPE_ORG);
localytics.addProfileAttributesToSet("my_date_array_attribute", [new Date(), new Date()], localytics.PROFILE_SCOPE_ORG);

localytics.removeProfileAttributesFromSet("my_integer_attribute", [1,2], localytics.PROFILE_SCOPE_ORG);
localytics.removeProfileAttributesFromSet("my_string_array_attribute", ['one', 'two'], localytics.PROFILE_SCOPE_ORG);
localytics.removeProfileAttributesFromSet("my_date_array_attribute", [new Date()], localytics.PROFILE_SCOPE_ORG);

localytics.incrementProfileAttribute("my_integer_attribute", 5, localytics.PROFILE_SCOPE_ORG);
localytics.decrementProfileAttribute("my_integer_attribute", 6, localytics.PROFILE_SCOPE_ORG);

localytics.deleteProfileAttribute("my_integer_attribute", localytics.PROFILE_SCOPE_ORG);

localytics.upload();
	
// Localytics info
console.log('library version ' + localytics.getLibraryVersion());
console.log('install id ' + localytics.getInstallId());
console.log('app key ' + localytics.getAppKey());

// Optional: Start ranging for BLE beacons
// localytics.startMonitoring({ uuid: 'YOUR_BEACON_UUID', identifier: 'YOUR_BEACON_IDENTIFIER' });
// localytics.stopMonitoring();