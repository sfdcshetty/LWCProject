/**
 * Created by 7Summits on 6/10/21.
 */

public with sharing class x7s_UserPhotoRetrieveFromCMSScheduler implements Schedulable {
    public static final String CRON_EXPRESSION = '0 0 0 * * ?'; // every day at 12am

    /**
     * @description - Schedulable Execute method
     * @param sc
     */
    public void execute(SchedulableContext sc) { 
        x7s_UserPhotoRetrieveFromCMSBatch obj = new x7s_UserPhotoRetrieveFromCMSBatch(0);
        if(Test.isRunningTest()) {
            obj.runOnce = true;
        }
        Database.executeBatch(obj);
        //System.schedule('Scheduled Apex class: x7s_UserPhotoRetrieveFromCMSBatch', CRON_EXPRESSION, new x7s_UserPhotoRetrieveFromCMSBatch())
    }

    /**
     * @description - Schedulable Schedule method
     */
    public static void schedule(){
        schedule(null);
    }

    /**
     * @description - Schedulable Schedule method
     * @param cron - used for specifying time period to repeat on
     */
    public static void schedule(String cron) {
        if (String.isBlank(cron)) {
            cron = CRON_EXPRESSION;
        }
        List<CronTrigger> existingCronTriggers = [
                SELECT Id, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE '%x7s_UserPhotoRetrieveFromCMSScheduler%'
        ];
        Decimal existingCronTriggerCount = existingCronTriggers.size();
        Boolean isExistingJobRunning = existingCronTriggerCount > 0;
        if (!isExistingJobRunning) {
            System.schedule('Scheduled Apex class: x7s_UserPhotoRetrieveFromCMSScheduler', cron, new x7s_UserPhotoRetrieveFromCMSScheduler());
        }
    }
}