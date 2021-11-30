global class AccountOwnership_Scheduler implements Schedulable{    
    global void execute(SchedulableContext sc) {

        CheckOwnershipofaccounts batch = new CheckOwnershipofaccounts();
        ID batchprocessid = Database.executeBatch(batch,50);           
    }
}