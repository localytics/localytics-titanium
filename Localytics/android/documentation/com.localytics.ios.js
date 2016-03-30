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