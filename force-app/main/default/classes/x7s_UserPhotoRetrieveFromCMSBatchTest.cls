@IsTest(SeeAllData=true)
public class x7s_UserPhotoRetrieveFromCMSBatchTest {
    
    @IsTest(SeeAllData=true)
    public static void userPhotoRetrieveTest1(){
        
        try{
            x7s_UserPhotoRetrieveFromCMSBatch obj1 = new x7s_UserPhotoRetrieveFromCMSBatch();
            obj1.runOnce = true;
            Test.startTest();
            Id jobId = Database.executeBatch(obj1);
            Test.stopTest();
            List <AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType='BatchApex' And Id =: jobId];
            System.assertEquals(jobs[0].Status, 'Completed');
            
        } catch(Exception e){
            System.debug('Error in batch: ' + e.getMessage());
        }
    }
}