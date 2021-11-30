@isTest
public class FASFieldsUpdate_TC {
    @isTest static void method1(){
        User owner = [SELECT Name FROM User WHERE Profile.Name = 'Advisor' LIMIT 1] ;
        Id RecordTypeIdHouseHold = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id RecordTypeIdCustodian = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        Account ParentAccount = new Account();
        ParentAccount.Name = 'TestParentAccount';
        ParentAccount.RecordTypeId = RecordTypeIdCustodian;
        insert ParentAccount;
        
        Contact contactToInsert = new Contact();
        contactToInsert.LastName='TestLastName';
        contactToInsert.AccountId=ParentAccount.Id;
        insert contactToInsert;
        
        Account accountToInsert = new Account();
        accountToInsert.Name='TestAccount';
        accountToInsert.OwnerId = owner.Id;
        accountToInsert.WEGP1_Primary_Individual__c=contactToInsert.Id;
        accountToInsert.FI_Annual_Income__c = 23;
        accountToInsert.FI_Liquid_Net_Worth__c = 12;
        accountToInsert.FinServ__NetWorth__c = 14;
        accountToInsert.FI_Primary_Source_of_Wealth__c = 'Employment' ;
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
        accountToInsert.WEG_Investment_Variances__c ='Y';
        accountToInsert.WEG_Investment_Variances_Detail__c = 'IV Details';
        insert accountToInsert;
        
        Id RecordTypeIdAS = Schema.SObjectType.Account_Servicing__c.getRecordTypeInfosByName().get('Account Servicing').getRecordTypeId();
        Account_Servicing__c AServicing = new Account_Servicing__c();
        Aservicing.Related_Account__c = accountToInsert.Id;
        Aservicing.OwnerId = owner.Id;
        Aservicing.RecordTypeId = RecordTypeIdAS;
        Aservicing.WEGP1_Secondary_Individual__c = contactToInsert.Id;
        Aservicing.FI_Primary_Source_of_Wealth__c = 'Employment';
        Aservicing.WEG_Primary_PrimaryEmail__c = 'Personal';
        Aservicing.WEG_Primary_Email__c = 'test@test.com';
        Aservicing.WEG_Secondary_Email__c = 'test@test.com';
        Aservicing.WEG_Secondary_PrimaryEmail__c =  'Personal';
        Aservicing.WEG_Investment_Variances__c ='Y';
        Aservicing.WEG_Investment_Variances_Detail__c = 'IV Details';
        Aservicing.WEG_IM_Special_Instructions__c = 'Y';
        Aservicing.WEG_IM_Special_Instructions_Detail__c = 'SIR details';
        Aservicing.FI_Annual_Income__c =23546 ;
        Aservicing.FI_Net_Worth__c = 23;
        Aservicing.FI_Liquid_Net_Worth__c = 25; 
        Aservicing.FI_Tax_Bracket__c = 4;
        Aservicing.FI_Special_Liquidity_Needs__c = 'Y';
        Aservicing.FI_Special_Liquidity_Needs_Detail__c = 'SLN Details';
        Aservicing.FI_Year_Began_Investing__c = 2012;
        Aservicing.WEG_Alternate_Billing__c = 'Y';
        Aservicing.WEG_Status__c = 'Suitability Review';
        Aservicing.WEG_Items_to_Complete__c = '';
        insert Aservicing;
        
        Id RecordTypeIdFAS = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('New Brokerage').getRecordTypeId();
        Id RecordTypeIdFASNewAdvisory = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('New Advisory').getRecordTypeId();
        
        Financial_Account_Servicing__c FinancialASRecord = new Financial_Account_Servicing__c();
        FinancialASRecord.Account_Servicing__c = Aservicing.Id;
        FinancialASRecord.Registration_Type__c = '401(k)';
        FinancialASRecord.WEG_Custodian__c = 'Schwab';
        FinancialASRecord.Approximate_Value__c = 2;
        FinancialASRecord.WEG_No_Model__c = true;
        //FinancialASRecord.WEG_Source_of_Funds__c = '401k';
        FinancialASRecord.WEG_Billing_Exclusions__c = 'Y';
        FinancialASRecord.WEG_Billing_Exclusions_Detail__c = 'Exclude Cash from RIA Fee';
        FinancialASRecord.RecordTypeId =RecordTypeIdFAS;
        FinancialASRecord.WEG_Items_to_Complete__c = '';
        FinancialASRecord.Status__c = 'Suitability Review';
        insert FinancialASRecord;
        
        Financial_Account_Servicing__c FinancialASRecordWithNA = new Financial_Account_Servicing__c();
        FinancialASRecordWithNA.Account_Servicing__c = Aservicing.Id;
        FinancialASRecordWithNA.Registration_Type__c = '401(k)';
        FinancialASRecordWithNA.WEG_Custodian__c = 'Schwab';
        FinancialASRecordWithNA.Approximate_Value__c = 2;
        //FinancialASRecordWithNA.WEG_Source_of_Funds__c = '401k';
        FinancialASRecordWithNA.WEG_Billing_Exclusions__c = 'Y';
        FinancialASRecordWithNa.WEG_No_Model__c = true;
        FinancialASRecordWithNA.WEG_Billing_Exclusions_Detail__c = 'Exclude Cash from RIA Fee';
        FinancialASRecordWithNA.RecordTypeId =RecordTypeIdFASNewAdvisory;
        FinancialASRecordWithNA.WEG_Items_to_Complete__c = '';
        FinancialASRecordWithNA.Account_Number__c = '12345';
        FinancialASRecordWithNA.TIK_Hold__c = 'N';
        FinancialASRecordWithNA.Fee_Type__c = '';
        FinancialASRecordWithNA.Prudent_Process__c = '';
        FinancialASRecordWithNA.WEG_Program__c = '';
        FinancialASRecordWithNA.Status__c = 'Suitability Review';
        insert FinancialASRecordWithNA;
        
        Test.startTest();
        FASFieldsUpdate.PushAccountServicing pushAS = new FASFieldsUpdate.PushAccountServicing();
        pushAS.parentId = FinancialASRecordWithNA.Account_Servicing__c;
        
        FASFieldsUpdate.updateFasFields(new List<FASFieldsUpdate.PushAccountServicing>{pushAS});
        Test.stopTest();
        
        System.assertEquals('Suitability Review',Aservicing.WEG_Status__c);
    }
}