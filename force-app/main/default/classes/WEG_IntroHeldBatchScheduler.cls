global class WEG_IntroHeldBatchScheduler implements Schedulable {
    
    // every day at 10:00 PM
    // seconds minutes hours dayOfMonth month dayOfWeek
    public static string CRON_EXP = '0 0 22 * * ?';
    
    global void execute(SchedulableContext sc) {
        
        // execute the intro held batch
        database.executeBatch(new WEG_IntroHeldBatch());
    }
}