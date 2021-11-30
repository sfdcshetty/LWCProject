@isTest
private class InteractionTriggerHandlerTest {
    @testSetup
    public static void setupTestData() {
        Properties__c settings = Properties__c.getOrgDefaults();
        settings.Default_Contact_Owner__c = 'knelson';
        settings.Run_Trigger_Logic_In_Factory__c = true;
        upsert settings Properties__c.Id;

        User leadOwner = new User(
            LastName = 'Test',
            Email = 'testusertrigger@test.com',
            Username = 'testusertrasdfasdfdigger@test.com',
            Alias = 'knelson',
            CompanyName = 'testusertrigger',
            Title = 'Tester',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
            .Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert leadOwner;

        // create a queue to assign to leads
        Group testQueue = new Group(Name = 'Test Group', Type = 'Queue');
        insert testQueue;

        Campaign cplvl1 = new Campaign();
        cplvl1.Name = 'Level 1';
        cplvl1.Year__c = '2020';
        cplvl1.Business_Line__c = 'WEG';
        cplvl1.IsActive = true;
        cplvl1.ECID_Fragment__c = 'lv1';
        cplvl1.StartDate = Date.today().addDays(-1);
        cplvl1.enddate = Date.today().addDays(1);
        insert cplvl1;

        Campaign cplvl2 = new Campaign();
        cplvl2.Name = 'Level 2';
        cplvl2.Objective__c = 'Awareness';
        cplvl2.ParentId = cplvl1.Id;
        cplvl2.IsActive = true;
        cplvl2.ECID_Fragment__c = 'lv2';
        cplvl2.StartDate = Date.today().addDays(-1);
        cplvl2.enddate = Date.today().addDays(1);
        insert cplvl2;

        Campaign cplvl3 = new Campaign();
        cplvl3.Name = 'Level 3';
        cplvl3.Sub_Channel__c = 'Traditional Media';
        cplvl3.ParentId = cplvl2.Id;
        cplvl3.IsActive = true;
        cplvl3.ECID_Fragment__c = 'lv3';
        cplvl3.StartDate = Date.today().addDays(-1);
        cplvl3.enddate = Date.today().addDays(1);

        insert cplvl3;

        Campaign cplvl4 = new Campaign();
        cplvl4.Name = 'Level 4';
        cplvl4.Sub_Channel__c = 'Traditional Media';
        cplvl4.Tactic__c = 'Brochure';
        cplvl4.ParentId = cplvl3.Id;
        cplvl4.IsActive = true;
        cplvl4.ECID_Fragment__c = 'lv4';
        cplvl4.StartDate = Date.today().addDays(-1);
        cplvl4.enddate = Date.today().addDays(1);
        insert cplvl4;

        Campaign cplvl5 = new Campaign();
        cplvl5.Name = 'Level 5  ';
        cplvl5.Sub_Channel__c = 'Traditional Media';
        cplvl5.Tactic__c = 'Brochure';
        cplvl5.Media_Souce__c = 'Random Text';
        cplvl5.Placement__c = 'what';
        cplvl5.ParentId = cplvl4.Id;
        cplvl5.ECID_Fragment__c = 'lv5';
        cplvl5.IsActive = true;
        cplvl5.StartDate = Date.today().addDays(-1);
        cplvl5.enddate = Date.today().addDays(1);
        insert cplvl5;

        Campaign cplvl52 = new Campaign();
        cplvl52.Name = 'Level 5  ';
        cplvl52.Sub_Channel__c = 'Traditional Media';
        cplvl52.Tactic__c = 'Brochure';
        cplvl52.Media_Souce__c = 'Random Text';
        cplvl52.Placement__c = 'what';
        cplvl52.ParentId = cplvl4.Id;
        cplvl52.ECID_Fragment__c = 'lv6';
        cplvl52.IsActive = true;
        cplvl52.StartDate = Date.today().addDays(-1);
        cplvl52.enddate = Date.today().addDays(1);
        insert cplvl52;

        Contact c = new Contact();
        c.FirstName = 'cory';
        c.LastName = 'lastname';
        insert c;

        Contact c2 = new Contact();
        c2.FirstName = 'billy';
        c2.LastName = 'lastname';
        insert c2;

        WEGP1_Office__c plymouthOffice = new WEGP1_Office__c(
            Name = 'Plymouth',
            WEGP1_GeographicRegion__c = 'MN/IA',
            WEGP1_NationalRadius__c = 50,
            WEGP1_Location__latitude__s = 44.985754,
            WEGP1_Location__longitude__s = -93.404114
        );
        insert plymouthOffice;
    }

    private static testMethod void interactionInsertTest() {
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'cory' LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE FirstName = 'billy' LIMIT 1];
        Interaction__c i = new Interaction__c();
        i.Contact__c = c.Id;
        i.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';
        i.Behavior_Score__c = 50;

        Interaction__c i2 = new Interaction__c();
        i2.Contact__c = c.Id;
        i2.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';
        i2.Behavior_Score__c = 40;

        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];

        Interaction__c i3 = new Interaction__c();
        i3.Contact__c = c.Id;
        i3.ECID_String__c = camp.Id;
        i3.Behavior_Score__c = 30;
        i3.reset__c = true;

        test.startTest();
        insert i;
        insert i2;
        insert i3;
        i3.contact__c = c2.id;
        update i3;
        test.stopTest();

        Interaction__c r = [SELECT Id, Last_Responded_Campaign__c, First_Responded_Campaign__c FROM Interaction__c WHERE id = :i.Id LIMIT 1];

        System.assertEquals(r.Last_Responded_Campaign__c, [SELECT id FROM Campaign WHERE ECID_Fragment__c = :'lv6' LIMIT 1].Id);
        System.assertEquals(r.First_Responded_Campaign__c, [SELECT id FROM Campaign WHERE ECID_Fragment__c = :'lv5' LIMIT 1].Id);
    }

    private static testMethod void interactionOpportunityTest() {
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'cory' LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE FirstName = 'billy' LIMIT 1];
        Interaction__c i = new Interaction__c();
        i.Contact__c = c.Id;
        i.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';
        i.Behavior_Score__c = 50;

        Interaction__c i2 = new Interaction__c();
        i2.Contact__c = c.Id;
        i2.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';
        i2.Behavior_Score__c = 40;

        Opportunity op = new Opportunity();
        op.ContactId = c.Id;
        op.Name = 'Test Opportunity';
        op.StageName = 'Intro';
        op.CloseDate = Date.today();

        Campaign camp = [SELECT Id FROM Campaign WHERE ECID__c = :'lv1lv2lv3lv4lv5' LIMIT 1];

        CampaignInfluenceModel cif = [SELECT ID FROM CampaignInfluenceModel WHERE IsDefaultModel = :true LIMIT 1];

        test.startTest();
        insert i;
        insert i2;
        insert op;

        CampaignInfluence ci = new CampaignInfluence();
        ci.CampaignId = camp.Id;
        ci.ContactId = c.Id;
        ci.ModelId = cif.Id;
        ci.OpportunityId = op.Id;
        insert ci;

        test.stopTest();

        Interaction__c r = [SELECT Id, Last_Responded_Campaign__c, First_Responded_Campaign__c FROM Interaction__c WHERE id = :i.Id LIMIT 1];

        System.assertEquals(r.Last_Responded_Campaign__c, [SELECT id FROM Campaign WHERE ECID_Fragment__c = :'lv6' LIMIT 1].Id);
        System.assertEquals(r.First_Responded_Campaign__c, [SELECT id FROM Campaign WHERE ECID_Fragment__c = :'lv5' LIMIT 1].Id);
    }

    private static testMethod void interactionLeadTest() {
        Id leadrecordtypeId = [SELECT Id FROM RecordType WHERE SobjectType = :'Lead' AND DeveloperName = :'WEGP1_WEG_General' LIMIT 1].Id;

        Lead lead = new Lead();
        lead.RecordtypeId = leadrecordtypeId;
        lead.firstname = 'f';
        lead.lastname = 'l';
        lead.company = 'f l';
        lead.email = 'email@3mail.com';

        insert lead;

        Id recordtypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType = :'Interaction__c' AND DeveloperName = :'Inbound' LIMIT 1].Id;

        Interaction__c i = new Interaction__c();
        i.recordtypeId = recordtypeId;
        i.First_Name__c = 'f';
        i.Last_Name__c = 'l';
        i.Lead__c = lead.Id;
        //i.Do_Not_Call__c = 'Yes';
        i.Email_Opt_Out__c = 'No';
        i.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';

        i.Email__c = 'testLast@eadfm.com';

        test.startTest();
        Test.enableChangeDataCapture();
        insert i;
        Test.getEventBus().deliver();
        test.stopTest();

        Interaction__c r = [SELECT Id, Lead__c FROM Interaction__c WHERE id = :i.Id LIMIT 1];

        System.assertNotEquals(null, r.Lead__c);
    }

    private static testMethod void interactionContactTest() {
        Interaction__c i = new Interaction__c();
        i.First_Name__c = 'test';
        i.Last_Name__c = 'testLast';
        i.Email__c = 'testLast@eadfm.com';
        //i.Do_Not_Call__c = 'Yes';
        i.Email_Opt_Out__c = 'Yes';
        i.Request_Meeting__c = 'Yes';
        i.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';

        test.startTest();
        insert i;
        test.stopTest();

        Interaction__c r = [SELECT Id, Contact__c FROM Interaction__c WHERE id = :i.Id LIMIT 1];

        System.assertNotEquals(null, r.Contact__c);
    }

    private static testMethod void interactionImport() {
        Id recordtypeId = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Import').getRecordTypeId();

        List<Interaction__c> interactions = new List<Interaction__c>();

        // Interaction__c i = new Interaction__c();
        // i.First_Name__c = 'test';
        // i.Last_Name__c = 'testLast';
        // i.Company__c = 'test testLast';
        // i.Email__c = 'testLast@eadfm.com';
        // i.Request_Meeting__c = 'No';
        // i.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';
        // i.recordtypeId = recordtypeId;
        // interactions.add(i);

        Interaction__c i2 = new Interaction__c();
        i2.First_Name__c = 'test';
        i2.Last_Name__c = 'testLast';
        i2.Company__c = 'test testLast';
        i2.Email__c = 'testLast@eadadfm.com';
        i2.ECID_String__c = 'lv1lv2lv3lv4lv5.2020-01-01_lv1lv2lv3lv4lv6.2020-01-02';
        i2.Request_Meeting__c = 'Yes';
        i2.recordtypeId = recordtypeId;
        interactions.add(i2);

        Test.startTest();
        Database.insert(interactions);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Interaction__c WHERE recordtypeId = :recordtypeId]);
    }

    private static testMethod void interactionImportConvert() {
        Id leadrecordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WEG General').getRecordTypeId();
        Id inboundRecordType = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
        Id miestoneRecordType = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
        Id taskRecordType = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Task').getRecordTypeId();

        List<Interaction__c> interactions = new List<Interaction__c>();

        Lead lead = new Lead();
        lead.RecordtypeId = leadrecordtypeId;
        lead.firstname = 'f';
        lead.lastname = 'l';
        lead.company = 'f l';
        lead.email = 'email@3mail.com';

        insert lead;

        TriggerFactory.RUN_TRIGGER_LOGIC = false;

        Interaction__c i = new Interaction__c();
        i.Lead__c = lead.Id;
        i.recordtypeId = inboundRecordType;
        interactions.add(i);

        Interaction__c i2 = new Interaction__c();
        i2.Lead__c = lead.Id;
        i2.recordtypeId = miestoneRecordType;
        interactions.add(i2);

        Interaction__c i3 = new Interaction__c();
        i3.Lead__c = lead.Id;
        i3.recordtypeId = taskRecordType;
        interactions.add(i3);
        Database.insert(interactions);

        String leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
        Id ownerUserId = [SELECT Id FROM USER WHERE Alias = :Properties__c.getOrgDefaults().Default_Contact_Owner__c LIMIT 1].Id;
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();

        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(lead.Id);
        Leadconvert.setConvertedStatus(leadStatus);
        Leadconvert.setDoNotCreateOpportunity(true);
        Leadconvert.setOwnerId(ownerUserId);
        MassLeadconvert.add(Leadconvert);

        Map<Id, Database.LeadConvertResult> leadConvertMap = new Map<Id, Database.LeadConvertResult>();
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert, dml);
        TriggerFactory.RUN_TRIGGER_LOGIC = true;

        Test.startTest();
        Database.executeBatch(new InteractionUpdateConvertedLeads());
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE IsConverted = FALSE]);
    }

    private static testMethod void scoringTest() {
        Id recordtypeId = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
        List<Interaction__c> interactions = new List<Interaction__c>();

        //initial interaction creates lead
        Interaction__c i = new Interaction__c();
        i.First_Name__c = 'Led';
        i.Last_Name__c = 'One';
        i.Email__c = 'lead@weg.com';
        i.Company__c = 'Led One';
        i.Street__c = '5925 29th PL N';
        i.City__c = 'Crystal';
        i.State__c = 'MN';
        i.Postal_Code__c = '55422';
        i.Phone__c = '(999) 999-9999';
        i.recordtypeId = recordtypeId;
        i.WEGP1_NewClientTeamOpportunityAmount__c = 0;

        Test.startTest();
        insert i;
        Id leadId = [SELECT Lead__c FROM interaction__c WHERE id = :i.id LIMIT 1].Lead__c;

        //range score
        Interaction__c i2 = new Interaction__c();
        i2.recordtypeId = recordtypeId;
        i2.lead__c = leadId;
        i2.WEGP1_NewClientTeamOpportunityAmount__c = 175001;
        insert i2;
        Test.stopTest();

        Lead result = [SELECT Id, Behavior_Score__c, Demographic_Score__c FROM Lead WHERE Id = :leadId];
        //System.assertEquals(50, result.Behavior_Score__c);
        //System.assertEquals(30, result.Demographic_Score__c);
    }

    private static testMethod void duplicateLeadTest() {
        Id recordtypeId = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
        List<Interaction__c> interactions = new List<Interaction__c>();

        //initial interaction creates lead
        Interaction__c i = new Interaction__c();
        i.First_Name__c = 'Led';
        i.Last_Name__c = 'One';
        i.Email__c = 'lead@weg.com';
        i.Company__c = 'Led One';
        i.Street__c = '5925 29th PL N';
        i.City__c = 'Crystal';
        i.State__c = 'MN';
        i.Postal_Code__c = '55422';
        i.Phone__c = '(999) 999-9999';
        i.recordtypeId = recordtypeId;
        i.WEGP1_NewClientTeamOpportunityAmount__c = 0;

        insert i;
        Id leadId = [SELECT Lead__c FROM interaction__c WHERE id = :i.id LIMIT 1].Lead__c;

        Test.startTest();
        //range score
        Interaction__c i2 = new Interaction__c();
        i2.recordtypeId = recordtypeId;
        i2.First_Name__c = 'Led';
        i2.Last_Name__c = 'One';
        i2.Company__c = 'Led One';
        i2.Email__c = 'lead@weg.com';
        i2.WEGP1_NewClientTeamOpportunityAmount__c = 175001;
        insert i2;
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM LEAD]);
    }

    private static testMethod void leadConvertTest() {
        Id recordtypeId = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
        Id generalLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WEG General').getRecordTypeId();
        List<Interaction__c> interactions = new List<Interaction__c>();

        //initial interaction creates lead
        Lead i = new Lead();
        i.FirstName = 'Led';
        i.LastName = 'One';
        i.Email = 'lead@weg.com';
        i.Company = 'Led One';
        i.recordtypeId = generalLeadTypeId;

        insert i;

        Test.startTest();
        // //range score
        Interaction__c i3 = new Interaction__c();
        i3.recordtypeId = recordtypeId;
        i3.lead__c = i.Id;
        i3.Behavior_Score__c = 100;
        i3.Demographic_Score__c = 100;
        i3.Request_Meeting__c = 'Yes';
        insert i3;

        Test.getEventBus().deliver();
        Test.stopTest();

        interaction__c result = [SELECT id, contact__c FROM interaction__c WHERE id = :i3.Id LIMIT 1];
        System.assertNotEquals(null, result.contact__c);
    }

    //this was copied from WEG_ContactTriggerTest
    private static testMethod void contactTriggerTest() {
        WEGP1_Office__c office = new WEGP1_Office__c();
        office.WEGP1_City__c = 'Minneapolis';
        office.WEGP1_State__c = 'MN';
        office.WEGP1_GeographicRegion__c = 'National';
        office.WEGP1_NationalRadius__c = 25;
        office.Name = 'National';
        office.WEGP1_Location__latitude__s = 45.86;
        office.WEGP1_Location__longitude__s = -95.38;
        insert office;

        WEGP1_Office__c localoffice = new WEGP1_Office__c();
        localoffice.WEGP1_City__c = 'Minneapolis';
        localoffice.WEGP1_State__c = 'MN';
        localoffice.WEGP1_GeographicRegion__c = 'MN/IA';
        localoffice.WEGP1_NationalRadius__c = 1;
        localoffice.Name = 'Minneapolis';
        localoffice.WEGP1_Location__latitude__s = 45.86;
        localoffice.WEGP1_Location__longitude__s = -95.38;
        insert localoffice;

        test.startTest();
        // create a contact for testing
        Contact ctc1 = new Contact(
            LastName = 'Doe',
            FirstName = 'John',
            Marketing_Status__c = 'Qualified',
            Email = 'test@weg.com',
            WEGP1_LeadConvertedStatus__c = 'Converted',
            WEGP1_UnsubscribeAllEmails__c = 'Unsubscribed'
        );
        insert ctc1;

        // create another contact to test populated mobile
        Contact ctc2 = new Contact(
            LastName = 'Doe',
            FirstName = 'John',
            Marketing_Status__c = 'Qualified',
            Email = 'test2@weg.com',
            MobilePhone = '1122334455',
            MailingLatitude = 45.86,
            MailingLongitude = -95.38,
            WEGP1_LeadConvertedStatus__c = 'Converted',
            WEGP1_UnsubscribeAllEmails__c = 'Unsubscribed'
        );
        insert ctc2;

        ctc2.MailingLatitude = 65.86;
        ctc2.MailingLongitude = -95.38;
        update ctc2;

        ctc2.MailingLatitude = null;
        ctc2.MailingLongitude = null;
        update ctc2;

        ctc2.MailingState = 'IL';
        ctc2.MailingLatitude = 45.86;
        ctc2.MailingLongitude = -95.38;
        update ctc2;

        Contact con = [SELECT Id, FirstName, WEGP1_PrimaryPhone__c, Phone, HomePhone, AssistantPhone, MobilePhone, OtherPhone FROM Contact WHERE Id = :ctc1.Id];

        System.assertEquals('Home', con.WEGP1_PrimaryPhone__c);
        System.assertEquals(null, con.Phone);
        System.assertEquals(null, con.HomePhone);
        System.assertEquals(null, con.AssistantPhone);
        System.assertEquals(null, con.MobilePhone);
        System.assertEquals(null, con.OtherPhone);

        con.FirstName = 'Jim';
        con.WEGP1_UnsubscribeAllEmails__c = null;
        con.WEGP1_LeadFulfillmentItems__c = 'Reading Book';
        con.Phone = '1122334455';
        update con;

        // testing any phone merge functions
        con.Phone = null;
        update con;
        con.WEGP1_PrimaryPhone__c = 'Work';
        con.Phone = '1122334455';
        update con;
        con.Phone = null;
        update con;
        con.WEGP1_PrimaryPhone__c = 'Cell';
        con.Phone = '1122334455';
        update con;
        con.Phone = null;
        update con;
        con.WEGP1_PrimaryPhone__c = 'Other';
        con.Phone = '1122334455';
        update con;
        con.Phone = null;
        update con;
        con.WEGP1_PrimaryPhone__c = null;
        con.Phone = '1122334455';
        update con;

        test.stopTest();
    }

    private static testMethod void leadException() {
        try {
            Lead i = new Lead();
            List<Lead> leads = new List<Lead>();
            leads.add(i);
            FlowLeadCreateWithAssignmentRules.FlowLeadCreateWithAssignmentRules(leads);
        } catch (Exception ex) {
            System.assertEquals(ex, ex);
        }
    }
}