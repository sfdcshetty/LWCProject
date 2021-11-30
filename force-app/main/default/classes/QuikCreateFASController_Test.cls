@isTest
private class QuikCreateFASController_Test {
    
    @testSetup static void testDataSetup() {
        User owner = [SELECT Name FROM User WHERE Profile.Name = 'Advisor' LIMIT 1];
        Id RecordTypeIdCustodian = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        
        Account ParentAccount = new Account();
        ParentAccount.Name = 'TestParentAccount';
        ParentAccount.RecordTypeId = RecordTypeIdCustodian;
        ParentAccount.ShippingState = 'AK';
        insert ParentAccount;
        
        Contact contactToInsert = new Contact();
        contactToInsert.LastName = 'TestLastName';
        contactToInsert.AccountId = ParentAccount.Id;
        insert contactToInsert;
        
        Account accountToInsert = new Account();
        accountToInsert.OwnerId = owner.id;
        accountToInsert.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        accountToInsert.Name = 'TestAccount';
        accountToInsert.OwnerId = owner.Id;
        accountToInsert.WEGP1_Primary_Individual__c = contactToInsert.Id;
        accountToInsert.FI_Annual_Income__c = 23;
        accountToInsert.FI_Liquid_Net_Worth__c = 12;
        accountToInsert.FinServ__NetWorth__c = 14;
        accountToInsert.FI_Special_Liquidity_Needs__c = 'Y';
        accountToInsert.FI_Tax_Bracket__c = 2;
        accountToInsert.FI_Year_Began_Investing__c = 2012;
        accountToInsert.WEG_Alternate_Billing__c = 'Y';
        accountToInsert.FinServ__TimeHorizon__c = '1-3 years';
        accountToInsert.FI_Special_Liquidity_Needs_Detail__c = 'SLN Details';
        accountToInsert.WEGP1_Secondary_Individual__c = contactToInsert.Id;
        accountToInsert.WEG_IM_Special_Instructions__c = 'Y';
        accountToInsert.WEG_IM_Special_Instructions_Detail__c = 'SIR Dtails';
        accountToInsert.WEG_Investment_Objective__c = 'Long Term Growth';
        accountToInsert.WEG_Investment_Variances__c = 'Y';
        accountToInsert.WEG_Investment_Variances_Detail__c = 'IV Details';
        accountToInsert.TamAdvisor__Updated_by_Tamarac_Integration__c = true;
        accountToInsert.SK_Balance_Due__c = 100;
        insert accountToInsert;
        
        Account_Servicing__c asRecord = new Account_Servicing__c();
        asRecord.WEG_Items_to_Complete__c = 'Test';
        asRecord.Related_Account__c = accountToInsert.Id;
        asRecord.WEGP1_Secondary_Individual__c = contactToInsert.Id;
        insert asRecord;
        
        Account indAcc = new Account();
        indAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        indAcc.Name = 'Test Individual Account';
        insert indAcc;
        
        list<FinServ__FinancialAccount__c> financialAccList = new list<FinServ__FinancialAccount__c>();
        FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c();
        fa.Name = 'Test Financial Account 1';
        fa.FinServ__PrimaryOwner__c = indAcc.Id;
        fa.FinServ__Status__c = 'Open';
        fa.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        fa.FinServ__Household__c = accountToInsert.Id;
        fa.FinServ__FinancialAccountNumber__c = '12232324';
        fa.WEG_As_of_Date__c = System.Today();
        fa.WEGP1_YTD_Contributions__c = 10000;
        fa.WEGP1_ContributionsOverride__c = 10000;
        fa.WEGP1_YTD_Withdrawals__c = 10000;
        fa.WEGP1_WithdrawalsOverride__c = 10000;
        fa.FinServ__Balance__c = 10000;
        fa.WEG_Registration_Type__c = 'Checking';
        financialAccList.add(fa);
        
        fa = new FinServ__FinancialAccount__c();
        fa.Name = 'Test Financial Account 2';
        fa.FinServ__PrimaryOwner__c = indAcc.Id;
        fa.FinServ__Status__c = 'Closed';
        fa.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        fa.FinServ__Household__c = accountToInsert.Id;
        fa.FinServ__FinancialAccountNumber__c = '122323235';
        fa.WEG_As_of_Date__c = System.Today();
        fa.WEGP1_YTD_Contributions__c = 10000;
        //fa.WEGP1_ContributionsOverride__c = 10000;
        fa.WEGP1_YTD_Withdrawals__c = 10000;
        //fa.WEGP1_WithdrawalsOverride__c = 10000;
        fa.FinServ__Balance__c = 10000;
        fa.WEG_Registration_Type__c = 'Estate';
        financialAccList.add(fa);
        
        insert financialAccList;
        
    }
    
    static testMethod void getTestResults(){
        
        Account_Servicing__c asRecord = [SELECT Related_Account__c from Account_Servicing__c LIMIT 1];
        List <FinServ__FinancialAccount__c> fAccounts = [SELECT FinServ__Household__c 
                                    FROM 
                                        FinServ__FinancialAccount__c
                                    ];
        
        System.assertEquals(fAccounts.size(), 2);
        String returnVal = QuikCreateFASController.getRelatedHouseholdRecords(asRecord.Id);        
        System.Debug(returnVal);
    }
    
    
}