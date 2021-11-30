/*
Created Date: 13/07/2020
Description: To update the Custodian Info field in Financial Account Servicing  whenever the FAS record is created or modified.
Test class: QuikFormHandler_Test
*/
trigger Quik_FASCustodianInfoUpdate on Financial_Account_Servicing__c (before insert, before update) {
    
    Set<String> custodianValues = new Set<String>();
    List<Custodian_Info__c> custodianInfoRecords = new List<Custodian_Info__c>();
    
    for(Financial_Account_Servicing__c fas : Trigger.new) {
        custodianValues.add(fas.WEG_Custodian__c);
    }
    
    custodianInfoRecords = [SELECT Custodian_Name__c FROM Custodian_Info__c WHERE Custodian_Name__c IN :custodianValues];
    
    if(custodianInfoRecords.size() > 0) {
        for(Financial_Account_Servicing__c fas : Trigger.new) {
            for(Custodian_Info__c cusInfo : custodianInfoRecords) {
                if(fas.WEG_Custodian__c == cusInfo.Custodian_Name__c) {
                    fas.WEG_Custodian_Info__c = cusInfo.Id;
                }
            }
        }
    }
}