global class IndvidualAccount_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {

        CheckOwnershipofindividualaccounts batch = new CheckOwnershipofindividualaccounts ();
        ID batchprocessid = Database.executeBatch(batch);           
    }
}