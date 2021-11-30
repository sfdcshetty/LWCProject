@isTest
private class WEG_FinAccountServicingTriggerTest {
    private static testMethod void testTrigger1() {
        
        // create a test user
        User testUser = new User(
            LastName = 'FasTest',
            Email = 'fastestuser@test.com',
            Username = 'fastestuser@test.com',
            Alias = 'alias',
            CompanyName = 'Fas Test User',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Advisor'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // create a household account
        Id hhRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account hhAcc = new Account(
            Name='FasHH TriggerTest',
            Type = 'Client',
            RecordTypeId = hhRecordTypeId,
            OwnerId = testUser.Id
        );
        insert hhAcc;
        
        // create an individual
        Id indivRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Account indAcc = new Account(Name='Fas TriggerTest', FinServ__Status__c = 'Active', Type = 'Client', RecordTypeId = indivRecordTypeId);
        insert indAcc;
        
        // get the contact portion of the individual
        Contact ctc = [SELECT Id FROM Contact WHERE AccountId = :indAcc.Id];
        
        // create a household to individual relationship
        AccountContactRelation acr1 = new AccountContactRelation();
        acr1.contactId = ctc.Id;
        acr1.AccountId = hhAcc.Id;
        acr1.FinServ__Primary__c = true;
        acr1.FinServ__PrimaryGroup__c = true;
        insert acr1;
        
        // create a financial account
        FinServ__FinancialAccount__c finacc = New FinServ__FinancialAccount__c(
            Name = 'Test Fin Acct 1',
            FinServ__PrimaryOwner__c = indAcc.Id,
            Finserv__Status__c = 'Open'
        );
        insert finacc;
        
        Id actRoleRtId = Schema.SObjectType.FinServ__FinancialAccountRole__c.getRecordTypeInfosByName().get('Account Role').getRecordTypeId();
        FinServ__FinancialAccountRole__c faRole = new FinServ__FinancialAccountRole__c(
            RecordTypeId = actRoleRtId,
            FinServ__RelatedAccount__c = indAcc.Id,
            FinServ__FinancialAccount__c = finacc.Id,
            FinServ__Role__c = 'Beneficiary',
            WEG_Per_Share__c = 50,
            WEG_Per_Stirpes__c = true
        );
        insert faRole;
        
        test.startTest();
        
        Id beneAsRtId = Schema.SObjectType.Account_Servicing__c.getRecordTypeInfosByName().get('Beneficiary Update').getRecordTypeId();
        Account_Servicing__c asv = new Account_Servicing__c(
            Related_Account__c = hhAcc.Id,
            RecordTypeId = beneAsRtId
        );
        insert asv;
        
        Id beneFasRtId = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Beneficiary Update').getRecordTypeId();
        Financial_Account_Servicing__c fas = new Financial_Account_Servicing__c(
            Account_Servicing__c = asv.Id,
            Financial_Account__c = finacc.Id,
            RecordTypeId = beneFasRtId,
            Name = finacc.Name,
            Primary_Owner__c = finacc.FinServ__PrimaryOwner__c,
            WEG_New_Account_Type__c = 'Advisory'
        );
        insert fas;
        
        fas.Status__c = 'Complete';
        update fas;
        
        test.stopTest();
    }
}