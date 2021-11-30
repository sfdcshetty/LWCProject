@isTest
public class WEG_TestUtil {
    
    public static User createUser() {
        // create the user
        User testUser = new User(
            FirstName = 'Apex',
            LastName = 'Tester',
            Alias = 'apextest',
            Email = 'apex.tester@wealthenhancement.com',
            Username = 'apex.tester@wealthenhancement.com',
            CommunityNickname = 'apextest',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Advisor'].Id,
            //CompanyName = 'testusertrigger',
            //Title = 'Tester',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        // insert and return
        insert testUser;
        return testUser;
    }
    
    public static Account createPerson() {
        // create the person
        Account testPerson = new Account(
            Name='Apex Tester',
            FinServ__Status__c = 'Active',
            Type = 'Client',
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId()
        );
        
        // insert the person
        insert testPerson;
        
        Contact c = [SELECT Id FROM Contact WHERE AccountId = :testPerson.Id];
        testPerson.FinServ__PrimaryContact__c = c.Id;
        
        return testPerson;
    }
    
    public static FinServ__FinancialAccount__c createFinancialAccount(Id primaryOwnerId) {
        // create the financial account
        FinServ__FinancialAccount__c testFinancialAccount = new FinServ__FinancialAccount__c(
            FinServ__PrimaryOwner__c = primaryOwnerId,
            RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Advisory Investment Account').getRecordTypeId(),
            FinServ__Status__c = 'Open',
            FinServ__HeldAway__c = false
        );
        
        // insert and return
        insert testFinancialAccount;
        return testFinancialAccount;
    }
}