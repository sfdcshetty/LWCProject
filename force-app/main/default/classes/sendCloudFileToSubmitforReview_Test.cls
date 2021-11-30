@isTest
private class sendCloudFileToSubmitforReview_Test {
    static testMethod void method1() {
        User owner = [SELECT Name FROM User WHERE Profile.Name = 'Advisor' LIMIT 1];
        Id RecordTypeIdHouseHold = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id RecordTypeIdCustodian = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        Id individualRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        Account ParentAccount = new Account();
        ParentAccount.Name = 'TestParentAccount';
        ParentAccount.RecordTypeId = RecordTypeIdCustodian;
        ParentAccount.ShippingState = 'AK';
        insert ParentAccount;

        Account ParentAccount1 = new Account();
        ParentAccount1.Name = 'TestParentAccount';
        ParentAccount1.RecordTypeId = individualRecordId;
        ParentAccount1.ShippingState = 'AK';
        insert ParentAccount1;

        Contact contactToInsert = new Contact();
        contactToInsert.LastName = 'TestLastName';
        contactToInsert.AccountId = ParentAccount.Id;
        insert contactToInsert;

        Account accountToInsert = new Account();
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
        accountToInsert.RecordTypeId = RecordTypeIdHouseHold;
        accountToInsert.WEG_IM_Special_Instructions__c = 'Y';
        accountToInsert.WEG_IM_Special_Instructions_Detail__c = 'SIR Dtails';
        accountToInsert.WEG_Investment_Objective__c = 'Long Term Growth';
        accountToInsert.WEG_Investment_Variances__c = 'Y';
        accountToInsert.WEG_Investment_Variances_Detail__c = 'IV Details';
        insert accountToInsert;


        Account_Servicing__c asRecord = new Account_Servicing__c();
        asRecord.WEG_Items_to_Complete__c = 'Test';
        asRecord.Related_Account__c = accountToInsert.Id;
        asRecord.WEGP1_Secondary_Individual__c = contactToInsert.Id;
        insert asRecord;

        
        TVA_CFB__Cloud_Files__c  cf = new TVA_CFB__Cloud_Files__c ();
        cf.WEG_Account_Servicing__c = asRecord.Id;
        cf.WEGP1_DocumentType__c = 'Document Submission';
        cf.Scan_Date__c = system.now();
        insert cf;
        
        cf.Scan_Date__c = system.now().addDays(1);
        update cf;
    }
}