/*
 * Copyright (c) 2020. 7Summits Inc.
 */

@IsTest
private class x7sAnnouncementsContentObjectTest
{
	@TestSetup
	static void testSetup()
	{
		Contact testContact = x7sAnnouncementsTestUtils.createTestContact();
		System.assertNotEquals(null, testContact);
	}

	@IsTest
	public static void testX7S_ContentObject()
	{

		List<Contact> testContacts = [SELECT Id FROM Contact WHERE Email = :x7sAnnouncementsTestConstants.STANDARD_EMAIL];

		User testUser = x7sAnnouncementsTestUtils.createStandardUserNoContact();
		try
		{
			testUser.ContactId = testContacts[0].Id;
			insert testUser;
		} catch (Exception e)
		{
			testUser.ContactId = null;
			insert testUser;
		}

		Test.startTest();

		x7sAnnouncementsContentObject x7sContentObject = new x7sAnnouncementsContentObject();
		x7sContentObject.contentID = testUser.Id;
		x7sContentObject.title = x7sAnnouncementsTestConstants.FIRSTNAME;
		x7sContentObject.description = x7sAnnouncementsTestConstants.TEST_DESCRIPTION;
		x7sContentObject.fullDescription = x7sAnnouncementsTestConstants.TEST_DESCRIPTION;
		x7sContentObject.attachments = new List<Attachment>();
		x7sContentObject.url = x7sAnnouncementsTestConstants.TEST_URL;
		x7sContentObject.featured = false;
		x7sContentObject.bannerImage = '';
		x7sContentObject.avatar = '';
		x7sContentObject.commentCount = 1;
		x7sContentObject.commentUrl = '';
		x7sContentObject.dateTimeField = Datetime.newInstance(2011, 11, 18, 3, 3, 3);
		x7sContentObject.dateField = x7sAnnouncementsTestConstants.TODAY;

		System.assertEquals(x7sContentObject.title, x7sAnnouncementsTestConstants.FIRSTNAME);
		Test.stopTest();
	}

}