public with sharing class WEG_FAServicingFAListController {
    @AuraEnabled
    public static List<FinServ__FinancialAccount__c> getFinancialAccounts(string accountRecordId) {
        system.debug('>>>>>>>> accountRecordId: ' + accountRecordId);
        
        List<FinServ__FinancialAccount__c> financialAccounts =
            [SELECT Id, Name, FinServ__FinancialAccountNumber__c
             FROM FinServ__FinancialAccount__c
             WHERE (FinServ__PrimaryOwner__c = :accountRecordId OR FinServ__Household__c = :accountRecordId)
             AND RecordTypeId IN ('01241000001IhbxAAC', '01241000001IhbuAAC', '01241000001IhbuAAC', '01241000001IhbwAAC', '01241000000ygDGAAY', '01241000001IhbyAAC', '01241000001IhbvAAC')
             AND FinServ__Status__c IN ('Open', 'Draft')
             AND FinServ__HeldAway__c = false ];
        system.debug('>>>>>>>> financialAccounts: ' + financialAccounts);
        
        return financialAccounts;
    }
}