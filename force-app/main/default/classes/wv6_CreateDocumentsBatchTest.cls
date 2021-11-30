@isTest
private class wv6_CreateDocumentsBatchTest {
    @testSetup
    private static void createTestData(){
        
        // Create Test users
        list<User>users = new list<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        users.add(new User(Alias = 'standt1', Email='standarduser11@weg.com', EmailEncodingKey='UTF-8', LastName='User 1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser11@weg.com'));
        users.add(new User(Alias = 'standt2', Email='standarduser22@weg.com', EmailEncodingKey='UTF-8', LastName='User 2', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser22@weg.com'));
        //users.add(new User(Alias = 'standt3', Email='standarduser3@weg.com', EmailEncodingKey='UTF-8', LastName='User 3', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3@weg.com'));
        //users.add(new User(Alias = 'standt4', Email='standarduser4@weg.com', EmailEncodingKey='UTF-8', LastName='User 4', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4@weg.com'));
        insert users;
        
        //Create Individual Accounts
        list<Account> accounts = new list<Account>();
        Account indAcc= new Account(Name='Ind Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        accounts.add(indAcc);
        
        Account indAcc2= new Account(Name='Ind Account2', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        accounts.add(indAcc2);
        insert accounts;
        
        list<Contact> contacts = new list<Contact>();
        contacts = [SELECT Id FROM Contact WHERE AccountId IN:accounts];
        if(contacts.size() >1){
            //Create Household Account
            Account hhAcc = new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_Primary_Individual__c = contacts[0].Id, WEGP1_Secondary_Individual__c=contacts[1].Id );
            insert hhAcc;
        }
        
        list<Document__c> docs = new list<Document__c>();
        docs =[SELECT Id FROM Document__c];
        
        delete docs;
        
    }
    
  private static testMethod void testCreateDocumentsBatch() {
        test.startTest();    
        wv6_CreateDocumentsBatch batch = new wv6_CreateDocumentsBatch();
        database.executeBatch(batch);
        test.stopTest();
        
        list<Document__c> docs = new list<Document__c>();
        docs =[SELECT Id FROM Document__c];
        system.assertEquals(1, docs.size()); 
  }

}