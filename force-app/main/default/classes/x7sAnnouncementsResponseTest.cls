/*
 * Copyright (c) 2020. 7Summits Inc.
 */

@isTest
public with sharing class x7sAnnouncementsResponseTest
{

    @isTest
    public static void testX7SReponse(){
        x7sAnnouncementsResponse response = new x7sAnnouncementsResponse();

        // Test success flag
        System.assertEquals(response.success,true);

        // Test messages
        response.messages.add(x7sAnnouncementsTestConstants.TEST_MESSAGE);
        System.assertEquals(response.messages[0], x7sAnnouncementsTestConstants.TEST_MESSAGE);

        // Test object list
        Account account = x7sAnnouncementsTestUtils.createTestAccount();
        response.results.add(account);
        System.assertEquals(account,response.results[0]);
    }
}