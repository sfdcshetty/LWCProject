@isTest
public class wv6_FinancialAccountsGridViewTest {
    @testSetup static void testDataSetup() {
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        acc.Name = 'Test Household Account';
        insert acc;
        
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
        fa.FinServ__Household__c = acc.Id;
        fa.FinServ__FinancialAccountNumber__c = '12232324';
        fa.WEG_As_Of_Date__c = System.Today();
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
        fa.FinServ__Household__c = acc.Id;
        fa.FinServ__FinancialAccountNumber__c = '122323235';
        fa.WEG_As_Of_Date__c = System.Today();
        fa.WEGP1_YTD_Contributions__c = 10000;
        //fa.WEGP1_ContributionsOverride__c = 10000;
        fa.WEGP1_YTD_Withdrawals__c = 10000;
        //fa.WEGP1_WithdrawalsOverride__c = 10000;
        fa.FinServ__Balance__c = 10000;
        fa.WEG_Registration_Type__c = 'Estate';
        financialAccList.add(fa);
        
        insert financialAccList;
        system.debug('financialAccList:>>'+financialAccList);
    }
    
    static private string getFieldString() {
        return 'Id,Name,WEGP1_Owner_Type__c,FinServ__FinancialAccountNumber__c,FinServ__Status__c,WEG_As_of_Date__c,Contributions_Total__c,WEGP1_ContributionsOverride__c,WEG_Registration_Type__c,WEGP1_WithdrawalsOverride__c,FinServ__Balance__c,WEGP1_Held_Status__c';
    }
    
    @isTest 
    static void getGridRecordsForEditModeTest(){
        Account acc = [SELECT Id FROM Account Where RecordType.Name = 'Individual' LIMIT 1];
        String wrapper = wv6_FinancialAccountsGridViewController.getGridRecordsForEditMode(
                                                                                            'FinServ__FinancialAccount__c', 
                                                                                            Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId(), 
                                                                                            getFieldString(),
                                                                                            acc.Id, 
                                                                                            'Individual', 
                                                                                            'WEGP1_Held_Status__c', 
                                                                                            'FinServ__Balance__c',  
                                                                                            'Open, Draft');
                                                                                            
       
    }
    
    
    @isTest 
    static void getGridRecordsForReadOnlyModeTest(){
        Account acc = [SELECT Id FROM Account Where RecordType.Name = 'Individual' LIMIT 1];
        String wrapper1 = wv6_FinancialAccountsGridViewController.getGridRecordsForReadOnlyMode(
                                                                                            'FinServ__FinancialAccount__c', 
                                                                                            Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId(), 
                                                                                            getFieldString(),
                                                                                            acc.Id, 
                                                                                            'Individual', 
                                                                                            'WEGP1_Held_Status__c', 
                                                                                            'FinServ__Balance__c', 
                                                                                            'Open, Draft','Financial Accounts');                                                                                    
        
    }
    
    
    @isTest 
    static void saveChangesTest(){
        Account acc = [SELECT Id FROM Account Where RecordType.Name = 'Individual' LIMIT 1];
        String wrapper = wv6_FinancialAccountsGridViewController.getGridRecordsForEditMode(
                                                                                            'FinServ__FinancialAccount__c', 
                                                                                            Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId(), 
                                                                                            getFieldString(),
                                                                                            acc.Id, 
                                                                                            'Individual', 
                                                                                            'WEGP1_Held_Status__c', 
                                                                                            'FinServ__Balance__c', 
                                                                                            'Open, Draft');                                                                                    
           
        wv6_FinancialAccountsGridViewController.saveChanges(wrapper);
    }
    
    @isTest 
    static void updatesObjectTest(){
        list<FinServ__FinancialAccount__c> faList = [SELECT Id, Remove_or_Historic__c FROM FinServ__FinancialAccount__c];                                                                                       
        for(FinServ__FinancialAccount__c fa : faList){
            wv6_FinancialAccountsGridViewController.updatesObject(fa.Id,'Mark for Removal','FinServ__FinancialAccount__c');    
        }
        // Validate data
        FinServ__FinancialAccount__c fa = [SELECT Id, Remove_or_Historic__c FROM FinServ__FinancialAccount__c LIMIT 1];                                                                                       
        system.assertEquals('Mark for Removal',fa.Remove_or_Historic__c);
    }
    
    @isTest 
    static void getInvestAdjustmentTypesTest(){
        List<String> recTypeList = wv6_FinancialAccountsGridViewController.getInvestAdjustmentTypes();
        
        // Validate data
        system.assertNotEquals(recTypeList,Null);
    }
    
    @isTest 
    static void createInvestmentAdjustmentTest(){
        FinServ__FinancialAccount__c fa = [SELECT Id, Remove_or_Historic__c FROM FinServ__FinancialAccount__c LIMIT 1]; 
        Investment_Adjustment__c invAdjustment = new Investment_Adjustment__c();
        invAdjustment.Adjustment_Type__c = 'Contribution';
        invAdjustment.Financial_Account__c = fa.Id;
        invAdjustment.Amount__c = 100;
        invAdjustment.Adjustment_Reason__c = 'Test';
        invAdjustment.Date_of_Adjustment__c = system.today();
        wv6_FinancialAccountsGridViewController.createInvestmentAdjustment(invAdjustment);
        
        // validate Data
        list<Investment_Adjustment__c> iaList = [SELECT Id FROM Investment_Adjustment__c ] ;
        system.assertEquals(iaList.size(), 1);
    }
    
    @isTest 
    static void getRecordTypesTest(){
        string insuranceRecTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Insurance Policy').getRecordTypeId();
        string  invAccRecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        string recTypeIds = insuranceRecTypeId+','+invAccRecordTypeId;
        List<wv6_FinancialAccountsGridViewWrapper.RecordTypeInfoWrapper> recTypeList = wv6_FinancialAccountsGridViewController.getRecordTypes('FinServ__FinancialAccount__c',recTypeIds);
        
        // Validate data
        system.assertNotEquals(recTypeList,Null);
    }
    
    
    
}