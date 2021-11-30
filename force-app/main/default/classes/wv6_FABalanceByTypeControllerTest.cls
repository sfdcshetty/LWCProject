@isTest
public class wv6_FABalanceByTypeControllerTest {
    private static testMethod void testing() {
        
        Id bizRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account biz = new Account(Name = 'Test Biz', RecordTypeId = bizRecordType);
        insert biz;
        
        FinServ__FinancialAccount__c finacc = New FinServ__FinancialAccount__c();
        finacc.Name = 'Test Fin Acct 1';
        finacc.FinServ__PrimaryOwner__c = biz.Id;
        finacc.FinServ__CloseDate__c = NULL;
        finacc.Finserv__Status__c = 'Open';
        //finacc.WEGP1_Held_Status__c = 'WEG Held';
        finacc.Updated_by_Tamarac_Integration__c = true;
        finacc.FinServ__Balance__c = 2.00;
        finacc.WEG_External_Rec_ID__c = '1234';
        finacc.WEG_Registration_Type__c = 'IRA';
        insert finacc;
        
        test.startTest();
        
        wv6_FABalanceByTypeController.getAccountTypeAndBalances();
        
        test.stopTest();
    }
}