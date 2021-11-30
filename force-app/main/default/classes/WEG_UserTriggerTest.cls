@isTest(seeAllData=true)
private class WEG_UserTriggerTest {
    
    private static testMethod void testTrigger(){
        
        test.startTest();
        User u = new User(
            LastName = 'Test',
            Email = 'testusertrigger@test.com',
            Username = System.now().millisecond() + 'testusertriggerweg@usertriggertest.com',
            Alias = 'alias',
            CompanyName = 'testusertrigger',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        
        u.Title = 'Sr. Tester';
        update u;
        
        test.stopTest();
    }
}