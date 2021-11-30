public without sharing class x7sInvestmentController {

    @AuraEnabled (cacheable=true)
    public static List<FinServ__FinancialAccount__c> getInvestmentDetails(String accountId){
        
        List<FinServ__FinancialAccount__c> invAccList;
        
        if(accountId != null){
            
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
           		
               invAccList = [SELECT Id,Name, FinServ__FinancialAccountNumber__c,
                             WEG_Custodian__c, WEGP1_Owner_Type__c, 
                             WEG_As_of_Date__c, FinServ__Balance__c,WEG_Registration_Type__c,
                             FinServ__Household__c, WEG_Account__c,FinServ__FinancialAccountType__c
                             FROM FinServ__FinancialAccount__c
                             WHERE FinServ__Household__c = :accList[0].WEGP1_Primary_Household__c 
                             AND RecordType.Name IN('Advisory Investment Account','Annuity Investment Account','Brokerage Investment Account','ERP Investment Account','Investment Account') 
                             AND Remove_or_Historic__c = ''
                             //AND WEG_External_Rec_ID__c != '' //Commented Janavi Trivedi
                             AND FinServ__HeldAway__c = FALSE
                             AND FinServ__Status__c = 'Open'
                             AND WEGP1_ExcludeFromReview__c = false];
            }
            
        }
        return invAccList;
    }
}