@isTest
public class CheckOpenNCNM_Test {
    
    static testMethod void checkOpenNCNM() {
        
        // get current user
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        // new test user
        User testUser;
        
        // runas in a new context to avoid Mixed DML
        System.runAs(thisUser) {
            
            // create a Chatter Group
            CollaborationGroup cg = new CollaborationGroup(Name = 'TestGroup', CollaborationType = 'Public');
            insert cg;
            
            // create a user
            testUser = new User(
                LastName = 'CheckOpenNCNM_Test',
                Email = 'CheckOpenNCNM_Test@wealthenhancement.test',
                Username = 'CheckOpenNCNM_Test@wealthenhancement.test',
                Alias = 'alias',
                CSChatterGroup__c = cg.Id,
                CompanyName = 'CheckOpenNCNM_Test',
                Title = 'Tester',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
            );
            insert testUser;
        }
        
        // create an account
        Account acc = new Account(Name = 'Name', OwnerId = testUser.Id);
        insert acc;
        
        // create a blot
        Blot__c blot = new Blot__c(WEGP1_Household__c = acc.Id, WEGP1_BlotType__c = 'New Money');
        insert blot;
        
        // create an opportunity
        Opportunity oppty = new Opportunity(Name = 'NCNM Test', StageName = 'Engage', CloseDate = date.today(), Household__c = acc.Id, Type = 'NCNM');
        oppty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Client New Money').getRecordTypeId();
        insert oppty;
        
        Test.startTest(); 
        
        // schedule the batch
        string jobName = 'testBatchApexJob';
        CheckOpenNCNM_Scheduler schedulable = new CheckOpenNCNM_Scheduler();
        string jobId = system.schedule(jobName, CheckOpenNCNM_Scheduler.CRON_EXP, schedulable);
        
        // get the cron trigger information
        CronTrigger ct = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // verify the expressions are the same
        system.assertEquals(CheckOpenNCNM_Scheduler.CRON_EXP, ct.CronExpression);
            
        Test.stopTest();   
    }
}