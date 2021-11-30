public class WEG_FinAccountServicingTriggerHandler {
    
    /* ******************************* PUBLIC METHODS ******************************* */
    public void afterInsert(List<Financial_Account_Servicing__c> fasList) {
        system.debug('>>>>>>>> WEG_FinAccountServicingTriggerHandler.afterInsert');
        
        Map<Id, Id> fasFaMap = new Map<Id, Id>();
        Id beneUpdateRecordType = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Beneficiary Update').getRecordTypeId();
        for (Financial_Account_Servicing__c fas : fasList) {
            system.debug('>>>>>>>> FAS: ' + fas);
            
            if (fas.RecordTypeId == beneUpdateRecordType && fas.Financial_Account__c != null) {
                fasFaMap.put(fas.Id, fas.Financial_Account__c);
            }
        }
        
        if (!fasFaMap.isEmpty())
            updateFasBeneficiary(fasFaMap);
    }
    
    public void afterUpdate(List<Financial_Account_Servicing__c> fasList, Map<Id, Financial_Account_Servicing__c> oldFasMap) {
        system.debug('>>>>>>>> WEG_FinAccountServicingTriggerHandler.afterUpdate');
        
        List<Id> accountServicingIds = new List<Id>();
        List<Financial_Account_Servicing__c> compBeneFasList = new List<Financial_Account_Servicing__c>();
        List<Id> finAcctIds = new List<Id>();
        Id beneUpdateRecordType = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Beneficiary Update').getRecordTypeId();
        for (Financial_Account_Servicing__c fas : fasList) {
            system.debug('>>>>>>>> FAS: ' + fas);
            
            // get the old fas
            Financial_Account_Servicing__c oldFas = oldFasMap.get(fas.Id);
            
            // when fas is completed, later check for all fas being completed for AS
            if (oldFas.Status__c != 'Complete' && fas.Status__c == 'Complete') {
                accountServicingIds.add(fas.Account_Servicing__c);
            }
            
            // only when the beneficiary fas has been completed
            if (fas.RecordTypeId == beneUpdateRecordType && fas.Financial_Account__c != null && oldFas.Status__c != 'Complete' && fas.Status__c == 'Complete') {
                compBeneFasList.add(fas);
                finAcctIds.add(fas.Financial_Account__c);
            }
        }
        
        if (!accountServicingIds.isEmpty())
            updateAccountServicingToComplete(accountServicingIds);
        
        if (!compBeneFasList.isEmpty())
            updateFaRoles(compBeneFasList, finAcctIds);
    }
    
    /* ******************************* PRIVATE METHODS ******************************* */
    private void updateAccountServicingToComplete(List<Id> accountServicingIds) {
        // 
        List<Account_Servicing__c> accountServicings =
            [SELECT Id, WEG_Status__c
             , (SELECT Id, Status__c FROM Financial_Account_Servicing__r)
             FROM Account_Servicing__c
             WHERE Id IN :accountServicingIds];
        
        //
        List<Account_Servicing__c> completeAccountServicings = new List<Account_Servicing__c>();
        for (Account_Servicing__c aServ : accountServicings) {
            if (aServ.WEG_Status__c != 'Complete') {
                boolean atLeastOneFasIncomplete = false;
                for (Financial_Account_Servicing__c fas : aServ.Financial_Account_Servicing__r) {
                    if (fas.Status__c != 'Complete')
                        atLeastOneFasIncomplete = true;
                }
                
                if (!atLeastOneFasIncomplete) {
                    aServ.WEG_Status__c = 'Complete';
                    completeAccountServicings.add(aServ);
                }
            }
        }
        
        if (!completeAccountServicings.isEmpty())
            update completeAccountServicings;
    }
    
    private void updateFaRoles(List<Financial_Account_Servicing__c> compBeneFasList, List<Id> finAcctIds) {
        
        // get the map of financial accounts to their roles
        Map<Id, List<FinServ__FinancialAccountRole__c>> faRoleMap = getFaRoleMap(finAcctIds);
        
        List<FinServ__FinancialAccountRole__c> faRolesToDelete = new List<FinServ__FinancialAccountRole__c>();
        List<FinServ__FinancialAccountRole__c> faRolesToCreate = new List<FinServ__FinancialAccountRole__c>();
        Id acctRoleRecordType = Schema.SObjectType.FinServ__FinancialAccountRole__c.getRecordTypeInfosByName().get('Account Role').getRecordTypeId();
        for (Financial_Account_Servicing__c fas : compBeneFasList) {
            // get the beneficiary roles
            List<FinServ__FinancialAccountRole__c> finAcctRoles = faRoleMap.get(fas.Financial_Account__c);
            faRolesToDelete.addAll(finAcctRoles);
            
            for (integer i = 1; i < 7; i++) {
                Id beneficiaryAccountId = (Id)fas.get('WEG_Beneficiary_' + i + '_Name__c');
                if (beneficiaryAccountId != null) {
                    FinServ__FinancialAccountRole__c newFaRole = new FinServ__FinancialAccountRole__c(
                        RecordTypeId = acctRoleRecordType,
                        FinServ__RelatedAccount__c = beneficiaryAccountId,
                        FinServ__FinancialAccount__c = fas.Financial_Account__c,
                        FinServ__Role__c = (string)fas.get('WEG_Beneficiary_' + i + '_Role__c'),
                        WEG_Per_Share__c = (decimal)fas.get('WEG_Beneficiary_' + i + '_Share__c'),
                        WEG_Per_Stirpes__c = (boolean)fas.get('WEG_Beneficiary_' + i + '_Per_Stirpes__c')
                    );
                    faRolesToCreate.add(newFaRole);
                }
            }
        }
        
        insert faRolesToCreate;
        delete faRolesToDelete;
    }
    
    private Map<Id, List<FinServ__FinancialAccountRole__c>> getFaRoleMap(List<Id> finAcctIds) {
        // initialize the map
        Map<Id, List<FinServ__FinancialAccountRole__c>> faRoleMap = new Map<Id, List<FinServ__FinancialAccountRole__c>>();
        for (Id finAcctId : finAcctIds) {
            // add the financial account id only once
            if (!faRoleMap.containsKey(finAcctId))
                faRoleMap.put(finAcctId, new List<FinServ__FinancialAccountRole__c>());
        }
        
        // get all beneficiary roles related to the financial accounts
        List<FinServ__FinancialAccountRole__c> faRoles =
            [SELECT Id, FinServ__FinancialAccount__c, FinServ__Role__c, WEG_Per_Share__c, WEG_Per_Stirpes__c
             , FinServ__RelatedContact__c, FinServ__RelatedContact__r.AccountId, FinServ__RelatedAccount__c
             FROM FinServ__FinancialAccountRole__c
             WHERE FinServ__FinancialAccount__c IN :finAcctIds AND FinServ__Role__c IN ('Beneficiary', 'Contingent Beneficiary') AND FinServ__Active__c = true];
        
        // build the map of financial accounts to their roles
        for (FinServ__FinancialAccountRole__c faRole : faRoles) {
            // add the role to the financial account
            faRoleMap.get(faRole.FinServ__FinancialAccount__c).add(faRole);
        }
        
        return faRoleMap;
    }
    
    private void updateFasBeneficiary(Map<Id, Id> fasFaMap) {
        
        // get the fas list
        List<Financial_Account_Servicing__c> fasList =
            [SELECT Id, Financial_Account__c
             , WEG_Beneficiary_1_Name__c, WEG_Beneficiary_1_Role__c, WEG_Beneficiary_1_Type__c, WEG_Beneficiary_1_Share__c, WEG_Beneficiary_1_Per_Stirpes__c
             , WEG_Beneficiary_2_Name__c, WEG_Beneficiary_2_Role__c, WEG_Beneficiary_2_Type__c, WEG_Beneficiary_2_Share__c, WEG_Beneficiary_2_Per_Stirpes__c
             , WEG_Beneficiary_3_Name__c, WEG_Beneficiary_3_Role__c, WEG_Beneficiary_3_Type__c, WEG_Beneficiary_3_Share__c, WEG_Beneficiary_3_Per_Stirpes__c
             , WEG_Beneficiary_4_Name__c, WEG_Beneficiary_4_Role__c, WEG_Beneficiary_4_Type__c, WEG_Beneficiary_4_Share__c, WEG_Beneficiary_4_Per_Stirpes__c
             , WEG_Beneficiary_5_Name__c, WEG_Beneficiary_5_Role__c, WEG_Beneficiary_5_Type__c, WEG_Beneficiary_5_Share__c, WEG_Beneficiary_5_Per_Stirpes__c
             , WEG_Beneficiary_6_Name__c, WEG_Beneficiary_6_Role__c, WEG_Beneficiary_6_Type__c, WEG_Beneficiary_6_Share__c, WEG_Beneficiary_6_Per_Stirpes__c
             FROM Financial_Account_Servicing__c
             WHERE Id IN :fasFaMap.keySet()];
        
        // get the map of financial accounts to their roles
        Map<Id, List<FinServ__FinancialAccountRole__c>> faRoleMap = getFaRoleMap(fasFaMap.values());
        
        for (Financial_Account_Servicing__c fas : fasList) {
            // get the beneficiary roles
            List<FinServ__FinancialAccountRole__c> finAcctRoles = faRoleMap.get(fas.Financial_Account__c);
            
            integer i = 1;
            for (FinServ__FinancialAccountRole__c finAcctRole : finAcctRoles) {
                if (finAcctRole.FinServ__RelatedContact__c != null)
                    fas.put('WEG_Beneficiary_' + i + '_Name__c', finAcctRole.FinServ__RelatedContact__r.AccountId);
                else
                    fas.put('WEG_Beneficiary_' + i + '_Name__c', finAcctRole.FinServ__RelatedAccount__c);
                fas.put('WEG_Beneficiary_' + i + '_Role__c', finAcctRole.FinServ__Role__c);
                //WEG_Beneficiary_1_Type__c
                fas.put('WEG_Beneficiary_' + i + '_Share__c', finAcctRole.WEG_Per_Share__c);
                fas.put('WEG_Beneficiary_' + i + '_Per_Stirpes__c', finAcctRole.WEG_Per_Stirpes__c);
                
                if (i != 6)
                    i++; // increment
            }
        }
        
        update fasList;
    }
}