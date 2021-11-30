@isTest
private class WEG_FAServicingTest {
    
    private static testMethod void testFAServicingComponent() {
        
        // create a person
        Account testPerson = WEG_TestUtil.createPerson();
        
        // create an associated financial account
        FinServ__FinancialAccount__c testFinancialAccount = WEG_TestUtil.createFinancialAccount(testPerson.Id);
        
        test.startTest();
        
        WEG_FAServicingFAListController.getFinancialAccounts(testPerson.Id);
        
        List<Id> financialAccountIds = new List<Id>();
        financialAccountIds.add(testFinancialAccount.Id);
        WEG_FAServicingSelectedFAList faList = new WEG_FAServicingSelectedFAList();
        faList.financialAccountIds = financialAccountIds;
        faList.countFinancialAccounts = 1;
        
        test.stopTest();
    }
}