/*
    Name : UpdateFinancialAccountStatus
    TestClassName : UpdateFinancialAccountStatus_TC
    Developer Name: K P Sai Sampath
    Reviewed by : Srikanth Valluri
    Description : "Trigger to Update Financial Status :
                   to Open if date closed = NULL  AND status <> Open AND balance > 0 AND  external rec id <> NULL .
                   to Closed if date closed < TODAY AND status <> Closed AND balance = 0 AND  external rec id <> NULL AND closing value >= 0 . 
                   and   Exclude From  Review flag  field to be true.

*/
trigger UpdateFinancialAccountStatus on FinServ__FinancialAccount__c (after update) {
    /*
    Activate_FINACC_AND_ATTACH_TRIGGER__c active = new Activate_FINACC_AND_ATTACH_TRIGGER__c();
    active.Activate_FINACC__c = true;
    
    // list of closed statuses
    List<String> closedStatuses = new List<String> {'Cancelled', 'Withdrawn', 'Declined', 'Closed'};
    
    // get the insurance type id
    Id insuranceTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Insurance Policy').getRecordTypeId();
    
    // iterate through the updated financial accounts, making the necessary changes
    List<FinServ__FinancialAccount__c> accountsToUpdate = new List<FinServ__FinancialAccount__c>();
    List<Id> householdsToUpdate = new List<Id>();
    for(FinServ__FinancialAccount__c a : [SELECT FinServ__CloseDate__c, Finserv__Status__c, FinServ__Balance__c, WEGP1_AccumulationValue__c, RecordTypeId
                                          , SkienceFinSln__External_Rec_Id__c, WEGP1_Closing_Value__c, WEGP1_ExcludeFromReview__c, Remove_or_Historic__c
                                          , WEG_Electronic_Prospectus_Delivery__c, FinServ__Household__c
                                          FROM FinServ__FinancialAccount__c
                                          WHERE ID IN :TRIGGER.NEW])
    {
        // ensure the financial account is open if it should be
        if (a.FinServ__CloseDate__c == NULL && a.Finserv__Status__c != 'Open' && a.FinServ__Balance__c > 0 && a.SkienceFinSln__External_Rec_Id__c != '') {
            a.Finserv__Status__c = 'Open';
            accountsToUpdate.add(a);
        }
        
        // ensure the financial account is closed if it should be
        else if (a.FinServ__CloseDate__c < Date.Today() && a.FinServ__Status__c != 'Closed' && a.FinServ__Balance__c == 0 && a.SkienceFinSln__External_Rec_Id__c != '' && a.WEGP1_Closing_Value__c >= 0) {
            a.Finserv__Status__c = 'Closed';
            a.WEGP1_ExcludeFromReview__c = true;
            accountsToUpdate.add(a);
        }
        
        // 'STATUS' CHANGED
        // ensure the financial account is excluded from review if it should be
        // if the Status changed to something Closed AND Remove or Historic or Remove isn't set properly, set it
        else if (a.FinServ__Status__c != ((FinServ__FinancialAccount__c)Trigger.oldMap.get(a.Id)).FinServ__Status__c
            && closedStatuses.contains(a.FinServ__Status__c) && string.isEmpty(a.Remove_or_Historic__c))
        {
            a.Remove_or_Historic__c = 'Transfer to Historic';
            a.WEGP1_ExcludeFromReview__c = true;
            accountsToUpdate.add(a);
        }
        
        // 'REMOVE OR HISTORIC' CHANGED
        else if (a.Remove_or_Historic__c != ((FinServ__FinancialAccount__c)Trigger.oldMap.get(a.Id)).Remove_or_Historic__c
            && string.isNotEmpty(a.Remove_or_Historic__c) && !a.WEGP1_ExcludeFromReview__c) {
            a.WEGP1_ExcludeFromReview__c = true;
            accountsToUpdate.add(a);
        }
        
        // 'ACCUMULATION VALUE' CHANGED
        if (a.RecordTypeId == insuranceTypeId && a.WEGP1_AccumulationValue__c != ((FinServ__FinancialAccount__c)Trigger.oldMap.get(a.Id)).WEGP1_AccumulationValue__c
            && a.WEGP1_AccumulationValue__c != null && a.FinServ__Balance__c == null && UserInfo.getUserName() != 'api@wealthenhancement.com') {
            a.FinServ__Balance__c = a.WEGP1_AccumulationValue__c;
            accountsToUpdate.add(a);
        }
        
        // 'ELECTRONIC PROSPECTUS DELIVERY' CHANGED TO CHECKED
        if (a.WEG_Electronic_Prospectus_Delivery__c && !((FinServ__FinancialAccount__c)Trigger.oldMap.get(a.Id)).WEG_Electronic_Prospectus_Delivery__c
            && UserInfo.getUserName() != 'api@wealthenhancement.com') {
            householdsToUpdate.add(a.FinServ__Household__c);
        }
    }
    
    if (accountsToUpdate.size() > 0)
        update accountsToUpdate;
    
    if (householdsToUpdate.size() > 0) {
        // get the households for Electronic Prospectus Delivery
        List<Account> households = [SELECT Id, WEG_Electronic_Prospectus_Delivery__c
                                   FROM Account
                                   WHERE Id IN :householdsToUpdate];
        // iterate the households, setting the prospectus delivery
        for (Account hh : households) {
            hh.WEG_Electronic_Prospectus_Delivery__c = true;
        }
        
        // update the households
        update households;
    }
	*/
}