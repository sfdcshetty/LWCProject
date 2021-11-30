@IsTest(SeeAllData=true)
public class x7s_UserPhotoRetrieveCMSSchedulerTest {
    
  @IsTest(SeeAllData=true)
    public static void userPhotoRetrieveTest(){
        Test.startTest();
        x7s_UserPhotoRetrieveFromCMSScheduler.schedule();
        Test.stopTest();
        List<CronTrigger> existingCronTriggers = [
                SELECT Id, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE '%x7s_UserPhotoRetrieveFromCMSScheduler%'
        ];
        System.assertNotEquals(0, existingCronTriggers.size());
    }
}