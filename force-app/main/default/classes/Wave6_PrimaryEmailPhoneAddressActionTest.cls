/******************************************************************************************************************************
* @class name    : Wave6_PrimaryEmailPhoneAddressActionTest
* @description   : This class provides unit tests for Wave6_UpdateAllChildContactAction and Wave6_UpdateContactAction classes.
*                  
* @author        : Ganesh Ekhande
* @date          : 08/02/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              08/02/2017             Created.

******************************************************************************************************************************/
@isTest
private class Wave6_PrimaryEmailPhoneAddressActionTest {
    
    private static testMethod void  updateContactActionTest() {
        // Create Test Account
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.BillingStreet = 'BillingStreet';
        acc.BillingCity = 'BillingCity';
        acc.BillingPostalCode = 'BillingPostalCode';
        acc.BillingState = 'BillingState';
        acc.BillingCountry = 'BillingCountry';
        acc.ShippingStreet = 'ShippingStreet';
        acc.ShippingCity = 'ShippingCity';
        acc.ShippingPostalCode = 'ShippingPostalCode';
        acc.ShippingState = 'ShippingState';
        acc.ShippingCountry = 'ShippingCountry';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId(); 
        insert acc;
        
        // Create Test Contact
        Contact con = new Contact();
        con.LastName = ' Test Contact';
        con.WEGP1_PrimaryAddress__c = 'Work';
        con.WEGP1_PrimaryEmail__c ='Work';
        con.WEGP1_PrimaryPhone__c = 'Work';
        con.HomePhone = '1111111111';
        con.AssistantPhone = '2222222222';
        con.MobilePhone = '3333333333';
        con.OtherPhone = '4444444444';
        con.WEG_Business_Email__c = 'work_email@weg.com';
        con.WEGP1_OtherEmail__c = 'other_email@weg.com';
        con.WEGP1_PersonalEmail__c = 'test@weg.com';
        con.Email = 'test@weg.com';
        con.OtherStreet = 'OtherStreet';
        con.accountId = acc.Id;
        con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        insert con;
        
        
        // Update Primary Address on Account
        con.WEGP1_PrimaryAddress__c = 'Other';
        Update con;
        
        Contact updatedContact = [Select Id, MailingStreet From Contact Where Id =: con.Id];
        system.assertEquals('OtherStreet', updatedContact.MailingStreet);
        
        con.WEGP1_PrimaryAddress__c = 'Home';
        Update con;
        updatedContact = [Select Id, MailingStreet From Contact Where Id =: con.Id];
        system.assertEquals(acc.BillingStreet, updatedContact.MailingStreet);
        
        con.WEGP1_PrimaryAddress__c = 'Work';
        Update con;
        updatedContact = [Select Id, MailingStreet From Contact Where Id =: con.Id];
        system.assertEquals(acc.ShippingStreet, updatedContact.MailingStreet);
        
        
        // Update Primary Email on Contact
        con.WEGP1_PrimaryEmail__c = 'Personal';
        Update con;
        updatedContact = [Select Id, Email,WEGP1_PersonalEmail__c From Contact Where Id =: con.Id];
        system.assertEquals(con.Email, updatedContact.WEGP1_PersonalEmail__c);
        
        con.WEGP1_PrimaryEmail__c = 'Work';
        Update con;
        updatedContact = [Select Id, Email From Contact Where Id =: con.Id];
        system.assertEquals(con.WEG_Business_Email__c, updatedContact.Email);
        
        con.WEGP1_PrimaryEmail__c = 'Other';
        Update con;
        updatedContact = [Select Id, Email From Contact Where Id =: con.Id];
        system.assertEquals(con.WEGP1_OtherEmail__c, updatedContact.Email);
        
        // Update Primary Phone on Contact
        con.WEGP1_PrimaryPhone__c = 'Home';
        Update con;
        updatedContact = [Select Id, Phone From Contact Where Id =: con.Id];
        system.assertEquals(con.HomePhone, updatedContact.Phone);
        
        con.WEGP1_PrimaryPhone__c = 'Work';
        Update con;
        updatedContact = [Select Id, Phone From Contact Where Id =: con.Id];
        system.assertEquals(con.AssistantPhone , updatedContact.Phone);
        
        con.WEGP1_PrimaryPhone__c = 'Cell';
        Update con;
        updatedContact = [Select Id, Phone From Contact Where Id =: con.Id];
        system.assertEquals(con.MobilePhone, updatedContact.Phone);
        
        con.WEGP1_PrimaryPhone__c = 'Other';
        Update con;
        updatedContact = [Select Id, Phone From Contact Where Id =: con.Id];
        system.assertEquals(con.OtherPhone , updatedContact.Phone); 
    }
  
    private static testMethod void updateAllChildContactActionTest() {
        // Create Test Account
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.BillingStreet = 'BillingStreet';
        acc.BillingCity = 'BillingCity';
        acc.BillingPostalCode = 'BillingPostalCode';
        acc.BillingState = 'BillingState';
        acc.BillingCountry = 'BillingCountry';
        acc.ShippingStreet = 'ShippingStreet';
        acc.ShippingCity = 'ShippingCity';
        acc.ShippingPostalCode = 'ShippingPostalCode';
        acc.ShippingState = 'ShippingState';
        acc.ShippingCountry = 'ShippingCountry';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert acc;
        
        // Create Test Contact
        Contact con = new Contact();
        con.LastName = ' Test Contact';
        con.WEGP1_PrimaryAddress__c = 'Work';
        con.WEGP1_PrimaryEmail__c ='Work';
        con.WEGP1_PrimaryPhone__c = 'Work';
        con.HomePhone = '1111111111';
        con.AssistantPhone = '2222222222';
        con.MobilePhone = '3333333333';
        con.OtherPhone = '4444444444';
        con.WEG_Business_Email__c = 'work_email@weg.com';
        con.WEGP1_OtherEmail__c = 'other_email@weg.com';
        con.Email = 'test@weg.com';
        con.OtherStreet = 'OtherStreet';
        con.accountId = acc.Id;
        con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con;
        
        test.startTest();
        
        acc.ShippingStreet ='Updated Shipping Street';
        update acc;     
        
        Contact updatedContact = [Select Id, MailingStreet, WEGP1_PrimaryAddress__c From Contact Where Id =: con.Id];
        system.assertEquals(acc.ShippingStreet, updatedContact.MailingStreet);
        
        updatedContact.WEGP1_PrimaryAddress__c = 'Home';
        update updatedContact;
        
        updatedContact = [Select Id, MailingStreet, WEGP1_PrimaryAddress__c From Contact Where Id =: con.Id];
        system.assertEquals(acc.BillingStreet, updatedContact.MailingStreet);
        
        acc.Name ='Test';
        acc.BillingStreet ='Test Billing Street';
        update acc; 
        
        updatedContact = [Select Id, MailingStreet, WEGP1_PrimaryAddress__c From Contact Where Id =: con.Id];
        system.assertEquals(acc.BillingStreet, updatedContact.MailingStreet);
        test.stopTest();
        
    }
}