public without sharing class x7sTrustController {
    
    @AuraEnabled (Cacheable=true)
    public static List<Account> getTrustDetails(){

        List<Account> trusts = new List<Account>();
        User currentUser = [SELECT Id, Name, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c FROM User WHERE Id = : UserInfo.getUserId()];

        //If community user
        if(currentUser.ContactId != null && currentUser.Contact.Account.WEGP1_Primary_Household__c != null) {
            System.debug('houseHoldId = '+currentUser.Contact.Account.WEGP1_Primary_Household__c);
            List<FinServ__FinancialAccount__c> finAcc = [SELECT WEGP1_Trustee__c  FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = : currentUser.Contact.Account.WEGP1_Primary_Household__c];
            System.debug('finAcc' + finAcc);

            Map<Id, Contact> contactList = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id =: currentUser.Contact.Account.WEGP1_Primary_Household__c]);
            List<AccountContactRelation> relatedContacts = [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId =: currentUser.Contact.Account.WEGP1_Primary_Household__c AND IsActive = TRUE];

            List<Id> contactIds = new List<Id>();

            for(AccountContactRelation relation : relatedContacts) {
                contactIds.add(relation.ContactId);
            }
            contactIds.addAll(contactList.keySet());

            List<AccountContactRelation> trustRelations = [SELECT Id, AccountId FROM AccountContactRelation WHERE ContactId IN: contactIds AND Account.RecordType.Name = 'Trust' AND IsActive = TRUE];
            List<Id> trustIds = new List<Id>();

            for(AccountContactRelation trustRelation : trustRelations) {
                trustIds.add(trustRelation.AccountId);
            }

            trusts = [SELECT Id, Name, WEG_Trust_Scenario__c, Parent.Id, Parent.Name, WEG_Trust_Category__c, Date_of_Trust__c, FinServ__TotalFinancialAccounts__c, WEGP1_Total_AUM__c FROM Account WHERE Id IN: trustIds];

        }
        
        return trusts;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getTrustCategory() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Account.WEG_Trust_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getTrustType() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Account.Trust_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    }

}