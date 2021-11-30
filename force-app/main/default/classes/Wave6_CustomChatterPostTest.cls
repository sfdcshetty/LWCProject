/******************************************************************************************************************************
* @class name    : Wave6_CustomChatterPostTest
* @description   : This class provides unit tests for Wave6_CustomChatterPost.
* @author        : Ganesh Ekhande
* @date          : 05/11/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Wave6                       05/11/2017             Created.
* 
******************************************************************************************************************************/
@isTest
private class Wave6_CustomChatterPostTest {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is testSetup method to create required test data for all the test mothods.
    * @created      : 05/11/2017
    */
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
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit tests for ChatterFeedItemAction method when posting Text.
    * @created      : 05/11/2017
    */
	private static testMethod void testTextPost() {
        Test.startTest();
        list<Wave6_CustomChatterPost.ChatterPostInputs> inputs = new list<Wave6_CustomChatterPost.ChatterPostInputs>();
        Wave6_CustomChatterPost.ChatterPostInputs input = new Wave6_CustomChatterPost.ChatterPostInputs(); 
        
        Account acc = [Select Id From Account Limit 1];
        User usr = [Select Id From User Limit 1];
        
        input.parentId = acc.Id;
        input.userId = usr.Id;
        input.chatterBody = 'Test Msg';
        inputs.add(input);
        
        Wave6_CustomChatterPost.ChatterFeedItemAction(inputs);
        
        // Validate Data
        list<FeedItem> feedItems = [Select Id From FeedItem ];
        system.assert(feedItems.size() > 0 );
        test.stopTest();
        
	}
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit tests for ChatterFeedItemAction method when posting url.
    * @created      : 05/11/2017
    */
    private static testMethod void testUrlPost() {
        Test.startTest();
        list<Wave6_CustomChatterPost.ChatterPostInputs> inputs = new list<Wave6_CustomChatterPost.ChatterPostInputs>();
        Wave6_CustomChatterPost.ChatterPostInputs input = new Wave6_CustomChatterPost.ChatterPostInputs(); 
        
        Account acc = [Select Id From Account Limit 1];
        User usr = [Select Id From User Limit 1];
        
        input.parentId = acc.Id;
        input.userId = usr.Id;
        input.chatterBody = 'Test Msg';
        input.url = 'https://www.wealthenhancement.com/';
        inputs.add(input);
        
        Wave6_CustomChatterPost.ChatterFeedItemAction(inputs);
        
        // Validate Data
        list<FeedItem> feedItems = [Select Id From FeedItem ];
        system.assert(feedItems.size() > 0 );
        test.stopTest();
        
	}

}