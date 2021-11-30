/*
 * Copyright (c) 2020. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 2/27/20.
 */

@IsTest
private class x7sAnnouncementsSettingTest
{
	@IsTest
	static void testBehavior()
	{
		x7sAnnouncementsSettings.AnnouncementEmailTemplate = 'test';
		x7sAnnouncementsSettings.AnnouncementProfile = 'Test Profile';
		System.assertNotEquals(null, x7sAnnouncementsSettings.AnnouncementEmailTemplate);
	}
}