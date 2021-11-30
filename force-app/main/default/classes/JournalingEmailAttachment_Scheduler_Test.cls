@istest
public class JournalingEmailAttachment_Scheduler_Test{
    static testMethod void testschedule() {
        Test.StartTest();
        JournalingEmailAttachment_Scheduler sh1 = new JournalingEmailAttachment_Scheduler();      
        String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}