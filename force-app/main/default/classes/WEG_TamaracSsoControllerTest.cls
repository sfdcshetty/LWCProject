@isTest
private class WEG_TamaracSsoControllerTest {
    
    private static testMethod void testUserHasSignOnAccess() {
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'last',
            Email = 'wegTamSsoUser@weg.com',
            Username = 'wegTamSsoUser@weg.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            Support_Team__c='Allee Team',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert u;
        
        test.startTest();
        
        system.runAs(u) {
            WEG_TamaracSsoController.userHasSignOnAccess();
        }
        
        u.WEG_TamaracSsoUser__c = true;
        update u;
        
        system.runAs(u) {
            WEG_TamaracSsoController.userHasSignOnAccess();
        }
        
        test.stopTest();
    }
}