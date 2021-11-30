public without sharing class x7sMyWealthListViewController {

    @AuraEnabled (cacheable=true)
    public static List<FinServ__FinancialAccount__c> getInvestmentDetails(String accountId){
        
        List<FinServ__FinancialAccount__c> invAccList;
        
        if(accountId != null){
            
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
           		
               invAccList = [SELECT Name, FinServ__FinancialAccountType__c, 
                             WEG_Custodian__c, WEGP1_Owner_Type__c, 
                             WEG_As_of_Date__c, FinServ__Balance__c,
                             FinServ__Household__c, WEG_Account__c
                             FROM FinServ__FinancialAccount__c
                             WHERE FinServ__Household__c = :accList[0].WEGP1_Primary_Household__c 
                             AND RecordType.Name IN('Advisory Investment Account','Annuity Investment Account','Brokerage Investment Account','ERP Investment Account','Investment Account') 
                             AND Remove_or_Historic__c = ''];
            }
            
        }
        return invAccList;
    }
    
    @AuraEnabled (cacheable=true)
    public static List<FinServ__AssetsAndLiabilities__c > getPersonalPropertyDetails(String accountId){
        
        List<FinServ__AssetsAndLiabilities__c> personalProList;
        
        if(accountId != null){
            
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
           		
               personalProList = [SELECT Id,Name,FinServ__Amount__c,FinServ__AssetsAndLiabilitiesType__c,
                                  WEGP1_Owner_Type__c 
                                  FROM FinServ__AssetsAndLiabilities__c 
                                  WHERE FinServ__Household__c = :accList[0].WEGP1_Primary_Household__c
                                  AND RecordType.Name IN('Asset') 
                                  AND FinServ__AssetsAndLiabilitiesType__c IN ('Automobile','Jewelry','Real Estate')];
            }
            
        }
        return personalProList;
    }
}