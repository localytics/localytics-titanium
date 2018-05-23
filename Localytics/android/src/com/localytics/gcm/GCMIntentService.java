package com.localytics.gcm;

import com.localytics.LocalyticsLog;
import com.localytics.PushTrackingActivity;
import com.localytics.android.Localytics;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import org.json.JSONException;
import org.json.JSONObject;

public class GCMIntentService extends GCMBaseIntentService
{

	private static final String LOCALYTICS_METADATA_NOTIFICATION_ICON = "LOCALYTICS_NOTIFICATION_ICON";

	public GCMIntentService()
	{
		super("GCMIntentService");
	}

	@Override
	public void onRegistered(Context context, String registrationId)
	{
		LocalyticsLog.d("GCM registered: " + registrationId);
		Localytics.setPushRegistrationId(registrationId);
	}

	@Override
	public void onUnregistered(Context context, String registrationId)
	{
		LocalyticsLog.d("GCM unregistered: " + registrationId);
	}

	@Override
	protected void onMessage(Context context, Intent intent)
	{
		String llString = intent.getExtras().getString("ll");
		if (llString == null) {
			LocalyticsLog.w("Ignoring message that aren't from Localytics.");
			return;
		}

		// Try to parse the campaign id from the payload
		int campaignId = 0;
		try {
			JSONObject llObject = new JSONObject(llString);
			campaignId = llObject.getInt("ca");
		} catch (JSONException e) {
			LocalyticsLog.w("Failed to get campaign id from payload, ignoring message");
			return;
		}

		String message = intent.getExtras().getString("message");

		CharSequence appName = "";
		int appIcon = getLocalyticsNotificationIcon(context);
		try {
			ApplicationInfo applicationInfo =
				context.getPackageManager().getApplicationInfo(context.getPackageName(), 0);
			appName = context.getPackageManager().getApplicationLabel(applicationInfo);
		} catch (PackageManager.NameNotFoundException e) {
			LocalyticsLog.w("Failed to get application name, icon, or launch intent");
		}

		Intent launchIntent = new Intent(this, PushTrackingActivity.class);
		launchIntent.putExtras(intent);
		PendingIntent contentIntent =
			PendingIntent.getActivity(context, 0, launchIntent, PendingIntent.FLAG_UPDATE_CURRENT);
		
		Notification.Builder builder = new Notification.Builder(context);
		builder.setContentIntent(contentIntent).setAutoCancel(true);
		builder.setContentText(message);
		
		Notification notification = builder.getNotification();
		notification.flags |= Notification.FLAG_AUTO_CANCEL;

		// Show the notification (use the campaign id as the notification id to prevents duplicates)
		NotificationManager notificationManager =
			(NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.notify(campaignId, notification);
	}

	private int getLocalyticsNotificationIcon(Context context)
	{
		// first try to get the image indicated in the manifest meta-data with the key LOCALYTICS_NOTIFICATION_ICON
		// then try to use the application's icon
		// finally, default to a generic Android icon
		ApplicationInfo applicationInfo;
		try {
			applicationInfo =
				context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
			if (applicationInfo.metaData != null) {
				String metaData = (String) applicationInfo.metaData.get(LOCALYTICS_METADATA_NOTIFICATION_ICON);
				if (null != metaData) {
					String iconName = metaData.substring(metaData.lastIndexOf('/') + 1, metaData.lastIndexOf('.'));
					return context.getResources().getIdentifier(iconName, "drawable", context.getPackageName());
				}
			}

			applicationInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(), 0);
			if (applicationInfo.icon != 0) {
				return applicationInfo.icon;
			}
		} catch (PackageManager.NameNotFoundException e) {
		}

		return android.R.drawable.sym_def_app_icon;
	}

	@Override
	public void onError(Context context, String errorId)
	{
		LocalyticsLog.e("GCM error: " + errorId);
	}

	@Override
	public boolean onRecoverableError(Context context, String errorId)
	{
		LocalyticsLog.e("GCM recoverable error: " + errorId);
		return true;
	}
}
