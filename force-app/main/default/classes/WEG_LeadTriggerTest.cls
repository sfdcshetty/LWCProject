@isTest
private class WEG_LeadTriggerTest {
    private static testMethod void testTrigger() {
        test.startTest();

        // get the lead record type ids for later
        Id generalRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WEG General').getRecordTypeId();
        Id invalidRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Invalid Lead').getRecordTypeId();

        User standardUser = new User(
            LastName = 'Test',
            Email = 'testusertrigger@test.com',
            Username = 'testusertriggerfakefakefake@test.com',
            Alias = 'alias',
            CompanyName = 'testusertrigger',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert standardUser;

        // create a queue to assign to leads
        Group testQueue = new Group(Name = 'Test Group', Type = 'Queue');
        insert testQueue;

        // associate the queue to the Lead object
        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSObject queueAssoc = new QueueSObject(SobjectType = 'Lead', QueueId = testQueue.Id);
            insert queueAssoc;
        }

        // create a few offices for testing
        WEGP1_Office__c clintonOffice = new WEGP1_Office__c(
            Name = 'Clinton',
            WEGP1_GeographicRegion__c = 'WI',
            WEGP1_NationalRadius__c = 50,
            WEGP1_Location__latitude__s = 42.566968,
            WEGP1_Location__longitude__s = -88.862623
        );
        WEGP1_Office__c plymouthOffice = new WEGP1_Office__c(
            Name = 'Plymouth',
            WEGP1_GeographicRegion__c = 'MN/IA',
            WEGP1_NationalRadius__c = 50,
            WEGP1_Location__latitude__s = 44.985754,
            WEGP1_Location__longitude__s = -93.404114
        );
        WEGP1_Office__c northbrookOffice = new WEGP1_Office__c(
            Name = 'Northbrook',
            WEGP1_GeographicRegion__c = 'IL',
            WEGP1_NationalRadius__c = 50,
            WEGP1_Location__latitude__s = 42.117457,
            WEGP1_Location__longitude__s = -87.813881
        );
        WEGP1_Office__c nationalOffice = new WEGP1_Office__c(Name = 'National', WEGP1_GeographicRegion__c = 'National');
        insert clintonOffice;
        insert plymouthOffice;
        insert northbrookOffice;
        insert nationalOffice;

        // create the first standard lead (nothing special)
        Lead leadOne = new Lead(FirstName = 'Led', LastName = 'One', Email = 'lead@weg.com', Company = 'Led One', OwnerId = testQueue.Id);
        insert leadOne;

        // impersonate Melissa Data - returning codes
        // start with an invalid name
        // rejected state
        leadOne.WEGP1_PersonatorResultCodes__c = 'NE01';
        update leadOne;

        // then with an invalid address, e-mail, phone
        // rejected state
        leadOne.WEGP1_PersonatorResultCodes__c = 'AE01,ES02,PE01';
        update leadOne;

        // then an invalid address only
        // invalid state (vs reject)
        leadOne.WEGP1_PersonatorResultCodes__c = 'AE01';
        update leadOne;

        // then an invalid phone only
        // invalid state (vs reject)
        leadOne.WEGP1_PersonatorResultCodes__c = 'PE01';
        update leadOne;

        // invalidate the first lead
        leadOne.RecordTypeId = invalidRecordTypeId;
        leadOne.FirstName = 'Lead';
        leadOne.Company = 'Lead One';
        update leadOne;

        // validate the first lead, updating the owner to the queue
        leadOne.RecordTypeId = generalRecordTypeId;
        leadOne.WEGP1_UnsubscribeAllEmails__c = 'Unsubscribed';
        leadOne.WEGP1_PersonatorResultCodes__c = 'ES01';
        leadOne.OwnerId = standardUser.Id;
        // with a Boise address
        leadOne.Street = '2772 S Cole Rd';
        leadOne.State = 'ID';
        leadOne.Latitude = 43.5777;
        leadOne.Longitude = -116.2734;
        update leadOne;

        // with a Chicago address
        leadOne.Street = '233 S Wacker Dr';
        leadOne.State = 'IL';
        leadOne.Latitude = 41.8789;
        leadOne.Longitude = -87.6363;
        update leadOne;

        // finally, without an address
        leadOne.Street = null;
        leadOne.State = null;
        leadOne.Latitude = null;
        leadOne.Longitude = null;
        update leadOne;

        //delete leadOne;

        // create a second lead - unsubscribed target owned by the queue
        Lead leadTwo = new Lead(
            FirstName = 'Lead',
            LastName = 'Two',
            Email = 'test@test.com',
            Company = 'Lead Two',
            WEGP1_Classification__c = 'Target',
            WEGP1_UnsubscribeAllEmails__c = 'Unsubscribed',
            OwnerId = standardUser.Id
        );
        insert leadTwo;

        // update the lead to a suspect, owned by current user
        leadTwo.WEGP1_Classification__c = 'Suspect';
        leadTwo.OwnerId = testQueue.Id;
        update leadTwo;

        Task leadTwoTask = new Task(Subject = 'Task One', WhoId = leadTwo.Id, WEGP1_OriginalLeadID__c = leadTwo.Id);
        insert leadTwoTask;

        //Lead leadOneCheck = [SELECT Id, Owner.Type FROM Lead WHERE Id =: leadOne.Id];
        //System.AssertEquals(leadOneCheck.Owner.Type, 'User');

        merge leadOne leadTwo;

        // create the additional leads for testing
        Lead leadThree = new Lead(FirstName = 'Lead', LastName = 'Three', Phone = '1122334455', Company = 'Lead Three');
        Lead leadFour = new Lead(FirstName = 'Lead', LastName = 'Four', Phone = '1122334455', Company = 'Lead Four');
        Lead leadFive = new Lead(FirstName = 'Lead', LastName = 'Five', Phone = '1122334455', Company = 'Lead Five');
        insert leadThree;
        insert leadFour;
        insert leadFive;

        Task leadThreeTask = new Task(Subject = 'Lead Three Task', WhoId = leadThree.Id, WEGP1_OriginalLeadID__c = leadThree.Id);
        Task leadFourTask = new Task(Subject = 'Lead Four Task', WhoId = leadFour.Id, WEGP1_OriginalLeadID__c = leadFour.Id);
        Task leadFiveTask = new Task(Subject = 'Lead Five Task', WhoId = leadFive.Id, WEGP1_OriginalLeadID__c = leadFive.Id);
        insert leadThreeTask;
        insert leadFourTask;
        insert leadFiveTask;

        // attempt each merge, establishing proper parameters on the master lead prior to
        leadOne.Status = 'Unqualified';
        leadOne.ReasonforUnqualified__c = 'Age';
        update leadOne;
        merge leadOne leadThree;

        leadOne.WEGP1_NewClientTeamOpportunityAmount__c = 0;
        leadOne.Status = 'New';
        leadOne.ReasonforUnqualified__c = null;
        update leadOne;
        merge leadOne leadFour;

        leadOne.WEGP1_Age__c = '75 or Older';
        leadOne.WEGP1_NewClientTeamOpportunityAmount__c = null;
        update leadOne;
        merge leadOne leadFive;

        // create a test account for lead conversion
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId()
        );
        insert testAccount;

        // the contact is created along with the account
        Contact testContact = [SELECT Id, LastName FROM Contact WHERE AccountId = :testAccount.Id];

        // create a task for lead one
        Task leadOneTask = new Task(Subject = 'Lead One Task', WhoId = leadOne.Id, WEGP1_OriginalLeadID__c = leadOne.Id);
        insert leadOneTask;

        // convert lead one to the individual
        Database.LeadConvert leadConversion1 = new database.LeadConvert();
        leadConversion1.setLeadId(leadOne.Id);
        leadConversion1.setAccountId(testAccount.Id);
        leadConversion1.setContactId(testContact.Id);
        leadConversion1.setDoNotCreateOpportunity(true);
        leadConversion1.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr1 = Database.convertLead(leadConversion1);
        System.assert(lcr1.isSuccess());

        // create the additional leads for testing
        Lead leadSix = new Lead(FirstName = 'Lead', LastName = 'Six', Phone = '1122334455', Company = 'Lead Six');
        Lead leadSeven = new Lead(FirstName = 'Lead', LastName = 'Seven', Phone = '1122334455', Company = 'Lead Seven');
        Lead leadEight = new Lead(
            FirstName = 'Lead',
            LastName = 'Eight',
            Phone = '1122334455',
            Company = 'Lead Eight',
            WEGP1_NewClientTeamOpportunityAmount__c = 0
        );
        insert leadSix;
        insert leadSeven;
        insert leadEight;

        // create the additonal tasks
        Task leadSixTask = new Task(Subject = 'Lead Task', WhoId = leadSix.Id, WEGP1_OriginalLeadID__c = leadSix.Id);
        Task leadSevenTask = new Task(Subject = 'Lead Task', WhoId = leadSeven.Id, WEGP1_OriginalLeadID__c = leadSeven.Id);
        Task leadEightTask = new Task(Subject = 'Lead Task', WhoId = leadEight.Id, WEGP1_OriginalLeadID__c = leadEight.Id);
        insert leadSixTask;
        insert leadSevenTask;
        insert leadEightTask;

        // convert each lead to the individual, establishing proper parameters prior to
        testAccount.FinServ__Status__c = 'Deceased';
        update testAccount;

        Database.LeadConvert leadSixConvert = new database.LeadConvert();
        leadSixConvert.setLeadId(leadSix.Id);
        leadSixConvert.setAccountId(testAccount.Id);
        leadSixConvert.setContactId(testContact.Id);
        leadSixConvert.setDoNotCreateOpportunity(true);
        leadSixConvert.setConvertedStatus('Qualified');
        Database.LeadConvertResult leadSixConvertResult = Database.convertLead(leadSixConvert);
        System.assert(leadSixConvertResult.isSuccess());

        testAccount.Type = 'Client';
        testAccount.FinServ__Status__c = 'Active';
        update testAccount;

        Database.LeadConvert leadSevenConvert = new database.LeadConvert();
        leadSevenConvert.setLeadId(leadSeven.Id);
        leadSevenConvert.setAccountId(testAccount.Id);
        leadSevenConvert.setContactId(testContact.Id);
        leadSevenConvert.setDoNotCreateOpportunity(true);
        leadSevenConvert.setConvertedStatus('Qualified');
        Database.LeadConvertResult leadSevenConvertResult = Database.convertLead(leadSevenConvert);
        System.assert(leadSevenConvertResult.isSuccess());

        testAccount.Type = 'Prospect';
        update testAccount;

        Database.LeadConvert leadEightConvert = new database.LeadConvert();
        leadEightConvert.setLeadId(leadEight.Id);
        leadEightConvert.setAccountId(testAccount.Id);
        leadEightConvert.setContactId(testContact.Id);
        leadEightConvert.setDoNotCreateOpportunity(true);
        leadEightConvert.setConvertedStatus('Qualified');
        Database.LeadConvertResult leadEightConvertResult = Database.convertLead(leadEightConvert);
        System.assert(leadEightConvertResult.isSuccess());

        test.stopTest();
    }
}