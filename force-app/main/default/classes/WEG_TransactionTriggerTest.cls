@isTest
private class WEG_TransactionTriggerTest {
    
    private static testMethod void testTrigger(){
        
        test.startTest();
        
        // insert a non-admin user for testing
        User u = new User(
            LastName = 'Test',
            Email = 'testusertrigger@test.com',
            Username = 'testusertrigger@test.com',
            Alias = 'alias',
            CompanyName = 'testusertrigger',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            WEG_GLDepartment__c = 10,
            WEG_GLLocation__c = 1001,
            WEG_FACode__c = 2001
        );
        insert u;
        
        // create a household
        Id householdRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account household = new Account(Name = 'Test HH', RecordTypeId = householdRecordType
                                        , OwnerId = u.Id, WEGP1_ClientAnniversaryDate__c = Date.newInstance(2017, 01, 01));
        insert household;
        Account household2 = new Account(Name = 'Test HH2', RecordTypeId = householdRecordType
                                        , OwnerId = u.Id, WEGP1_ClientAnniversaryDate__c = Date.newInstance(2016, 01, 01));
        insert household2;
        
        // create an individual
        Id indivRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Account indiv = new Account(Name = 'Test Indiv', RecordTypeId = indivRecordType
                                        , OwnerId = u.Id);
        insert indiv;
        
        // create a financial account
        FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c(Name = 'Test Fin Acct', FinServ__PrimaryOwner__c = indiv.Id
                                                                               , OwnerId = u.Id);
        insert finAcct;
        
        // create a financial account
        FinServ__FinancialAccount__c finAcct2 = new FinServ__FinancialAccount__c(Name = 'Test Fin Acct', FinServ__PrimaryOwner__c = indiv.Id
                                                                                , OwnerId = u.Id);
        insert finAcct2;
        
        // create a pay period
        WEG_PayPeriod__c payPeriod = new WEG_PayPeriod__c (
            Name = '201801',
            WEG_PeriodStartDate__c = Date.newInstance(2018, 1, 1),
            WEG_PeriodEndDate__c = Date.newInstance(2018, 1, 15),
            WEG_PeriodPayDate__c = Date.newInstance(2018, 1, 22)
        );
        insert payPeriod;
        WEG_PayPeriod__c payPeriod2 = new WEG_PayPeriod__c (
            Name = '2018012',
            WEG_PeriodStartDate__c = Date.newInstance(2018, 2, 1),
            WEG_PeriodEndDate__c = Date.newInstance(2018, 2, 15),
            WEG_PeriodPayDate__c = Date.newInstance(2018, 2, 22)
        );
        insert payPeriod2;
        
        // create an account
        Account acct = new Account (
            Name = 'Test Acct',
            OwnerId = u.Id
        );
        insert acct;
        
        // create an invoice
        WEG_Invoice__c inv = new WEG_Invoice__c (
            Name = 'Test',
            //WEG_BillTo__c = acct.Id,
            WEG_PayPeriod__c = payPeriod.Id
        );
        insert inv;
        
        // create a product
        Product2 product = new Product2(Name = 'Test Product', WEG_GLRevenueAcct__c = 4001, WEG_GLProductLine__c = 50);
        insert product;
        // create another product
        Product2 product2 = new Product2(Name = 'Test Product 2', WEG_GLRevenueAcct__c = 4001, WEG_GLProductLine__c = 50);
        insert product2;
        
        // get the LPL and Manual Transaction record type Ids
        Id manualRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('Manual Transaction').getRecordTypeId();
        Id lplRecordTypeId = Schema.SObjectType.WEG_Transaction__c.getRecordTypeInfosByName().get('LPL Transaction').getRecordTypeId();
        
        // create a new Manual transaction
        WEG_Transaction__c manualTrans = new WEG_Transaction__c(
            Pay_Period__c = payPeriod.Id,
            Invoice__c = inv.Id,
            RecordTypeId = manualRecordTypeId,
            Product__c = product.Id,
            Financial_Account__c = finAcct.Id,
            Household__c = household.Id
        );
        system.runAs(u) {
            insert manualTrans;
        }
        
        WEG_Transaction__c manualTransTest = [SELECT Id, GL_Account__c, GL_Product_Line__c, GL_Department__c, GL_Location__c, FA_Code__c
                                              FROM WEG_Transaction__c WHERE Id = :manualTrans.Id];
        
        //System.AssertEquals(manualTransTest.GL_Account__c, 4001);
        //System.AssertEquals(manualTransTest.GL_Product_Line__c, 50);
        //System.AssertEquals(manualTransTest.GL_Department__c, 10);
        //System.AssertEquals(manualTransTest.GL_Location__c, 1001);
        //System.AssertEquals(manualTransTest.FA_Code__c, 2001);
        
        // update the manual trans
        manualTrans.Product__c = product2.Id;
        manualTrans.Financial_Account__c = finAcct2.Id;
        manualTrans.Pay_Period__c = payPeriod2.Id;
        manualTrans.Household__c = household2.Id;
        update manualTrans;
        
        // create a new LPL transaction
        WEG_Transaction__c lplTrans = new WEG_Transaction__c(
            Pay_Period__c = payPeriod.Id,
            Invoice__c = inv.Id,
            RecordTypeId = lplRecordTypeId
        );
        insert lplTrans;
        
        // attempt to delete the LPL transaction
        System.runAs(u) {
            try {
                delete lplTrans;
                System.AssertEquals('Delete of the LPL Transaction did not fail.', '');
            }
            catch(Exception ex) {
                boolean expectedExceptionThrown =  ex.getMessage().contains('Only transactions of record type Manual Transaction can be deleted') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
        
        test.stopTest();
  }
}