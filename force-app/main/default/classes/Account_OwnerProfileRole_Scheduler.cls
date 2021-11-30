/*
 *	Test Class Name: Account_OwnerProfileRole_Scheduler_TC 
*/
global class Account_OwnerProfileRole_Scheduler implements Schedulable{    
    global void execute(SchedulableContext sc) {

        CheckAdvisorRoleOfIndividualAccounts batch = new CheckAdvisorRoleOfIndividualAccounts();
        ID batchprocessid = Database.executeBatch(batch,50);           
    }
}