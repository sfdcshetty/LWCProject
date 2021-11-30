global class WEG_IPSDriftScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // execute Batch class with the default batch size
        Database.executeBatch(new WEG_IPSDriftBatch());
   }
}