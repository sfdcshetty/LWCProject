public class WEG_FinancialAccountTriggerHandler {
    public void beforeInsert(List<FinServ__FinancialAccount__c> newFinancialAccounts) {
        
        for (FinServ__FinancialAccount__c fa : newFinancialAccounts) {
            
            // sync primary owner/household to account
            if (fa.FinServ__Household__c != null)
                fa.WEG_Account__c = fa.FinServ__Household__c;
            else
                fa.WEG_Account__c = fa.FinServ__PrimaryOwner__c;
        }
    }
    
    public void beforeUpdate(List<FinServ__FinancialAccount__c> newFinancialAccounts, Map<Id, FinServ__FinancialAccount__c> oldFinancialAccountMap) {
        
        for (FinServ__FinancialAccount__c fa : newFinancialAccounts) {
            FinServ__FinancialAccount__c oldFA = oldFinancialAccountMap.get(fa.Id);
            
            if (fa.FinServ__PrimaryOwner__c != oldFA.FinServ__PrimaryOwner__c || fa.FinServ__Household__c != oldFA.FinServ__Household__c) {
                // sync primary owner/household to account
                if (fa.FinServ__Household__c != null)
                    fa.WEG_Account__c = fa.FinServ__Household__c;
                else
                    fa.WEG_Account__c = fa.FinServ__PrimaryOwner__c;
            }
        }
    }
    
    public void afterUpdate(List<FinServ__FinancialAccount__c> newFinancialAccounts, Map<Id, FinServ__FinancialAccount__c> oldFinancialAccountMap) {
        //Activate_FINACC_AND_ATTACH_TRIGGER__c active = new Activate_FINACC_AND_ATTACH_TRIGGER__c();
        //active.Activate_FINACC__c = true;
                
        // collect up the Ids
        Set<Id> finAcctIds = new Set<Id>();
        for (FinServ__FinancialAccount__c fa : newFinancialAccounts)
            finAcctIds.add(fa.Id);
        
        // query the financial accounts
        List<FinServ__FinancialAccount__c> financialAccounts =
            [SELECT Id, FinServ__CloseDate__c, Finserv__Status__c, FinServ__Balance__c, WEGP1_AccumulationValue__c, RecordType.Name, FinServ__Household__c
             , WEG_External_Rec_ID__c, WEGP1_Closing_Value__c, WEGP1_ExcludeFromReview__c, Remove_or_Historic__c, WEG_Electronic_Prospectus_Delivery__c
             FROM FinServ__FinancialAccount__c
             WHERE ID IN :finAcctIds];
        
        List<String> closedStatuses = new List<String>{'Cancelled', 'Withdrawn', 'Declined', 'Closed'};
        
        // 
        List<FinServ__FinancialAccount__c> affectedFinAccts = new List<FinServ__FinancialAccount__c>();
        List<Id> affectedHouseholdIds = new List<Id>();
        for (FinServ__FinancialAccount__c fa : financialAccounts) {
            FinServ__FinancialAccount__c oldFA = oldFinancialAccountMap.get(fa.Id);
            boolean finAcctChanged = false;
            
            // ensure the financial account is open if it should be
            if (fa.FinServ__CloseDate__c == NULL && fa.Finserv__Status__c != 'Open' && fa.FinServ__Balance__c > 0 && fa.WEG_External_Rec_ID__c != '') {
                fa.Finserv__Status__c = 'Open';
                finAcctChanged = true;
            }
             
            // ensure the financial account is closed if it should be
            else if (fa.FinServ__CloseDate__c < Date.Today() && fa.FinServ__Status__c != 'Closed' && fa.FinServ__Balance__c == 0 && fa.WEG_External_Rec_ID__c != '' && fa.WEGP1_Closing_Value__c >= 0) {
                fa.Finserv__Status__c = 'Closed';
                fa.WEGP1_ExcludeFromReview__c = true;
                finAcctChanged = true;
            }
            
            // 'STATUS' CHANGED
            // ensure the financial account is excluded from review if it should be
            // if the Status changed to something Closed AND Remove or Historic or Remove isn't set properly, set it
            else if (fa.FinServ__Status__c != oldFA.FinServ__Status__c && closedStatuses.contains(fa.FinServ__Status__c) && string.isEmpty(fa.Remove_or_Historic__c)) {
                fa.Remove_or_Historic__c = 'Transfer to Historic';
                fa.WEGP1_ExcludeFromReview__c = true;
                finAcctChanged = true;
            }
            
            // 'REMOVE OR HISTORIC' CHANGED
            else if (fa.Remove_or_Historic__c != oldFA.Remove_or_Historic__c && string.isNotEmpty(fa.Remove_or_Historic__c) && !fa.WEGP1_ExcludeFromReview__c) {
                fa.WEGP1_ExcludeFromReview__c = true;
                finAcctChanged = true;
            }
            
            // 'ACCUMULATION VALUE' CHANGED
            if (fa.RecordType.Name == 'Insurance Policy' && fa.WEGP1_AccumulationValue__c != oldFA.WEGP1_AccumulationValue__c
                && fa.WEGP1_AccumulationValue__c != null && fa.FinServ__Balance__c == null && UserInfo.getUserName() != 'api@wealthenhancement.com') {
                fa.FinServ__Balance__c = fa.WEGP1_AccumulationValue__c;
                finAcctChanged = true;
            }
            
            // add the financial account to the affected list for later update if changed
            if (finAcctChanged)
                affectedFinAccts.add(fa);
            
            // 'ELECTRONIC PROSPECTUS DELIVERY' CHANGED TO CHECKED
            if (fa.WEG_Electronic_Prospectus_Delivery__c && !oldFA.WEG_Electronic_Prospectus_Delivery__c
                && fa.FinServ__Household__c != null && UserInfo.getUserName() != 'api@wealthenhancement.com') {
                affectedHouseholdIds.add(fa.FinServ__Household__c);
            }
        }
        
        // update the affected financial accounts (if applicable)
        if (!affectedFinAccts.isEmpty())
            update affectedFinAccts;
        
        // 
        if (!affectedHouseholdIds.isEmpty()) {
            // get the households for Electronic Prospectus Delivery
            List<Account> households = [SELECT Id, WEG_Electronic_Prospectus_Delivery__c
                                        FROM Account
                                        WHERE Id IN :affectedHouseholdIds];
            // iterate the households, setting the prospectus delivery
            for (Account hh : households) {
                hh.WEG_Electronic_Prospectus_Delivery__c = true;
            }
            
            // update the households
            update households;
        }
    }
}