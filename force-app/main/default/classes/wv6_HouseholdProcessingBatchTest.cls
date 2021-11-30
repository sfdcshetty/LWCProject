@isTest
private class wv6_HouseholdProcessingBatchTest  {

	private static testMethod void TestHouseholdProcessing() {
	    test.startTest();
	    // Insert Household Account
        Account hhAcc1 = new Account(Name='Test HH Account 1', recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc1;
        
        // Insert Individual Accounts
        Account indAcc1 = new Account(Name='Test Ind Account 1', recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc1;
        
        // Fetch Contact
        Contact con1 =  [Select Id, FinServ__IndividualId__c From Contact Where AccountId =: indAcc1.Id];
        
        
        //Insert AccountContactRelation record
        AccountContactRelation acr1 = new AccountContactRelation();
        acr1.accountId = hhAcc1.Id;
        acr1.contactId = con1.Id;
        acr1.FinServ__Primary__c = true;
        acr1.FinServ__PrimaryGroup__c = true;
        acr1.isActive = true;
        acr1.Roles='Client';
        insert acr1;
        
        // Insert Individual Accounts
        Account indAcc2 = new Account(Name='Test Ind Account 2', recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc2;
        
        // Fetch Contact
        Contact con2 =  [Select Id, FinServ__IndividualId__c From Contact Where AccountId =: indAcc2.Id];
        
        
        //Insert AccountContactRelation record
        AccountContactRelation acr2 = new AccountContactRelation();
        acr2.accountId = hhAcc1.Id;
        acr2.contactId = con2.Id;
        acr2.FinServ__Primary__c = false;
        acr2.FinServ__PrimaryGroup__c = true;
        acr2.isActive = true;
        acr2.Roles='Spouse';
        insert acr2;
        
        wv6_HouseholdProcessingBatch batchCls = new wv6_HouseholdProcessingBatch();
        database.executebatch(batchCls);
        
        test.stopTest();
        
        Account householdAcc = [SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id =: hhAcc1.Id ];
        system.assertEquals(householdAcc.WEGP1_Primary_Individual__c, con1.Id);
        system.assertEquals(householdAcc.WEGP1_Secondary_Individual__c, con2.Id);
        
	}

}