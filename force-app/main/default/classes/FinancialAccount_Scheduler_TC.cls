@istest
public class FinancialAccount_Scheduler_TC{
    static testMethod void testschedule() {
        Test.StartTest();
        FinancialAccount_Scheduler sh1 = new FinancialAccount_Scheduler();      
        String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}