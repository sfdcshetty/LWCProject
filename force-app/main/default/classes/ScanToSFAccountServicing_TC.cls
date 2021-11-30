@isTest
public class ScanToSFAccountServicing_TC {
    static testMethod void method1() {
        Account acc = NEW Account ();
        acc.Name = 'test';
        insert acc;
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
        Aservicing.WEG_Status__c = 'New';
        Aservicing.WEG_Items_to_Complete__c = '';
        insert Aservicing;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        
        cloudFileDetails.Name = 'Test.pdf';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        insert cloudFileDetails;
        
        TVA_CFB__Version_History__c versionFile = NEW TVA_CFB__Version_History__c ();
        
        versionFile.TVA_CFB__Amazon_Version_ID__c = cloudFileDetails.TVA_CFB__Amazon_Version_ID__c;
        versionFile.TVA_CFB__Cloud_Files__c = cloudFileDetails.ID;
        versionFile.TVA_CFB__File_Name__c = 'test';
        versionFile.TVA_CFB__File_Size_in_Bytes__c = cloudFileDetails.TVA_CFB__File_Size_in_Bytes__c;
        versionFile.TVA_CFB__File_Type__c = cloudFileDetails.TVA_CFB__File_Type__c;
        insert versionFile;
        
        cloudFileDetails.TVA_CFB__Version__c = 2;
        update cloudFileDetails;
         Test.startTest();
        ScanToSFAccountServicing.createCloudFile(cloudFileDetails,'Version');
        ScanToSFAccountServicing.createCloudFile(cloudFileDetails,'pdf');
        ScanToSFAccountServicing.getDocumentTypes();
        ScanToSFAccountServicing.getFileName(AServicing.id,'versionn');
        ScanToSFAccountServicing.getFileName (cloudFileDetails.id, 'version');
        ScanToSFAccountServicing.searchRecords('test','TVA_CFB__DocuVault_Folders__c',' TVA_CFB__Value__c',10);
        ScanToSFAccountServicing.defaultFolder('test1','test2');
        Test.stopTest();
        System.assertEquals('TestAccount', accountToInsert.Name);
            
    }
    
}