/*
    Name : CheckOwnerShipOfFinancialAccounts
    TestClassName : CheckOwnerShipOfFinancialAccounts_TC
    ScheduleClassName : FinancialAccount_Scheduler
    Developer Name: K P Sai Sampath
    Reviewed by : Srikanth Valluri
    Description : 1)Update Financial Account Owner values from FinServ__Household__c  field(Owner) if  hosuehold owner's profile = "Advisor".
                  2).If  FinServ__Household__c field owner's profile not equal to ""Advisor"" ,
                    get the owner value from Finserv__Primary_Owner__c field  if primary owner's profile = "Advisor""
*/

global class CheckOwnerShipOfFinancialAccounts implements Database.Batchable<SObject>, Database.Stateful{
  
    global Database.queryLocator start(Database.BatchableContext ctx){
        
        String query = 'SELECT OwnerId, Owner.Profile.Name, FinServ__Household__c, FinServ__Household__r.OwnerId, FinServ__Household__r.Owner.Profile.Name, '
                    + 'FinServ__PrimaryOwner__c, FinServ__PrimaryOwner__r.OwnerId, FinServ__PrimaryOwner__r.Owner.Profile.Name '
                    + 'FROM FinServ__FinancialAccount__c '
                    + 'WHERE WEG_Household_Owner_Override__c = false';

        System.debug('>>>>>>>> Batch Query: ' + query);
        
        return Database.getQueryLocator(query);
    }                
    
    global void execute(Database.BatchableContext ctx, List<FinServ__FinancialAccount__c> scope){
        List<FinServ__FinancialAccount__c> finacclist = new List<FinServ__FinancialAccount__c>();
        
        for(FinServ__FinancialAccount__c finacc : scope) {
            
            if (finacc.FinServ__Household__c != null
            && finacc.FinServ__Household__r.Owner.Profile.Name == System.label.Profile_name
            && finacc.OwnerId != finacc.FinServ__Household__r.OwnerId) {
                finacc.OwnerId = finacc.FinServ__Household__r.OwnerId;
                finacclist.add(finacc);
                System.debug('>>>>>>>> Adding Financial Account to Update.');
            }
            else if (finacc.FinServ__PrimaryOwner__c != null
            && finacc.FinServ__PrimaryOwner__r.Owner.Profile.Name == System.Label.Profile_Name
            && finacc.OwnerId != finacc.FinServ__PrimaryOwner__r.OwnerId) {
                finacc.OwnerId = finacc.FinServ__PrimaryOwner__r.OwnerId;
                finacclist.add(finacc);
                System.debug('>>>>>>>> Adding Financial Account to Update.');
            }
                               
        }
        
        try {
            if (finacclist.size () > 0)
                update finacclist;
        }
        catch(Exception e) {
            System.debug('>>>>>>>> Error Updating Financial Accounts :: ' + e.getMessage());
        }       
    }
    
    global void finish(Database.BatchableContext ctx){
    }
}