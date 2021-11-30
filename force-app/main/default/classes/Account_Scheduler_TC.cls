@istest
public class Account_Scheduler_TC{
    static testMethod void testschedule() {
        Test.StartTest();
        AccountOwnership_Scheduler sh1 = new AccountOwnership_Scheduler();      
        String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}