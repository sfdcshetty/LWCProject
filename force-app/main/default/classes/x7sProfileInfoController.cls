public without sharing class x7sProfileInfoController {
    
     Public class ProfileDataContainer{
         
        @AuraEnabled Public List<Account> clientAndCoClientInfo {get;set;}
        @AuraEnabled Public List<FinServ__ContactContactRelation__c> beneficiaryInfo {get;set;}
        @AuraEnabled Public List<FinServ__ContactContactRelation__c> trusteeInfo {get;set;}
         
        public ProfileDataContainer(){
            
            clientAndCoClientInfo = new List<Account>();
            beneficiaryInfo = new List<FinServ__ContactContactRelation__c>();
            trusteeInfo = new List<FinServ__ContactContactRelation__c>();
            
        }
     }
    
    @AuraEnabled (cacheable=true)
    public static ProfileDataContainer getUsersProfileData(String accountId){
        
        ProfileDataContainer profileInfo = new ProfileDataContainer();
        
        List<Account> clientAndCoClient;

        if(accountId != null){
            
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            List<Account> beneficiaryAccounts = [SELECT Id,Name,(SELECT Id,Roles,ContactId 
                                                                FROM AccountContactRelations 
                                                                WHERE Roles = 'Benficiary' 
                                                                AND AccountId =:accountId LIMIT 1) Roles 
                                                FROM Account 
                                                WHERE Id =: accountId LIMIT 1];
            
            List<Account> trusteeAccounts = [SELECT Id,Name,(SELECT Id,Roles,ContactId 
                                                                FROM AccountContactRelations 
                                                                WHERE Roles = 'Trustee' 
                                                                AND AccountId =:accountId LIMIT 1) Roles 
                                                FROM Account 
                                                WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
                
                clientAndCoClient = [SELECT Id, Name, WEGP1_Primary_Household__c,
                                                	WEGP1_Primary_Individual__c,WEGP1_Primary_Individual__r.Name,
                                                	WEGP1_Primary_Individual__r.Birthdate, 
                                                	WEGP1_Primary_Individual__r.WEGP1_PrimaryAddress__c,
                                                    WEGP1_Primary_Individual__r.WEGP1_PrimaryPhone__c,
                                                    WEGP1_Primary_Individual__r.OtherAddress,WEGP1_Primary_Individual__r.OtherStreet,
                                     				WEGP1_Primary_Individual__r.OtherCity,WEGP1_Primary_Individual__r.OtherState,
                                     				WEGP1_Primary_Individual__r.OtherCountry,WEGP1_Primary_Individual__r.OtherPostalCode,
                                                    WEGP1_Primary_Individual__r.MailingAddress, WEGP1_Primary_Individual__r.Account.BillingAddress, WEGP1_Primary_Individual__r.Account.ShippingAddress,
                                                    WEGP1_Primary_Individual__r.Account.BillingStreet, WEGP1_Primary_Individual__r.Account.BillingCity, WEGP1_Primary_Individual__r.Account.BillingState, WEGP1_Primary_Individual__r.Account.BillingPostalCode,
                                                    WEGP1_Primary_Individual__r.Account.ShippingStreet, WEGP1_Primary_Individual__r.Account.ShippingCity, WEGP1_Primary_Individual__r.Account.ShippingState, WEGP1_Primary_Individual__r.Account.ShippingPostalCode,
                                     
                                                    WEGP1_Primary_Individual__r.Work_Address_Street__c,
                                                    WEGP1_Primary_Individual__r.AssistantPhone, WEGP1_Primary_Individual__r.HomePhone, WEGP1_Primary_Individual__r.OtherPhone, WEGP1_Primary_Individual__r.MobilePhone,
                                                    WEGP1_Primary_Individual__r.WEGP1_PersonalEmail__c, WEGP1_Primary_Individual__r.WEG_Business_Email__c,
                                                    WEGP1_Primary_Individual__r.WEGP1_OtherEmail__c,
                                                
                                                    WEGP1_Secondary_Individual__c,WEGP1_Secondary_Individual__r.Name, WEGP1_Secondary_Individual__r.Birthdate, 
                                                    WEGP1_Secondary_Individual__r.OtherStreet,WEGP1_Secondary_Individual__r.OtherAddress,
                                     				WEGP1_Secondary_Individual__r.OtherCity,WEGP1_Secondary_Individual__r.OtherState,
                                     				WEGP1_Secondary_Individual__r.OtherCountry,WEGP1_Secondary_Individual__r.OtherPostalCode,
                                     				WEGP1_Secondary_Individual__r.WEGP1_PrimaryAddress__c,

                                                    WEGP1_Secondary_Individual__r.Account.BillingAddress, WEGP1_Secondary_Individual__r.Account.ShippingAddress,
                                                    WEGP1_Secondary_Individual__r.Account.BillingStreet, WEGP1_Secondary_Individual__r.Account.BillingCity, WEGP1_Secondary_Individual__r.Account.BillingState, WEGP1_Secondary_Individual__r.Account.BillingPostalCode,
                                                    WEGP1_Secondary_Individual__r.Account.ShippingStreet, WEGP1_Secondary_Individual__r.Account.ShippingCity, WEGP1_Secondary_Individual__r.Account.ShippingState, WEGP1_Secondary_Individual__r.Account.ShippingPostalCode,

                                                    WEGP1_Secondary_Individual__r.WEGP1_PrimaryPhone__c,
                                                    WEGP1_Secondary_Individual__r.Work_Address_Street__c,
                                                    WEGP1_Secondary_Individual__r.AssistantPhone, WEGP1_Secondary_Individual__r.HomePhone, WEGP1_Secondary_Individual__r.OtherPhone, WEGP1_Secondary_Individual__r.MobilePhone,

                                                    WEGP1_Secondary_Individual__r.WEGP1_PersonalEmail__c, WEGP1_Secondary_Individual__r.WEG_Business_Email__c,
                                                    WEGP1_Secondary_Individual__r.WEGP1_OtherEmail__c
                                                    From Account Where Id =: accList[0].WEGP1_Primary_Household__c LIMIT 1];
            
            }
                       
            profileInfo.clientAndCoClientInfo = clientAndCoClient;

            if(beneficiaryAccounts.size() > 0 && beneficiaryAccounts != null){
               profileInfo.beneficiaryInfo = getBeneficiaryAndTrusteeData(beneficiaryAccounts);
            }
            if(trusteeAccounts.size() > 0 && trusteeAccounts != null){
               profileInfo.trusteeInfo = getBeneficiaryAndTrusteeData(trusteeAccounts);
            } 
        }
        
        return profileInfo;
    }
    
    public static List<FinServ__ContactContactRelation__c> getBeneficiaryAndTrusteeData(List<Account> benAndtrusAccs){
        
        List<FinServ__ContactContactRelation__c> beneficiaryAndTrustee;
        
        /** System.debug('benAndtrusAccs1' + benAndtrusAccs.size());
        System.debug('benAndtrusAccs2' + benAndtrusAccs[0].AccountContactRelations.size()); **/
        if(benAndtrusAccs.size() > 0 && benAndtrusAccs != null 
           && benAndtrusAccs[0].AccountContactRelations.size() > 0 && benAndtrusAccs[0].AccountContactRelations != null){
               
            if(benAndtrusAccs[0].AccountContactRelations[0].ContactId != null){
                
              	beneficiaryAndTrustee = [SELECT Id, Contact_Full_Name__c,Name, 
                                         FinServ__Contact__c,FinServ__Contact__r.Email,FinServ__Contact__r.Phone, 
                                         FinServ__Role__c,FinServ__Role__r.Name, Contact_Birthdate__c 
                                         FROM FinServ__ContactContactRelation__c 
                                         WHERE FinServ__Contact__c = :benAndtrusAccs[0].AccountContactRelations[0].ContactId LIMIT 1];  
             }
        }
        return beneficiaryAndTrustee;
    }
}