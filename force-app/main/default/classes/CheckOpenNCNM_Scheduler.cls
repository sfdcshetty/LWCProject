global class CheckOpenNCNM_Scheduler implements Schedulable {
    
    // every day at 5:00 AM
    // seconds minutes hours dayOfMonth month dayOfWeek
    public static string CRON_EXP = '0 0 5 * * ?';
    
    global void execute(SchedulableContext sc) {
        
        // execute the batch
        database.executeBatch(new CheckOpenNCNM());
    }
}