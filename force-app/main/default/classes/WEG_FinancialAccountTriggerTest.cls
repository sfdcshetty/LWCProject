@isTest
private class WEG_FinancialAccountTriggerTest {
    @testSetup
    private static void setup() {
        Id hhRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id trustRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Trust').getRecordTypeId();
        Id indivRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        // create a household account
        Account hhAcc = new Account(Name='Tim and Paul Allen', Type = 'Client', RecordTypeId = hhRecordTypeId);
        insert hhAcc;
        
        // create a trust account
        Account trustAcc = new Account(Name = 'Test Trust', RecordTypeId = trustRecordTypeId);
        insert trustAcc;
        
        // create an individual
        Account indAcc = new Account(Name='Tim Allen', FinServ__Status__c = 'Active', Type = 'Client', RecordTypeId = indivRecordTypeId);
        insert indAcc;
        
        // get the contact portion of the individual
        Contact ctc = [SELECT Id FROM Contact WHERE AccountId = :indAcc.Id];
        
        // create a household to individual relationship
        AccountContactRelation acr1 = new AccountContactRelation();
        acr1.contactId = ctc.Id;
        acr1.AccountId = hhAcc.Id;
        acr1.FinServ__Primary__c = true;
        acr1.FinServ__PrimaryGroup__c = true;
        insert acr1;
    }
    
    private static testMethod void testTrigger1() {
        // 
        Account trustAcc = [SELECT Id FROM Account WHERE Name = 'Test Trust'];
        Account indAcc = [SELECT Id FROM Account WHERE Name = 'Tim Allen'];
        
        test.startTest();
        
        FinServ__FinancialAccount__c finacc = New FinServ__FinancialAccount__c();
        finacc.Name = 'Test Fin Acct 1';
        finacc.FinServ__PrimaryOwner__c = trustAcc.Id;
        finacc.FinServ__CloseDate__c = NULL;
        finacc.Finserv__Status__c = 'Closed';
        //finacc.FinServ__Balance__c = 2.00;
        finacc.WEG_External_Rec_ID__c = '1234';
        insert finacc;
        
        // update the financial account, testing the first scenario
        finacc.FinServ__Balance__c = 2.00;
        finacc.FinServ__PrimaryOwner__c = indAcc.Id;
        update finacc;
        
        // test the second scenario
        finacc.FinServ__CloseDate__c = Date.newInstance(2018, 1, 9);
        finacc.FinServ__Status__c = 'Open';
        finacc.FinServ__Balance__c = 0.00;
        finacc.WEGP1_Closing_Value__c = 2.00;
        update finacc;
        
        test.stopTest();
    }
    
    private static testMethod void testTrigger2() {
        //
        Account trustAcc = [SELECT Id FROM Account WHERE Name = 'Test Trust'];
        Account indAcc = [SELECT Id FROM Account WHERE Name = 'Tim Allen'];
        
        test.startTest();
        
        FinServ__FinancialAccount__c finacc2 = New FinServ__FinancialAccount__c();
        finacc2.Name = 'Test Fin Acct 2';                   
        finacc2.FinServ__PrimaryOwner__c = indAcc.Id;
        finacc2.Finserv__Status__c = 'Open';
        insert finacc2;
        
        // third scenario, status changed
        finacc2.FinServ__CloseDate__c = Date.newInstance(2018, 1, 9);
        finacc2.FinServ__PrimaryOwner__c = trustAcc.Id;
        finacc2.Finserv__Status__c = 'Closed';
        update finacc2;
        
        test.stopTest();
    }
    
    private static testMethod void testTrigger3() {
        //
        Account indAcc = [SELECT Id FROM Account WHERE Name = 'Tim Allen'];
        
        test.startTest();
        
        FinServ__FinancialAccount__c finacc3 = New FinServ__FinancialAccount__c();
        finacc3.Name = 'Test Fin Acct 3';                   
        finacc3.FinServ__PrimaryOwner__c = indAcc.Id;
        finacc3.Finserv__Status__c = 'Open';
        insert finacc3;
        
        // 6th scenario, electronic prospectus
        finacc3.WEG_Electronic_Prospectus_Delivery__c = true;
        update finacc3;
        
        // 4th scenario, 
        finacc3.Remove_or_Historic__c = 'Transfer to Historic';
        update finacc3;
        
        test.stopTest();
    }
    
    private static testMethod void testTrigger4() {
        //
        Account trustAcc = [SELECT Id FROM Account WHERE Name = 'Test Trust'];
        
        test.startTest();
        
        Id insuranceTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Insurance Policy').getRecordTypeId();
        
        FinServ__FinancialAccount__c finacc4 = New FinServ__FinancialAccount__c();
        finacc4.Name = 'Test Fin Acct 4';
        finacc4.RecordTypeId = insuranceTypeId;
        finacc4.FinServ__PrimaryOwner__c = trustAcc.Id;
        finacc4.Finserv__Status__c = 'Open';
        finacc4.WEG_Product_Type__c = 'Other';
        insert finacc4;
        
        // 5th scenario, accumulation value
        finacc4.WEGP1_AccumulationValue__c = 2.00;
        update finacc4;
        
        test.stopTest();
    }
}