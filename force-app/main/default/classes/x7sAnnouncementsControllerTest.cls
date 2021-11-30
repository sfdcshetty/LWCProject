/*
 * Copyright (c) 2020. 7Summits Inc.
 */

@IsTest
public with sharing class x7sAnnouncementsControllerTest
{
	@IsTest
	public static void testResults()
	{
		// Create user
		User testUser = x7sAnnouncementsTestUtils.createStandardUser();
		try
		{
			insert testUser;
		} catch (Exception e)
		{
			testUser.ContactId = null;
		}

		// Insert test announcement
		X7S_Announcement__c testAnnouncement = new X7S_Announcement__c(Start_Date_Time__c = Date.newInstance(1990, 1, 1), End_Date_Time__c = Date.newInstance(2090, 1, 1), Name = 'Test Announcement', Announcement_Body__c = 'This is a test.', Announcement_Type__c = 'info', Announcement_Channel__c = 'Default');
		insert testAnnouncement;

		// Test
		System.runAs(testUser)
		{
			System.assertEquals(x7sAnnouncementsController.getActiveAnnouncements('1', 'Default', 'All', '').results.size(), 1);
		}
	}

	@IsTest
	public static void testNoResults()
	{

		// Create user
		User testUser = x7sAnnouncementsTestUtils.createStandardUser();
		try
		{
			insert testUser;
		} catch (Exception e)
		{
			testUser.ContactId = null;
			insert testUser;
		}

		// Test
		System.runAs(testUser)
		{
			System.assertEquals(x7sAnnouncementsController.getActiveAnnouncements('3', 'Default', 'All', '').results.size(), 0);
		}

	}

	@IsTest
	public static void testGetValues()
	{
		x7sAnnouncementsChannels channels = new x7sAnnouncementsChannels();
		System.assert(channels.getDefaultValue() != null);
		System.assert(channels.getValues() != null);
	}

	@IsTest
	public static void testGetPrefix()
	{
		System.assert(x7sAnnouncementsController.getSitePrefix() != null);
	}

	@IsTest
	public static void testGetUserId()
	{
		System.assert(x7sAnnouncementsController.getUserId() != null);
	}

	@IsTest
	public static void testGetNetworkId()
	{
		System.assertNotEquals(null, x7sAnnouncementsController.getNetworkId());
	}
}