global class FinancialAccount_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {

        CheckOwnershipoffinancialaccounts batch = new CheckOwnershipoffinancialaccounts();
        ID batchprocessid = Database.executeBatch(batch,50);           
    }
}