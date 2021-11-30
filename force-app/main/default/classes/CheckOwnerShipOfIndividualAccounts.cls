/*
    Name : CheckOwnerShipOfIndividualAccounts
    TestClassName : CheckOwnerShipOfIndividualAccounts_TC
    ScheduleClassName : IndividualAccount_Scheduler
    Developer Name: K P Sai Sampath
    Reviewed by : Srikanth Valluri
    Description : 1).Update Individual Account Owner values from Primary House Hold field (Owner) if the household owner profiles is "Advisor"
                  2)Send Chatter post to record owner if  primary hosehold owner profile is not Advisor.
                    and Condition is Account recordtype should be Individual"
*/

global class CheckOwnerShipOfIndividualAccounts implements Database.Batchable<SObject>{
    
    
    global Database.queryLocator start(Database.BatchableContext ctx){
        
        String recordType = System.label.Individual_RecordType;

        String query = 'SELECT ownerid, owner.profile.Name, RecordType.Name, WEGP1_Primary_Household__c, '
                    + 'WEGP1_Primary_Household__r.ownerid, WEGP1_Primary_Household__r.Owner.Profile.Name '
                    + 'FROM Account '
                    + 'WHERE recordtype.Name = :recordType';
        
        System.debug('>>>>>>>> Batch Query: ' + query);
        
        return Database.getQueryLocator(query);
    }                
    
    global void execute(Database.BatchableContext ctx, List<Account> scope){
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc:scope) {            
            System.Debug('>>>>>>>> Individual Account Id: ' + acc.ID);
            System.Debug('>>>>>>>> Primary Household Id: ' + acc.WEGP1_Primary_Household__c);
            System.Debug ('>>>>>>>> Individual Account Owner Profile: ' + acc.Owner.Profile.Name);
            
            if (acc.WEGP1_Primary_Household__c != NULL) {
                System.Debug ('>>>>>>>> Primary Household Owner Profile: ' + acc.WEGP1_Primary_Household__r.Owner.Profile.Name);
                
                if (acc.OwnerID != acc.WEGP1_Primary_Household__r.OwnerID
                    && acc.WEGP1_Primary_Household__r.Owner.Profile.Name == Label.Profile_Name) {
                    acc.OwnerId = acc.WEGP1_Primary_Household__r.OwnerID;
                    accountsToUpdate.add(acc);
                    System.debug('>>>>>>>> Adding Account to Update.');
                }
            }
        }
        
        try {
            if (accountsToUpdate.size () > 0)
                update accountsToUpdate;
        }
        catch (Exception e) {
            System.debug('>>>>>>>> Error Updating Individual Accounts :: ' + e.getMessage());
        }
    }    
    global void finish(Database.BatchableContext ctx){
    }
}