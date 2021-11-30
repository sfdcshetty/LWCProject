@isTest
public class WEG_AssetsAndLiabilitiesTriggerTest {
    private static testMethod void testTrigger() {
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
        
        test.startTest();
        
        FinServ__AssetsAndLiabilities__c asset1 = New FinServ__AssetsAndLiabilities__c();
        asset1.Name = 'Test Asset 1';
        asset1.FinServ__PrimaryOwner__c = trustAcc.Id;
        insert asset1;
        
        asset1.FinServ__PrimaryOwner__c = indAcc.Id;
        update asset1;
        
        asset1.FinServ__PrimaryOwner__c = trustAcc.Id;
        update asset1;
        
        FinServ__AssetsAndLiabilities__c asset2 = New FinServ__AssetsAndLiabilities__c();
        asset2.Name = 'Test Asset 2';
        asset2.FinServ__PrimaryOwner__c = indAcc.Id;
        insert asset2;
        
        test.stopTest();
    }
}