@isTest
private class WEG_IntroHeldBatchSchedulerTest {
    
    private static testMethod void testBatch() {
        
        Opportunity oppty = new Opportunity(Name='Test Oppty', StageName='Engage', CloseDate=date.today());
        insert oppty;
        
        Event evt = new Event(Subject='Test Event', WhatId=oppty.Id, WEGP1_MeetingType__c='Needs Analysis', StartDateTime=datetime.now(), DurationInMinutes=60);
        insert evt;
        
        test.startTest();
        
        // schedule the batch
        string jobName = 'testBatchApexJob';
        WEG_IntroHeldBatchScheduler schedulable = new WEG_IntroHeldBatchScheduler();
        string jobId = system.schedule(jobName, WEG_IntroHeldBatchScheduler.CRON_EXP, schedulable);
        
        // get the cron trigger information
        CronTrigger ct = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // verify the expressions are the same
        system.assertEquals(WEG_IntroHeldBatchScheduler.CRON_EXP, ct.CronExpression);
        
        test.stopTest();
    }
}