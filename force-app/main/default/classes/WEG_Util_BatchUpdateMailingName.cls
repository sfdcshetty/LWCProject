global class WEG_Util_BatchUpdateMailingName implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        // get Household record type
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        return Database.getQueryLocator('SELECT Id FROM Account WHERE RecordTypeId = :householdRecordTypeId AND WEG_Informal_Household_Mailing_Name__c = \'\'');
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        // iterate the household accounts, gathering the account ids
        Set<Id> householdIds = new Set<Id>();
        for (Account acct : scope) {
            householdIds.add(acct.Id);
        }
        
        // update the mailing name for all households
        WEG_Util_UpdateMailingName mailingNameUtility = new WEG_Util_UpdateMailingName();
        try { mailingNameUtility.updateHouseholds(householdIds); } catch(Exception ex) { system.debug('>>>>>>>> ERROR :: Update Households Utility. :: ' + ex.getMessage()); }
    }
    
    global void finish(Database.BatchableContext BC){
        // 
    }
}