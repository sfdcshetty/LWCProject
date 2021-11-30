/*
 * Copyright (c) 2020. 7Summits Inc.
 */

// ===================
// Test X7S Utils
// ===================
@IsTest
public with sharing class x7sAnnouncementsUtilsTest {

    @TestSetup
    static void testSetup() {
        Contact testContact = x7sAnnouncementsTestUtils.createTestContact();
        System.assertNotEquals(null, testContact);
    }

    @IsTest
    public static void testIsNullOrEmpty() {
        // Assert return true for empty list
        List<String> stringList = new List<String>();
        System.assertEquals(x7sAnnouncementsUtils.isNullOrEmpty(stringList), true);

        // Assert return false for not empty list
        stringList.add(x7sAnnouncementsTestConstants.ACCOUNT_NAME);
        System.assertEquals(x7sAnnouncementsUtils.isNullOrEmpty(stringList), false);
    }

    @IsTest
    public static void testGetSitePrefix() {
        System.assert(x7sAnnouncementsUtils.getSitePrefix() != null);
    }

    @IsTest
    public static void testCreateAttachment() {
        // Set up and run as a standard user
        List<Contact> testContacts = [SELECT Id FROM Contact WHERE Email = :x7sAnnouncementsTestConstants.STANDARD_EMAIL];

        User testUser = x7sAnnouncementsTestUtils.createStandardUserNoContact();
        try {
            testUser.ContactId = testContacts[0].Id;
            insert testUser;
        } catch (Exception e) {
            testUser.ContactId = null;
            insert testUser;
        }

        Attachment testAttachment = x7sAnnouncementsTestUtils.createAttachment(testUser.Id);
        System.assert(testAttachment != null);
    }

    @IsTest
    public static void testGetPicklistValues() {
        List<String> options = x7sAnnouncementsUtils.getPicklistValues('User', 'LanguageLocaleKey');
        System.assert(options.size() > 0);
    }

    @IsTest
    public static void testCreateListFromMultiPicklist() {

        String multiPicklistString = 'string1;string2;string3';

        List<String> multiPicklistList = x7sAnnouncementsUtils.createListFromMultiPicklist(multiPicklistString);

        System.assertEquals(multiPicklistList.get(0), 'string1');
        System.assertEquals(multiPicklistList.get(1), 'string2');
        System.assertEquals(multiPicklistList.get(2), 'string3');

    }

    @IsTest
    public static void testisGuestUser() {
        // Set up and run as a standard user
        List<Contact> testContacts = [SELECT Id FROM Contact WHERE Email = :x7sAnnouncementsTestConstants.STANDARD_EMAIL];

        User testUser = x7sAnnouncementsTestUtils.createStandardUserNoContact();
        try {
            testUser.ContactId = testContacts[0].Id;
            insert testUser;
        } catch (Exception e) {
            testUser.ContactId = null;
            insert testUser;
        }

        System.runAs(testUser) {
            Boolean isGuest = x7sAnnouncementsUtils.isGuestUser();
            System.assertEquals(isGuest, false);
        }


        User testGuest = x7sAnnouncementsTestUtils.createGuestUser();
        System.runAs(testGuest) {
            Boolean isGuest = x7sAnnouncementsUtils.isGuestUser();
            System.assertEquals(isGuest, true);
        }
    }

    @IsTest
    public static void testgetFieldSchema() {
        // Super simple - just assert that the account keyset returns name. We know this will always be true
        System.assert(x7sAnnouncementsUtils.getFieldSchema('Account').containsKey('Name'));
    }
}