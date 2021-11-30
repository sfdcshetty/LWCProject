/******************************************************************************************************************************
* @class name    : Wave6_AccountContactRelationTriggerTest
* @description   : This class provides unit tests for Wave6_AccountContactRelationTrigger. 
* @author        : Ganesh Ekhande
* @date          : 05/30/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/30/2017             Created.
*
******************************************************************************************************************************/
@isTest
private class Wave6_AccountContactRelationTriggerTest {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit tests for Wave6_AccountContactRelationTrigger.
    * @created      : 05/30/2017
    */
	private static testMethod void testACRTrigger(){
	    test.startTest();
	    // Insert Household Account
        Account hhAcc1 = new Account(Name = 'Test HH Account 1', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc1;
        
        // Insert Individual Accounts
        Account indAcc = new Account(Name = 'Test Ind Account 1', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc;
        
        // Fetch Contact
        Contact con =  [Select Id, FinServ__IndividualId__c From Contact Where AccountId = :indAcc.Id];
        
        //Insert AccountContactRelation record
        AccountContactRelation acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = con.Id;
        acr.FinServ__PrimaryGroup__c = true;
        acr.FinServ__Primary__c = true;
        acr.isActive = true;
        acr.Roles = 'Client';
        insert acr;
        
        indAcc = [Select Id, Name, WEGP1_Primary_Household__c From Account Where Id = :indAcc.Id];
        system.assertEquals(indAcc.WEGP1_Primary_Household__c, hhAcc1.Id);
        
        // Update AccountContactRelation record
        acr.FinServ__PrimaryGroup__c = false;
        update acr;
        
        indAcc = [Select Id, Name, WEGP1_Primary_Household__c From Account Where Id = :indAcc.Id];
        system.assertEquals(indAcc.WEGP1_Primary_Household__c, null);
        
        test.stopTest();
	}
	
	
	private static testMethod void updatePrimarySecondaryContactsTest(){
	    test.startTest();
	    List<Account> accList = new List<Account>();  
	    
	    // Insert Household Account
        Account hhAcc1 = new Account(Name = 'Test HH Account 1', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc1;
        
        
        // Insert Individual Accounts
        Account indAcc = new Account(Name = 'Test Individual 1', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        accList.add(indAcc);
        
        indAcc = new Account(Name = 'Test Individual 2', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        accList.add(indAcc);
        
        indAcc = new Account(Name = 'Test Individual 3', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        accList.add(indAcc);
        
        insert accList;
        
        // Fetch Contacts
        List<Contact> conList =  [Select Id, FinServ__IndividualId__c From Contact Where AccountId =: accList];
        
        
        //Insert AccountContactRelation record
        List<AccountContactRelation> acrList = new list<AccountContactRelation>();
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = conList[0].Id;
        acr.FinServ__Primary__c = true;
        acr.FinServ__PrimaryGroup__c = true;
        acr.isActive = true;
        acr.Roles = 'Client';
        insert acr;
        
        acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = conList[1].Id;
        acr.FinServ__PrimaryGroup__c = true;
        acr.isActive = true;
        acr.Roles = 'Spouse';
        insert acr;
        
        Account accTest1 = [SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id = :hhAcc1.Id];
        
        system.assertEquals(conList[0].Id, accTest1.WEGP1_Primary_Individual__c);
        system.assertEquals(conList[1].Id, accTest1.WEGP1_Secondary_Individual__c);
        
        acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = conList[2].Id;
        acr.FinServ__PrimaryGroup__c = true;
        acr.isActive = true;
        acr.Roles = 'Domestic Partner';
        insert acr;
        
        Account accTest2 = [SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id = :hhAcc1.Id];
        
        system.assertEquals(conList[0].Id, accTest2.WEGP1_Primary_Individual__c);
        system.assertEquals(null, accTest2.WEGP1_Secondary_Individual__c);
        
        delete acr;
        
        Account accTest3 = [SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id = :hhAcc1.Id];
        
        system.assertEquals(conList[0].Id, accTest3.WEGP1_Primary_Individual__c);
        system.assertEquals(conList[1].Id, accTest3.WEGP1_Secondary_Individual__c);
	}
}