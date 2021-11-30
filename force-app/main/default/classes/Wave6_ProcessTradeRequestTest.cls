/******************************************************************************************************************************
* @class name    : Wave6_ProcessTradeRequestTest
* @description   : This class provides unit tests for Wave6_ProcessTradeRequest class. 
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
private class Wave6_ProcessTradeRequestTest {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is unit test for TradeRequestAction.
    * @created      : 05/19/2017
    */
    private static testMethod void testTradeRequestAction() {

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
        
        Test.startTest();
        // Fetch DCA Trading Ticket Record Type Id
        Id DCATradingRecordTypeId = Schema.SObjectType.Trade_Request__c.getRecordTypeInfosByName().get('DCA Trade Ticket Parent').getRecordTypeId();
        
        // Create Test users
        list<User>users = new list<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name='Advisor']; 
        users.add(new User(Alias = 'standt1', Email='standarduser1@weg.com', EmailEncodingKey='UTF-8', LastName='User 1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@weg.com'));
        insert users;
        
        // Create Trade Request
        Trade_Request__c newTradeRequest = new Trade_Request__c();
        newTradeRequest.RecordTypeId =                  DCATradingRecordTypeId;
        newTradeRequest.Status__c =                     'New';
        newTradeRequest.WEGP1_Frequency__c =            'Daily';
        newTradeRequest.WEGP1_Household__c =            hhAcc.ID;
        newTradeRequest.WEGP1_Individual__c =           indAcc.ID;
        newTradeRequest.WEGP1_FinancialAccount__c =     finAcct.ID;
        newTradeRequest.Advisor__c = users[0].Id;
        
        insert newTradeRequest;
        
        Test.stopTest();
        
        
        //Determine if the date falls within  Business Hours
        // Get the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
        // Find whether the time is within the default business hours
        Boolean isWithin = BusinessHours.isWithin(bh.id, system.now());
        
        // Fetch all trade requests
        List<Trade_Request__c> tradeRequestList = [Select Id From Trade_Request__c];
        
        if(isWithin){
            System.assertEquals(2,tradeRequestList.size());
        }else{
            System.assertEquals(1,tradeRequestList.size());
        }    
    }

}