/******************************************************************************************************************************
* @class name    : Wave6_SetHouseholdNameTest
* @description   : This class provides unit tests for Wave6_SetHouseholdName and  Wave6_HouseholdNameUpdate classes. 
* @author        : Ganesh Ekhande
* @date          : 05/31/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/31/2017             Created.
*
******************************************************************************************************************************/
@isTest
private class Wave6_SetHouseholdNameTest {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit test for scenario where all child individual contacts have SAME LAST NAME.
    * @created      : 05/31/2017
    */
	private static testMethod void HouseholdNameUpdateActionTest1() {
        test.startTest();
        List<Account> accList = new List<Account>();
	    // Insert Household Account
        Account hhAcc1 = createAccount('TestHHAccount 1',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc1;
        
        // Insert Individual Accounts
        Account indAcc1 = createAccount('TestIndAccount 1', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc1;
        
        // Insert Individual Accounts
        Account indAcc2 = createAccount('TestIndAccount 1', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc2;
        
        Contact con1 =  [Select Id, FirstName, LastName From Contact Where AccountId =: indAcc1.Id];
        Contact con2 =  [Select Id, FirstName, LastName From Contact Where AccountId =: indAcc2.Id];
        
        //Insert AccountAccountRelation record
        AccountContactRelation acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = con1.Id;
        acr.FinServ__Primary__c = true;
        acr.FinServ__PrimaryGroup__c = true;
        acr.Roles='Client';
        insert acr;
        
        //Insert AccountAccountRelation record
        acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = con2.Id;
        acr.FinServ__Primary__c = FALSE;
        acr.FinServ__PrimaryGroup__c = false;
        acr.Roles='Client';
        insert acr;
        
        Wave6_SetHouseholdName.HouseholdNameUpdateAction(new list<Id>{hhAcc1.id});
        
        Account updatedAcc = [Select Id, Name From Account Where Id =: hhAcc1.Id];
        system.assertEquals('TestIndAccount and TestIndAccount 1 Household', updatedAcc.Name);
        test.stopTest();
	}
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit test for scenario where all child individual contacts have DIFFERENT LAST NAME.
    * @created      : 05/31/2017
    */
    private static testMethod void HouseholdNameUpdateActionTest2() {
        test.startTest();

        List<Account> accList = new List<Account>();
	    // Insert Household Account
        Account hhAcc1 = createAccount('TestHHAccount 1',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc1;
        
        // Insert Individual Accounts
        Account indAcc1 = createAccount('TestIndAccount 1', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc1;
        
        // Insert Individual Accounts
        Account indAcc2 = createAccount('TestIndAccount 2', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc2;
        
        Contact con1 =  [Select Id, FirstName, LastName From Contact Where AccountId =: indAcc1.Id];
        Contact con2 =  [Select Id, FirstName, LastName From Contact Where AccountId =: indAcc2.Id];
        
        //Insert AccountAccountRelation record
        AccountContactRelation acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = con1.Id;
        acr.FinServ__Primary__c = TRUE;
        acr.FinServ__PrimaryGroup__c = TRUE;
        acr.Roles='Client';
        insert acr;
        
        //Insert AccountAccountRelation record
        acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = con2.Id;
        acr.FinServ__Primary__c = FALSE;
        acr.FinServ__PrimaryGroup__c = TRUE;
        acr.Roles='Client';
        insert acr;
        
        Wave6_SetHouseholdName.HouseholdNameUpdateAction(new list<Id>{hhAcc1.id});
        
        Account updatedAcc = [Select Id, Name From Account Where Id =: hhAcc1.Id];
        system.assertEquals('TestIndAccount 1 and TestIndAccount 2 Household', updatedAcc.Name);
        
	}    
	
	/*
    * @author       : Ganesh Ekhande
    * @description  : This Method provides unit test for HouseholdNameAction method in Wave6_HouseholdNameUpdate class.
    * @created      : 05/31/2017
    */
	private static testMethod void testHouseholdNameAction(){
	    test.startTest();
	    List<Account> accList = new List<Account>();
	    // Insert Household Account
        Account hhAcc1 = createAccount('TestHHAccount 1',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc1;
        
        // Insert Individual Accounts
        Account indAcc1 = createAccount('TestIndAccount 1', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc1;
        
        // Insert Individual Accounts
        Account indAcc2 = createAccount('TestIndAccount 1', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc2;
        
        Contact con1 =  [Select Id, FirstName, LastName From Contact Where AccountId =: indAcc1.Id];
        Contact con2 =  [Select Id, FirstName, LastName From Contact Where AccountId =: indAcc2.Id];
        
        //Insert AccountAccountRelation record
        AccountContactRelation acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = con1.Id;
        acr.FinServ__Primary__c = TRUE;
        acr.FinServ__PrimaryGroup__c = TRUE;
        acr.Roles='Client';
        insert acr;
        
        //Insert AccountAccountRelation record
        acr = new AccountContactRelation();
        acr.accountId = hhAcc1.Id;
        acr.contactId = con2.Id;
        acr.FinServ__Primary__c = FALSE;
        acr.FinServ__PrimaryGroup__c = TRUE;
        acr.Roles='Client';
        insert acr;
        
        Wave6_HouseholdNameUpdate.HouseholdNameAction(new List<Id>{indAcc1.Id,indAcc2.Id});    
        
        Account updatedAcc = [Select Id, Name From Account Where Id =: hhAcc1.Id];
        system.assertEquals('TestIndAccount and TestIndAccount 1 Household', updatedAcc.Name);
        test.stopTest();
	}
	
	/*
    * @author       : Ganesh Ekhande
    * @description  : This Method create test accounts based on provided informtaion.
    * @created      : 05/31/2017
    */
	public static Account createAccount(String accName, Id recordTypeId){
	    Account acc = new Account();
	    acc.Name = accName;
	    acc.recordTypeId = recordTypeId;
	    return acc;
	}
}