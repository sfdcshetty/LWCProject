@istest
public class IndvidualAccount_Scheduler_TC{
    static testMethod void testschedule() {
        Test.StartTest();
        IndvidualAccount_Scheduler sh1 = new IndvidualAccount_Scheduler();      
        String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}