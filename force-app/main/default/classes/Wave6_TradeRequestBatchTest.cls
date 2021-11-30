/******************************************************************************************************************************
* @class name    : Wave6_TradeRequestBatchTest
* @description   : This class provides unit tests for Wave6_TradeRequestBatch batch class. 
* @author        : Ganesh Ekhande
* @date          : 05/19/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/19/2017             Created.
*
******************************************************************************************************************************/
@isTest
private class Wave6_TradeRequestBatchTest {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is testSetup method to create required test data for all the test mothods.
    * @created      : 05/19/2017
    */
    @testSetup
    public static void setupTestData(){

        // Fetch Household Account Record Type Id
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        // Create test household account record
        Account hhAcc = new Account();
        DateTime d = datetime.now();
        String currentMonthName= d.format('MMMMM');
        hhAcc.Name = 'Test Account';
        hhAcc.WEGP1_Review_Months__c = currentMonthName;
        hhAcc.RecordTypeId = householdRecordTypeId;
        insert hhAcc;
        
        system.debug('hhAcc:>>'+hhAcc);
        
        // Create test individual account
        Account indAcc = new Account();
        indAcc.Name = 'Individual Account';
        indAcc.RecordTypeId = individualRecordTypeId;
        //indAcc.FinServ__IndividualId__c = 'DUMMYINDIVIDUALID';
        insert indAcc;
        
        system.debug('indAcc:>>'+indAcc);
        
        // Create Test individual contact record
        // Fetch individual contact Record Type Id
        Id indConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = indConRecordTypeId;
        con.FirstName = 'Test First Name';
        con.LastName = 'Test Last Name';
        con.AccountId = indAcc.Id;
        insert con;
        
        // Create AccountContactRelation
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = hhAcc.Id;
        acr.ContactId = con.Id;
        acr.FinServ__Primary__c = true;
        insert acr;
        
        FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c();
        finAcct.Name = 'test';
        finAcct.FinServ__Household__c = hhAcc.ID;
        finAcct.FinServ__PrimaryOwner__c = indAcc.ID;
        insert finAcct;
        

        // Fetch DCA Trading Ticket Record Type Id
        RecordType dcaRecordType = [SELECT ID, Name, DeveloperName FROM RecordType WHERE DeveloperName='DCA_Trade_Ticket_Parent' and sObjectType = 'Trade_Request__c' LIMIT 1];
        
        // Create Test users
        list<User>users = new list<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name='Advisor']; 
        users.add(new User(Alias = 'standt1', Email='standarduser1@weg.com', EmailEncodingKey='UTF-8', LastName='User 1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@weg.com'));
        insert users;
        
        // Create Trade Request
        List<Trade_Request__c> tradeRequests = new List<Trade_Request__c>();
        Trade_Request__c newTradeRequest;
        for(integer i=1 ; i<=10 ; i++){
            newTradeRequest = new Trade_Request__c();
            newTradeRequest.RecordTypeId =                  dcaRecordType.ID;
            newTradeRequest.Status__c =                     'WIP'; //This is set to WIP only because otherwise process builder auto creates a child trade request right away and job won't pick up the parent
            newTradeRequest.WEGP1_Frequency__c =            'Daily';
            newTradeRequest.WEGP1_LastTradeDate__c =        System.Today().addDays(-i);  
            newTradeRequest.WEGP1_Household__c =            hhAcc.ID;
            newTradeRequest.WEGP1_Individual__c =           indAcc.ID;
            newTradeRequest.WEGP1_FinancialAccount__c =     finAcct.ID;
            newTradeRequest.Advisor__c = users[0].Id;
            tradeRequests.add(newTradeRequest);
        }
        insert tradeRequests;
    }

   /*
    * @author       : Ganesh Ekhande
    * @description  : This is unit test methid for Trade Request Batch Class.
    * @created      : 05/19/2017
    */
    private static testMethod void testTradeRequestBatch() {
        Test.startTest();
        
        // Execute Trade Request Batch Class
        Wave6_TradeRequestBatch batchCls =new Wave6_TradeRequestBatch();
        database.executeBatch(batchCls); 
        
        Test.stopTest();
        
        // Fetch all trade requests
        List<Trade_Request__c> tradeRequestList = [Select Id From Trade_Request__c];
        
        // Get the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
        // Find whether the time is within the default business hours
        Boolean isWithin = BusinessHours.isWithin(bh.id, system.now());
        system.debug('isWithin:>>'+isWithin);
        System.debug(bh);
        
        
        //Determine if the date falls on a weekend
        if(isWithin == true){
            System.assertEquals(20, tradeRequestList.size());
        }else{
            System.assertEquals(10, tradeRequestList.size());
        }    
    }
    
    private static testmethod void  Wave6_TradeRequestBatchSchedulerTest(){
        Test.startTest();
        Wave6_TradeRequestBatchScheduler sh1 = new Wave6_TradeRequestBatchScheduler();     
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();
    }
}