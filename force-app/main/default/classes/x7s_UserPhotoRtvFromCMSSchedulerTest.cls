@isTest
public class x7s_UserPhotoRtvFromCMSSchedulerTest {
	@isTest
    public static void userPhotoRetrieveFromCMSTest(){
        
        Test.StartTest();
        x7s_UserPhotoRetrieveFromCMSScheduler obj = new x7s_UserPhotoRetrieveFromCMSScheduler();
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 0 0 * * ?'; 
        String response = System.schedule('Test Class: x7s_UserPhotoRtvFromCMSSchedulerTest'+System.now(), cronExp, obj);
        x7s_UserPhotoRetrieveFromCMSScheduler.schedule(cronExp);
        Test.stopTest(); 
        
    }
    @isTest
    public static void userPhotoRetrieveFromCMS1Test(){
        
        Test.StartTest();
        x7s_UserPhotoRetrieveFromCMSScheduler obj = new x7s_UserPhotoRetrieveFromCMSScheduler();
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 0 0 * * ?'; 
        x7s_UserPhotoRetrieveFromCMSScheduler.schedule();
        Test.stopTest(); 
        
    }
    @isTest
    public static void userPhotoRetrieveFromCMS2Test(){
        
        Test.StartTest();
        x7s_UserPhotoRetrieveFromCMSScheduler obj = new x7s_UserPhotoRetrieveFromCMSScheduler();
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 0 0 * * ?'; 
        x7s_UserPhotoRetrieveFromCMSScheduler.schedule('');
        Test.stopTest(); 
        
    }
}