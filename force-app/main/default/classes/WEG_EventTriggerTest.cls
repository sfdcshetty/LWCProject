@isTest
public class WEG_EventTriggerTest {
    
    private static testMethod void testTrigger() {
        test.startTest();
        
        // Insert Household Account
        System.debug('>>>>>>>> Inserting Tim and Paul Allen.');
        Account hhAcc = new Account(Name='Tim and Paul Allen', Type = 'Client'
                                    , recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        insert hhAcc;
        
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
        
        // insert new campaigns
        Campaign testCampaign1 = new Campaign(Name = 'Campaign Test 1');
        insert testCampaign1;
        
        Campaign testCampaign2 = new Campaign(Name = 'Campaign Test 2');
        insert testCampaign2;
        
        // assign each individual to each campaign
        CampaignMember testMember1 = new CampaignMember(CampaignId = testCampaign1.Id, ContactId = ctc1.Id, Status = 'Responded', Camp_Inf__z_Magic_Robot_Override_Response_Date__c = date.newInstance(2017, 8, 15));
        insert testMember1;
        
        CampaignMember testMember2 = new CampaignMember(CampaignId = testCampaign2.Id, ContactId = ctc2.Id, Status = 'Responded', Camp_Inf__z_Magic_Robot_Override_Response_Date__c = date.newInstance(2018, 8, 15));
        insert testMember2;
        
        // create an opportunity
        Opportunity testOpportunity = new Opportunity(
        	Name = 'Test Opportunity',
            Household__c = hhAcc.Id,
            CloseDate = date.newInstance(2018, 10, 1),
            StageName = 'Closed Won'
        );
        insert testOpportunity;
        
        // create the event
        Event evt = new Event(
            WhatId = testOpportunity.Id,
            WEGP1_MeetingType__c = 'Needs Analysis',
        	StartDateTime = datetime.newInstance(2018, 10, 1),
            EndDateTime = datetime.newInstance(2018, 10, 1)
        );
        insert evt;
        
        test.stopTest();
    }
}