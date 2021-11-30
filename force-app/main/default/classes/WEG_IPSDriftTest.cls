@isTest
public class WEG_IPSDriftTest {
    public static testMethod void testschedule() {
        
        // insert a non-admin user for testing
        User u = new User(
            LastName = 'Test',
            Email = 'testusertrigger@test.com',
            Username = 'testusertrigger@test.com',
            Alias = 'alias',
            CompanyName = 'testusertrigger',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            WEG_GLDepartment__c = 10,
            WEG_GLLocation__c = 1001,
            WEG_FACode__c = 2001
        );
        insert u;
        
        // 
        insert new WEG_AccountConfiguration__c(WEG_MaxIPSDrift__c = 10, WEG_MinIPSDrift__c = -10);
        
        // create an investment objective
        Investment_Objective__c invObj = new Investment_Objective__c(Name = 'Test Objective', WEG_Equity__c = 46.34);
        insert invObj;
        
        // create a household
        Id householdRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account household = new Account(Name = 'Test HH', RecordTypeId = householdRecordType
                                        , OwnerId = u.Id);
        //, WEGP1_ClientAnniversaryDate__c = Date.newInstance(2017, 01, 01)
        household.TamAdvisor__Updated_by_Tamarac_Integration__c = true;
        household.WEGP1_Total_AUM_Household__c = 10;
        household.WEG_Investment_Policy_Statement__c = invObj.Id;
        insert household;
        
        Test.StartTest();
        
        WEG_IPSDriftScheduler sh1 = new WEG_IPSDriftScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Drift', sch, sh1);
        
        Test.stopTest();
    }
}