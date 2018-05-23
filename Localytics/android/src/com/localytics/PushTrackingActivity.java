package com.localytics;

import com.localytics.android.Localytics;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public final class PushTrackingActivity extends Activity
{

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		Localytics.integrate(this);
		Localytics.openSession();
		Localytics.handlePushNotificationOpened(getIntent());

		Intent launchIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());
		startActivity(launchIntent);

		finish();
	}
}
