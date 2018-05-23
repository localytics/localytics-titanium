package com.localytics;

import com.localytics.android.Localytics;

public final class LocalyticsLog
{

	private static final String TAG = "LocalyticsModule";

	private LocalyticsLog()
	{
	}

	public static int d(final String msg)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.d(TAG, msg);
		} else {
			return -1;
		}
	}

	public static int d(final String msg, final Throwable tr)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.d(TAG, msg, tr);
		} else {
			return -1;
		}
	}

	public static int e(final String msg)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.e(TAG, msg);
		} else {
			return -1;
		}
	}

	public static int e(final String msg, final Throwable tr)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.e(TAG, msg, tr);
		} else {
			return -1;
		}
	}

	public static int i(final String msg)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.i(TAG, msg);
		} else {
			return -1;
		}
	}

	public static int i(final String msg, final Throwable tr)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.i(TAG, msg, tr);
		} else {
			return -1;
		}
	}

	public static int v(final String msg, final Throwable tr)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.v(TAG, msg, tr);
		} else {
			return -1;
		}
	}

	public static int v(final String msg)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.v(TAG, msg);
		} else {
			return -1;
		}
	}

	public static int w(final String msg, final Throwable tr)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.w(TAG, msg, tr);
		} else {
			return -1;
		}
	}

	public static int w(final String msg)
	{
		if (Localytics.isLoggingEnabled()) {
			return org.appcelerator.kroll.common.Log.w(TAG, msg);
		} else {
			return -1;
		}
	}
}
