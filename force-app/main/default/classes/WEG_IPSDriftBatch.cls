public class WEG_IPSDriftBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        // return all households with AUM and any OPEN IPS Alerts
        Id hhRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id, WEG_IPS_Drift__c
                                        , (SELECT Id, WEG_Status__c FROM IPS_Alerts__r WHERE WEG_Status__c IN ('New', 'Exception'))
                                        FROM Account
                                        WHERE RecordTypeId = :hhRecordTypeId AND TamAdvisor__Updated_by_Tamarac_Integration__c = true AND WEGP1_Total_AUM__c > 0]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // get the min/max drift custom settings
        WEG_AccountConfiguration__c aConfig = WEG_AccountConfiguration__c.getOrgDefaults();
        decimal maxDrift = aConfig.WEG_MaxIPSDrift__c;
        decimal minDrift = aConfig.WEG_MinIPSDrift__c;
        
        // check each account
        List<IPS_Alert__c> ipsAlerts = new List<IPS_Alert__c>();
        for (Account acct : scope) {
            // if the account drift is outside the custom settings and no open alert exists
            if ((acct.WEG_IPS_Drift__c < minDrift || acct.WEG_IPS_Drift__c > maxDrift) && acct.IPS_Alerts__r.size() == 0) {
                // create an IPS Alert
                // record the current drift with a status of New
                IPS_Alert__c ipsAlert = new IPS_Alert__c(WEG_Household__c = acct.Id, WEG_Status__c = 'New', WEG_Drift_at_Alert__c = acct.WEG_IPS_Drift__c);
                ipsAlerts.add(ipsAlert);
            }
        }
        
        // create any IPS Alerts
        if (!ipsAlerts.isEmpty())
            insert ipsAlerts;
    }
    
    public void finish(Database.BatchableContext bc) {
    }
}