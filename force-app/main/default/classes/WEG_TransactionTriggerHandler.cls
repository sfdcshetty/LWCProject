public class WEG_TransactionTriggerHandler {
    public void beforeInsert() {
        // get the Manual Transaction record type Id
        Id manualRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('Manual Transaction').getRecordTypeId();
        
        // iterate the inserted transactions
        for (WEG_Transaction__c trans : (List<WEG_Transaction__c>)Trigger.new) {
            // only make changes to manual transactions
            if (trans.RecordTypeId == manualRecordTypeId) {
                // set the Transaction Type to Revenue
                System.debug('>>>>>>>> Setting Type to Revenue for Manual Transaction: ' + trans.Id);
                trans.Transaction_Type__c = 'Revenue';
            }
        }
    }
    
    public void beforeDelete() {
        // get the Manual Transaction record type Id
        Id manualRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('Manual Transaction').getRecordTypeId();
        
        // iterate the deleted records
        for (WEG_Transaction__c trans : (List<WEG_Transaction__c>)Trigger.old) {
            // only manual transactions can be deleted
            if (userinfo.getProfileId() != '00e41000001hVfjAAE' && trans.RecordTypeId != manualRecordTypeId) {
                trans.addError('>>>>>>>> Error :: Only transactions of record type Manual Transaction can be deleted.');
            }
        }
    }
    
    private Set<Id> transactionIds = new Set<Id>();    
    private Set<Id> needsProductGL = new Set<Id>();
    private Set<Id> needsAcctNumber = new Set<Id>();
    private Set<Id> needsRepGL = new Set<Id>();
    private Set<Id> needsHouseholdGL = new Set<Id>();
    private Set<Id> needsClientTenure = new Set<Id>();
    
    public void afterInsert() {
        // get the record type Ids
        Id manualRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('Manual Transaction').getRecordTypeId();
        Id lplRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('LPL Transaction').getRecordTypeId();
        
        for (WEG_Transaction__c trans : (List<WEG_Transaction__c>)Trigger.new) {
            // only process Gl if it's not Salesfore Admin inserting the record
            //if (UserInfo.getUserId() != '00541000002a4uYAAQ') {
            
            // determine need for Product GL, regardless of Record Type
            if (trans.Product__c != null)
                needsProductGL.add(trans.Id);
            
            // determine need for Fin Acct Number
            if (trans.Financial_Account__c != null && trans.RecordTypeId == manualRecordTypeId)
                needsAcctNumber.add(trans.Id);
                
            // determine need for User GL
            if (trans.RepCode__c != null && trans.RecordTypeId == lplRecordTypeId)
                needsRepGL.add(trans.Id);
            else if (trans.Household__c != null && trans.RecordTypeId != lplRecordTypeId)
                needsHouseholdGL.add(trans.Id);
            //}
            
            // determine need for Client Tenure, regardless of Record Type
            if (trans.Household__c != null)
                needsClientTenure.add(trans.Id);
            
            transactionIds.add(trans.Id);
        }
        
        processTransactions();
    }
    
    public void afterUpdate() {
        // get the Manual Transaction record type Id
        Id manualRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('Manual Transaction').getRecordTypeId();
        Id lplRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('LPL Transaction').getRecordTypeId();
        
        for (WEG_Transaction__c trans : (List<WEG_Transaction__c>)Trigger.new) {
            // get old transaction
            WEG_Transaction__c oldTrans = (WEG_Transaction__c)Trigger.oldMap.get(trans.Id);
            
            // only process Gl if it's not Salesfore Admin updating the record
            //if (UserInfo.getUserId() != '00541000002a4uYAAQ') {
            
            // determine need for Product GL, regardless of Record Type
            if (trans.Product__c != oldTrans.Product__c) {
                needsProductGL.add(trans.Id);
                transactionIds.add(trans.Id);
            }
            
            // determine need for Fin Acct Number, regardless of Record Type
            if (trans.Financial_Account__c != oldTrans.Financial_Account__c) {
                needsAcctNumber.add(trans.Id);
                transactionIds.add(trans.Id);
            }
            
            // determine need for User GL
            if (trans.RepCode__c != oldTrans.RepCode__c && trans.RecordTypeId == lplRecordTypeId) {
                needsRepGL.add(trans.Id);
                transactionIds.add(trans.Id);
            }
            else if (trans.Household__c != oldTrans.Household__c && trans.RecordTypeId != lplRecordTypeId) {
                needsHouseholdGL.add(trans.Id);
                transactionIds.add(trans.Id);
            }
            //}
            
            // determine need for Client Tenure, regardless of Record Type
            if (trans.Household__c != oldTrans.Household__c || trans.Pay_Period__c != oldTrans.Pay_Period__c) {
                needsClientTenure.add(trans.Id);
                transactionIds.add(trans.Id);
            }
        }
        
        if (!transactionIds.isEmpty())
        	processTransactions();
    }
    
    private void processTransactions() {
        // query the transactions and all related info
        List<WEG_Transaction__c> transactions =
            [SELECT Id, RecordTypeId, GL_Account__c, GL_Product_Line__c, GL_Department__c, GL_Location__c, FA_Code__c
             , Account_Number__c, Client_Tenure__c
             , Product__r.WEG_GLRevenueAcct__c, Product__r.WEG_GLProductLine__c
             , Financial_Account__r.FinServ__FinancialAccountNumber__c
             , RepCode__r.WEG_Primary_User__r.WEG_FACode__c, RepCode__r.WEG_Primary_User__r.WEG_GLDepartment__c, RepCode__r.WEG_Primary_User__r.WEG_GLLocation__c
             , Household__r.Owner.WEG_GLDepartment__c, Household__r.Owner.WEG_GLLocation__c, Household__r.Owner.WEG_FACode__c, Household__r.WEGP1_ClientAnniversaryDate__c
             , Pay_Period__r.WEG_PeriodEndDate__c
             FROM WEG_Transaction__c
             WHERE Id IN :transactionIds];
        
        // 
        for (WEG_Transaction__c trans : transactions) {
            
            // update the Account Number (where applicable)
            if (needsAcctNumber.contains(trans.Id))
                trans.Account_Number__c = trans.Financial_Account__r.FinServ__FinancialAccountNumber__c;
            
            // update the Product GL (where applicable)
            if (needsProductGL.contains(trans.Id)) {
                system.debug('>>>>>>>> Transaction needs Product GL');
                system.debug('>>>>>>>> GL_Account will be: ' + trans.Product__r.WEG_GLRevenueAcct__c);
                trans.GL_Account__c = trans.Product__r.WEG_GLRevenueAcct__c;
                trans.GL_Product_Line__c = trans.Product__r.WEG_GLProductLine__c;
            }
            
            // update User GL (where applicable)
            if (needsRepGL.contains(trans.Id)) {
                // update GL based on Rep Code
                trans.GL_Department__c = trans.RepCode__r.WEG_Primary_User__r.WEG_GLDepartment__c;
                trans.GL_Location__c = trans.RepCode__r.WEG_Primary_User__r.WEG_GLLocation__c;
                trans.FA_Code__c = trans.RepCode__r.WEG_Primary_User__r.WEG_FACode__c;
            }
            else if (needsHouseholdGL.contains(trans.Id)) {
                // update GL based on Household
                trans.GL_Department__c = trans.Household__r.Owner.WEG_GLDepartment__c;
                trans.GL_Location__c = trans.Household__r.Owner.WEG_GLLocation__c;
                trans.FA_Code__c = trans.Household__r.Owner.WEG_FACode__c;
            }
            
            // update Client Tenure (where applicable)
            if (needsClientTenure.contains(trans.Id) && trans.Household__r.WEGP1_ClientAnniversaryDate__c != null && trans.Pay_Period__r.WEG_PeriodEndDate__c != null)
                trans.Client_Tenure__c = getClientTenure(trans.Household__r.WEGP1_ClientAnniversaryDate__c, trans.Pay_Period__r.WEG_PeriodEndDate__c);
        }
        
        try {
        	update transactions;
        }
        catch (Exception ex) {
            system.debug('>>>>>>>> ERROR :: ' + ex.getMessage());
        }
    }
    
    // FLOOR(End of month (Pay Period) - End of month (Client Anniversary) / 365)
    private double getClientTenure(Date clientAnniversary, Date payPeriod) {
        // get the last day of the month for Client Anniversary Date
        Integer numberOfDaysCA = Date.daysInMonth(clientAnniversary.year(), clientAnniversary.month());
        Date lastDayOfMonthCA = Date.newInstance(clientAnniversary.year(), clientAnniversary.month(), numberOfDaysCA);
        // get the last day of the month for Pay Period
        Integer numberOfDaysPP = Date.daysInMonth(payPeriod.year(), payPeriod.month());
        Date lastDayOfMonthPP = Date.newInstance(payPeriod.year(), payPeriod.month(), numberOfDaysPP);
        // get the days between the two month-end dates
        integer daysBetween = lastDayOfMonthCA.daysBetween(lastDayOfMonthPP);
        // Tenure is the floor of the number of years between
        return math.floor(math.abs(daysBetween) / 365);
    }
}