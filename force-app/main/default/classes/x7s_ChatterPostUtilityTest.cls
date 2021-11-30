/**
 * Created by 7Summits on 5/21/21.
 */

@IsTest
private class x7s_ChatterPostUtilityTest {


        @testSetup
        private static void createTestData(){
            Account testAcc = new Account(Name='Test Account');
            Insert testAcc;

            // Setup test data
            // This code runs as the system user
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@weg.com');
            insert testUser;
        }


        private static testMethod void testTextPost() {
            Test.startTest();
            list<x7s_ChatterPostUtility.ChatterPostInputs> inputs = new list<x7s_ChatterPostUtility.ChatterPostInputs>();
            x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();

            Account acc = [Select Id From Account Limit 1];
            User usr = [Select Id From User Limit 1];

            input.parentId = acc.Id;
            input.userId = usr.Id;
            input.chatterBody = 'Test Msg';
            inputs.add(input);

            x7s_ChatterPostUtility.ChatterFeedItemAction(inputs);

            // Validate Data
            list<FeedItem> feedItems = [Select Id From FeedItem ];
            system.assert(feedItems.size() > 0 );
            test.stopTest();

        }


        private static testMethod void testUrlPost() {
            Test.startTest();
            list<x7s_ChatterPostUtility.ChatterPostInputs> inputs = new list<x7s_ChatterPostUtility.ChatterPostInputs>();
            x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();

            Account acc = [Select Id From Account Limit 1];
            User usr = [Select Id From User Limit 1];

            input.parentId = acc.Id;
            input.userId = usr.Id;
            input.chatterBody = 'Test Msg';
            input.url = 'https://www.wealthenhancement.com/';
            inputs.add(input);

            x7s_ChatterPostUtility.ChatterFeedItemAction(inputs);

            // Validate Data
            list<FeedItem> feedItems = [Select Id From FeedItem ];
            system.assert(feedItems.size() > 0 );
            test.stopTest();

        }


}