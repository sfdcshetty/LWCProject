@isTest
private class WEG_AccountTriggerTest {
    
    private static testMethod void testTrigger(){
        
        User wetsUser = new User(
            LastName = 'Test',
            Email = 'trigger.test@wealthenhancement.com',
            Username = 'trigger.test@wealthenhancement.com',
            Alias = 'alias',
            CompanyName = 'testusertrigger',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            WETS_Authorized__c = true
        );
        insert wetsUser;
        
        test.startTest();
        
        // Insert Household Account
        System.debug('>>>>>>>> Inserting Tim and Paul Allen.');
        Account hhAcc = new Account(Name='Tim and Paul Allen',
                                    Type = 'Client',
                                    WEG_Trust_Officer__c = wetsUser.Id,
                                    recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc;
        
        // create an empty household
        Account emptyHousehold = new Account(Name='Empty Household',
                                             Type = 'Client',
                                             recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert emptyHousehold;
        
        // use it to update the trust officer
        emptyHousehold.WEG_Trust_Officer__c = wetsUser.Id;
        update emptyHousehold;
        
        // insert the first individual
        System.debug('>>>>>>>> Inserting Tim Allen.');
        Account indAcc1 = new Account(Name='Tim Allen', FinServ__Status__c = 'Active', Type = 'Client'
                                      , recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc1;
        
        // insert the second individual
        System.debug('>>>>>>>> Inserting Paul Allen.');
        Account indAcc2 = new Account(Name='Paul Allen', FinServ__Status__c = 'Active', Type = 'Client'
                                      , recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc2;
        
        // get the contact portions of the individuals of the individual
        System.debug('>>>>>>>> Fetching Contacts.');
        Contact ctc1 = [SELECT Id FROM Contact WHERE AccountId = :indAcc1.Id];
        Contact ctc2 = [SELECT Id FROM Contact WHERE AccountId = :indAcc2.Id];
        
        // set the FinServ Primary Contact for both individuals
        // otherwise it doesn't seem to happen in test
        System.debug('>>>>>>>> Set the FinServ Primary Contact for both individuals.');
        indAcc1.FinServ__PrimaryContact__c = ctc1.Id;
        update indAcc1;
        indAcc2.FinServ__PrimaryContact__c = ctc2.Id;
        update indAcc2;
        
        // create the first relationship
        System.debug('>>>>>>>> Inserting Relationship 1');
        AccountContactRelation acr1 = new AccountContactRelation();
        acr1.contactId = ctc1.Id;
        acr1.AccountId = hhAcc.Id;
        acr1.FinServ__Primary__c = true;
        acr1.FinServ__PrimaryGroup__c = true;
        insert acr1;
        
        // create the second relationship
        System.debug('>>>>>>>> Inserting Relationship 2');
        AccountContactRelation acr2 = new AccountContactRelation();
        acr2.contactId = ctc2.Id;
        acr2.AccountId = hhAcc.Id;
        acr2.FinServ__Primary__c = false;
        acr2.FinServ__PrimaryGroup__c = true;
        insert acr2;
        
        // update the primary and secondary fields of the household
        // otherwise it doesn't seem to happen in test
        System.debug('>>>>>>>> Updating Primary & Secondary Fields');
        hhAcc.WEGP1_Primary_Individual__c = ctc1.Id;
        hhAcc.WEGP1_Secondary_Individual__c = ctc2.Id;
        update hhAcc;
        
        System.assertEquals(indAcc1.FinServ__PrimaryContact__c, hhAcc.WEGP1_Primary_Individual__c);
        System.assertEquals(indAcc2.FinServ__PrimaryContact__c, hhAcc.WEGP1_Secondary_Individual__c);
        
        // insert a third individual (for the referred by)
        System.debug('>>>>>>>> Inserting Bruce Wayne.');
        Account indAcc3 = new Account(Name='Bruce Wayne', FinServ__Status__c = 'Active', Type = 'Client'
                                      , recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert indAcc3;
        
        // get the contact created by individual 3
        Contact ctc3 = [SELECT Id FROM Contact WHERE AccountId = :indAcc3.Id];
        
        // update the status, classification, and lead segmentation
        System.debug('>>>>>>>> Updating Name, Status, Classification, and Lead Segmentation.');
        hhAcc.Name = 'Tom and Cindy Gardner';
        hhAcc.FinServ__Status__c = 'Deceased';
        hhAcc.WEGP1_ReasonForInactive__c = 'No Opportunity';
        hhAcc.WEGP1_ReasonForNoOpportunity__c = 'Age';
        hhAcc.Type = 'Prospect';
        hhAcc.WEGP1_Lead_Type__c = 'Marketing';
        hhAcc.WEGP1_Lead_SubType__c = 'Traditional';
        hhAcc.WEGP1_Lead_Type_Detail__c = 'General Website';
        hhAcc.WEG_ReferredBy__c = ctc3.Id; // using contact 3 to avoid circular error
        update hhAcc;
        
        // get the updated individuals and assert
        Account indAccUpdated1 = [SELECT Id, FinServ__Status__c, WEGP1_ReasonForInactive__c, WEGP1_ReasonForNoOpportunity__c, Type
                                  , FinServ__PrimaryContact__r.WEGP1_Type__c, FinServ__PrimaryContact__r.WEGP1_SubType__c, FinServ__PrimaryContact__r.WEGP1_TypeDetail__c
                                  , FinServ__PrimaryContact__r.WEGP1_ReferredBy__c
                                  FROM Account WHERE Id = :indAcc1.Id];
        Account indAccUpdated2 = [SELECT Id, FinServ__Status__c, WEGP1_ReasonForInactive__c, WEGP1_ReasonForNoOpportunity__c, Type
                                  , FinServ__PrimaryContact__r.WEGP1_Type__c, FinServ__PrimaryContact__r.WEGP1_SubType__c, FinServ__PrimaryContact__r.WEGP1_TypeDetail__c
                                  , FinServ__PrimaryContact__r.WEGP1_ReferredBy__c
                                  FROM Account WHERE Id = :indAcc2.Id];
        
        System.assertEquals('Deceased', indAccUpdated1.FinServ__Status__c);
        System.assertEquals('Deceased', indAccUpdated2.FinServ__Status__c);
        System.assertEquals('No Opportunity', indAccUpdated1.WEGP1_ReasonForInactive__c);
        System.assertEquals('No Opportunity', indAccUpdated2.WEGP1_ReasonForInactive__c);
        System.assertEquals('Age', indAccUpdated1.WEGP1_ReasonForNoOpportunity__c);
        System.assertEquals('Age', indAccUpdated2.WEGP1_ReasonForNoOpportunity__c);
        System.assertEquals('Prospect', indAccUpdated1.Type);
        System.assertEquals('Prospect', indAccUpdated2.Type);
        System.assertEquals('Marketing', indAccUpdated1.FinServ__PrimaryContact__r.WEGP1_Type__c);
        System.assertEquals('Marketing', indAccUpdated2.FinServ__PrimaryContact__r.WEGP1_Type__c);
        System.assertEquals('Traditional', indAccUpdated1.FinServ__PrimaryContact__r.WEGP1_SubType__c);
        System.assertEquals('Traditional', indAccUpdated2.FinServ__PrimaryContact__r.WEGP1_SubType__c);
        System.assertEquals('General Website', indAccUpdated1.FinServ__PrimaryContact__r.WEGP1_TypeDetail__c);
        System.assertEquals('General Website', indAccUpdated2.FinServ__PrimaryContact__r.WEGP1_TypeDetail__c);
        System.assertEquals(ctc3.Id, indAccUpdated1.FinServ__PrimaryContact__r.WEGP1_ReferredBy__c);
        System.assertEquals(ctc3.Id, indAccUpdated2.FinServ__PrimaryContact__r.WEGP1_ReferredBy__c);
        
        test.stopTest();
  }
}