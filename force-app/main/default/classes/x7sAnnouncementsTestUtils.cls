/*
 * Copyright (c) 2020. 7Summits Inc.
 */

@IsTest
public with sharing class x7sAnnouncementsTestUtils
{
	public static User createStandardUserNoContact(){
		List<Profile> standardProfileList = [SELECT Id FROM Profile WHERE Name = :x7sAnnouncementsTestConstants.COMMUNITY_PROFILE];
		User testUser;
		if (!x7sAnnouncementsUtils.isNullOrEmpty(standardProfileList)) {
			Profile standardProfile = standardProfileList[0];
			testUser = new User(Alias = x7sAnnouncementsTestConstants.STANDARD_ALIAS, Email= x7sAnnouncementsTestConstants.STANDARD_EMAIL, EmailEncodingKey= x7sAnnouncementsTestConstants.ENCODING, FirstName= x7sAnnouncementsTestConstants.FIRSTNAME, LastName= x7sAnnouncementsTestConstants.LASTNAME, LanguageLocaleKey= x7sAnnouncementsTestConstants.LOCALE,LocaleSidKey= x7sAnnouncementsTestConstants.LOCALE, ProfileId = standardProfile.Id,TimeZoneSidKey= x7sAnnouncementsTestConstants.TIMEZONE, Username= x7sAnnouncementsTestConstants.STANDARD_USERNAME);
		}

		return testUser;
	}

	// Create a standard user
	public static User createStandardUser(){
		Contact contact = createTestContact();
		User testUser;

		List<Profile> standardProfileList = [SELECT Id FROM Profile WHERE Name = :x7sAnnouncementsTestConstants.COMMUNITY_PROFILE];

		if (!x7sAnnouncementsUtils.isNullOrEmpty(standardProfileList)) {
			Profile standardProfile = standardProfileList[0];
			testUser = new User(Alias = x7sAnnouncementsTestConstants.STANDARD_ALIAS, Email= x7sAnnouncementsTestConstants.STANDARD_EMAIL, EmailEncodingKey= x7sAnnouncementsTestConstants.ENCODING, FirstName= x7sAnnouncementsTestConstants.FIRSTNAME, LastName= x7sAnnouncementsTestConstants.LASTNAME, LanguageLocaleKey= x7sAnnouncementsTestConstants.LOCALE,LocaleSidKey= x7sAnnouncementsTestConstants.LOCALE, ProfileId = standardProfile.Id,TimeZoneSidKey= x7sAnnouncementsTestConstants.TIMEZONE, Username= x7sAnnouncementsTestConstants.STANDARD_USERNAME);
			testUser.ContactId = contact.Id;
		}

		return testUser;
	}

	// Create a guest user
	public static User createGuestUser(){
		List<Profile> standardProfileList;
		User guestUser;

		try {
			standardProfileList = [SELECT Id FROM Profile WHERE Name='Standard User'];
		} catch (DmlException e) {
			System.debug(e);
		}

		if (!x7sAnnouncementsUtils.isNullOrEmpty(standardProfileList)) {
			Profile standardProfile = standardProfileList[0];
			guestUser = new User(Alias = x7sAnnouncementsTestConstants.GUEST_ALIAS, Email= x7sAnnouncementsTestConstants.GUEST_EMAIL, EmailEncodingKey= x7sAnnouncementsTestConstants.ENCODING, FirstName= x7sAnnouncementsTestConstants.FIRSTNAME,LastName= x7sAnnouncementsTestConstants.LASTNAME, LanguageLocaleKey= x7sAnnouncementsTestConstants.LOCALE,LocaleSidKey= x7sAnnouncementsTestConstants.LOCALE, ProfileId = standardProfile.Id,TimeZoneSidKey= x7sAnnouncementsTestConstants.TIMEZONE, Username= x7sAnnouncementsTestConstants.GUEST_USERNAME);
		}

		return guestUser;
	}

	// Create an account so we can create a Contact
	public static Account createTestAccount(){
		Account account = new Account(Name= x7sAnnouncementsTestConstants.ACCOUNT_NAME);
		insert account;
		return account;
	}

	// Create a contact associated with an account
	public static Contact createTestContact(){
		Account account = createTestAccount();
		Contact contact = new Contact(FirstName= x7sAnnouncementsTestConstants.FIRSTNAME, LastName= x7sAnnouncementsTestConstants.LASTNAME, Email= x7sAnnouncementsTestConstants.STANDARD_EMAIL);
		contact.AccountId = account.Id;
		insert contact;

		return contact;
	}

	// Create an attachment
	public static Attachment createAttachment(Id parentId){
		Attachment attachment = new Attachment();
		Blob bodyBlob=Blob.valueOf('');
		attachment.ParentId = parentId;
		attachment.Body = bodyBlob;
		attachment.Name = x7sAnnouncementsTestConstants.FIRSTNAME;
		return attachment;
	}
}