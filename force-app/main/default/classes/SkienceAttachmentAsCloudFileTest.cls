@isTest
private class SkienceAttachmentAsCloudFileTest {
    /*
    public static Account insertAccount() {
        Account account = new Account();
        account.Name = 'SampleFn SimpleLn';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert account;
        return account; 
    }
    
    public static FinServ__FinancialAccount__c insertFSCFinancialAccount(){
        Account account = insertAccount();
        Account accountHousehold = new Account();
        account.FinServ__PrimaryContact__c = account.FinServ__PrimaryContact__c;
        accountHousehold.Name = 'Household Name';
        accountHousehold.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        insert accountHousehold;
        account.WEGP1_Primary_Household__c = accountHousehold.Id;
        update account;
        
        FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
        financialAccount.RecordTypeId =  Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        financialAccount.FinServ__PrimaryOwner__c = account.Id;
        financialAccount.SkienceFinSln__Primary_Owner_Id__c = account.FinServ__PrimaryContact__c;        
        financialAccount.SkienceFinSln__Investment_Amount__c = 54154;
        financialAccount.SkienceFinSln__Product_Type__c='PT';
        financialAccount.FinServ__CashBalance__c=2;
        financialAccount.FinServ__Balance__c  =10000;
        financialAccount.SkienceFinSln__Product_Company__c = 'Charles Schwab';
        financialAccount.SkienceFinSln__Investment_Vehicle_Symbol_Name__c = 'VA';
        financialAccount.Finserv__Balance__c = 9000;
        financialAccount.FinServ__FinancialAccountNumber__c='TestAcct123';
        insert financialAccount;
        
        return financialAccount;
    }
    
    public static void setupDocuVault(){
        TVA_CFB__CloudFiles_LookUp_Mapping__c setting = NEW TVA_CFB__CloudFiles_LookUp_Mapping__c ();
        setting.TVA_CFB__Field_Name__c = 'WEGP1_FinancialAccount__c';
        setting.Name = 'FinServ__FinancialAccount__c';
        insert setting;
    }
    
    static testMethod void testCreateUpdateAttachment () {
        setupDocuVault();
        FinServ__FinancialAccount__c fa = insertFSCFinancialAccount();
        SkienceFinSln__FinancialAccountForm__c FAForm = new SkienceFinSln__FinancialAccountForm__c();
        FAForm.SkienceFinSln__Financial_Account_Id__c = fa.id;
        insert FAForm;
        Test.startTest ();
        
        //           TVA_CFB__Attachment_to_Cloud__c triggerEnable = NEW TVA_CFB__Attachment_to_Cloud__c ();
        //           triggerEnable.Enable_Disable__c = TRUE;
        //           insert triggerEnable;
        
        Attachment att = NEW Attachment ();
        att.Name = 'test.jpg';
        att.ParentID = fa.ID;
        att.Body = Blob.valueOf ('test');
        insert att;
        FAForm.SkienceFinSln__Signed_Attachment__c = att.id;
        update FAForm; 
        // simulating Docusign Download.
        att.Name = 'testchanged.jpg';
        update att; // This should insert the TVA_CFB__Cloud_Files__c record

        TVA_CFB__Cloud_Files__c cloudFlies = [select id, WEGP1_FinancialAccount__c, TVA_CFB__Attachment_ID__c, TVA_CFB__E_Tag__c
                                              from TVA_CFB__Cloud_Files__c where TVA_CFB__Attachment_ID__c = :att.id];
        system.assertEquals(fa.id, cloudFlies.WEGP1_FinancialAccount__c);
        cloudFlies.TVA_CFB__E_Tag__c = 'Updated';
        update cloudFlies; // This should update financialaccountforms record to update attacchment field with cloud files id.
        FAForm = [select id, SkienceFinSln__Signed_Attachment__c from SkienceFinSln__FinancialAccountForm__c where id = :FAForm.id];
        system.assertEquals(FAForm.SkienceFinSln__Signed_Attachment__c, cloudFlies.id);
        Test.stopTest ();
    }
    */
}