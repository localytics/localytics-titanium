package com.localytics;

import java.util.Date;

import com.localytics.android.Localytics;

public class Utils
{
	private Utils() {}
	
	public static Localytics.ProfileScope getProfileScope(String scope)
	{
		if (scope == null || scope.equals(LocalyticsModule.PROFILE_SCOPE_APP))
		{
			return Localytics.ProfileScope.APPLICATION;
		}
		else if (scope.equals(LocalyticsModule.PROFILE_SCOPE_ORG))
		{
			return Localytics.ProfileScope.ORGANIZATION;
		}
		else
		{
			throw new IllegalArgumentException("Profile scope must be either 'org' or 'app'.");
		}
	}
	
	public static Object getFirst(Object[] source)
	{
		if (source != null && source.length > 0)
		{
			return source[0];
		}
		
		return null;
	}

	public static String[] extractStringArray(Object[] source)
	{
		if (source == null)
		{
			return null;
		}
		
		String[] strings = new String[source.length];
		for (int i = 0; i < source.length; i++)
		{
			if (source[i] instanceof String)
			{
				strings[i] = (String) source[i];
			}
			else
			{
				// Return null for entire array to prevent multi-type arrays
				return null;
			}
		}
		
		return strings;
	}
	
	public static long[] extractLongArray(Object[] source)
	{
		if (source == null)
		{
			return null;
		}
		
		long[] longs = new long[source.length];
		for (int i = 0; i < source.length; i++)
		{
			if (source[i] instanceof Integer)
			{
				longs[i] = (Integer) source[i];
			}
			else
			{
				// Return null for entire array to prevent multi-type arrays
				return null;
			}
		}
		
		return longs;
	}
	
	public static Date[] extractDateArray(Object[] source)
	{
		if (source == null)
		{
			return null;
		}
		
		Date[] dates = new Date[source.length];
		for (int i = 0; i < source.length; i++)
		{
			if (source[i] instanceof Date)
			{
				dates[i] = (Date) source[i];
			}
			else
			{
				// Return null for entire array to prevent multi-type arrays
				return null;
			}
		}
		
		return dates;
	}
}
