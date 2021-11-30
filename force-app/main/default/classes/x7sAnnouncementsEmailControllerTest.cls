/*
 * Copyright (c) 2020. 7Summits Inc.
 */

@IsTest
public with sharing class x7sAnnouncementsEmailControllerTest
{

    @IsTest
    public static void testSendAnnouncementEmail(){

        // Create Test Community_Announcement List
        List<Id> testAnnouncementIDList = new List<Id>();

        // Test Community_Announcement
        X7S_Announcement__c testAnnouncement =
                new X7S_Announcement__c(Start_Date_Time__c = Date.newInstance(1990, 1, 1),
                        End_Date_Time__c = Date.newInstance(2090, 1, 1), Name = 'Test Announcement',
                        Announcement_Body__c = 'This is a test.', Announcement_Type__c = 'info',
                        Announcement_Channel__c = 'Default');

        insert testAnnouncement;
        System.assertNotEquals(null, testAnnouncement);

        testAnnouncementIDList.add(testAnnouncement.Id);
        x7sAnnouncementsEmailController.sendAnnouncementEmail(testAnnouncementIDList);
    }
}