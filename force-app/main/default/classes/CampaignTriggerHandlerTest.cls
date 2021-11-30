@istest
private class CampaignTriggerHandlerTest {
    @testSetup
    public static void setupTestData() {
    }

    private static testMethod void setCampaignNameTest() {
        test.startTest();

        Map<String, Id> CampaignRecordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = :'Campaign']) {
            CampaignRecordTypeMap.put(rt.Name, rt.Id);
        }

        Campaign cplvl1 = new Campaign();
        cplvl1.RecordtypeId = CampaignRecordTypeMap.get('Marketing');
        cplvl1.Name = 'Level 1';
        cplvl1.Year__c = '2020';
        cplvl1.Business_Line__c = 'WEG';
        cplvl1.IsActive = true;
        cplvl1.ECID_Fragment__c = 'lv1';
        insert cplvl1;

        Campaign cplvl2 = new Campaign();
        cplvl2.RecordtypeId = CampaignRecordTypeMap.get('Marketing');
        cplvl2.Name = 'Level 2';
        cplvl2.Objective__c = 'Awareness';
        cplvl2.ParentId = cplvl1.Id;
        cplvl2.IsActive = true;
        cplvl2.ECID_Fragment__c = 'lv2';
        insert cplvl2;

        Campaign cplvl3 = new Campaign();
        cplvl3.RecordtypeId = CampaignRecordTypeMap.get('Marketing');
        cplvl3.Name = 'Level 3';
        cplvl3.Persona__c = 'Traditional Media';
        cplvl3.ParentId = cplvl2.Id;
        cplvl3.IsActive = true;
        cplvl3.ECID_Fragment__c = 'lv3';
        insert cplvl3;

        Campaign cplvl4 = new Campaign();
        cplvl4.RecordtypeId = CampaignRecordTypeMap.get('Marketing');
        cplvl4.Name = 'Level 4';
        cplvl4.Sub_Channel__c = 'Traditional Media';
        cplvl4.Topic__c = 'Brochure';
        cplvl4.ParentId = cplvl3.Id;
        cplvl4.IsActive = true;
        cplvl4.ECID_Fragment__c = 'lv4';
        insert cplvl4;

        Campaign cplvl5 = new Campaign();
        cplvl5.RecordtypeId = CampaignRecordTypeMap.get('Marketing');
        cplvl5.Name = 'Level 5  ';
        cplvl5.Sub_Channel__c = 'Traditional Media';
        cplvl5.Tactic__c = 'Brochure';
        cplvl5.Content_Title__c = 'Random Text';
        cplvl5.Placement__c = 'what';
        cplvl5.ParentId = cplvl4.Id;
        cplvl5.ECID_Fragment__c = 'lv5';
        cplvl5.WEGP1_Region__c = 'TX';
        cplvl5.IsActive = true;
        insert cplvl5;

        Campaign cplvl12 = new Campaign();
        cplvl12.RecordtypeId = CampaignRecordTypeMap.get('Advisor');
        cplvl12.Name = 'Level 1';
        cplvl12.Year__c = '2020';
        cplvl12.Business_Line__c = 'WEG';
        cplvl12.IsActive = true;
        cplvl12.ECID_Fragment__c = 'lv1';
        insert cplvl12;

        Campaign cplvl22 = new Campaign();
        cplvl22.RecordtypeId = CampaignRecordTypeMap.get('Advisor');
        cplvl22.Name = 'Level 2';
        cplvl22.Year__c = '2020';
        cplvl22.Objective__c = 'Awareness';
        cplvl22.ParentId = cplvl12.Id;
        cplvl22.IsActive = true;
        cplvl22.ECID_Fragment__c = 'lv2';
        insert cplvl22;

        Campaign cplvl32 = new Campaign();
        cplvl32.RecordtypeId = CampaignRecordTypeMap.get('Advisor');
        cplvl32.Name = 'Level 3';
        cplvl32.Persona__c = 'Traditional Media';
        cplvl32.ParentId = cplvl22.Id;
        cplvl32.IsActive = true;
        cplvl32.WEGP1_Region__c = 'TX';
        cplvl32.ECID_Fragment__c = 'lv3';
        insert cplvl32;

        Campaign cplvl42 = new Campaign();
        cplvl42.RecordtypeId = CampaignRecordTypeMap.get('Advisor');
        cplvl42.Name = 'Level 4';
        cplvl42.Sub_Channel__c = 'Traditional Media';
        cplvl42.Topic__c = 'Brochure';
        cplvl42.Objective__c = 'Awareness';
        cplvl42.ParentId = cplvl32.Id;
        cplvl42.IsActive = true;
        cplvl42.ECID_Fragment__c = 'lv4';
        insert cplvl42;

        Campaign cplvl52 = new Campaign();
        cplvl52.RecordtypeId = CampaignRecordTypeMap.get('Advisor');
        cplvl52.Name = 'Level 5  ';
        cplvl52.Sub_Channel__c = 'Traditional Media';
        cplvl52.Tactic__c = 'Brochure';
        cplvl52.Content_Title__c = 'Random Text';
        cplvl52.Placement__c = 'what';
        cplvl52.ParentId = cplvl42.Id;
        cplvl52.ECID_Fragment__c = 'lv5';
        cplvl52.WEGP1_Region__c = 'TX';
        cplvl52.IsActive = true;
        insert cplvl52;

        test.stopTest();
    }

    private static testMethod void insertDuplicate() {
        test.startTest();

        Campaign cplvl1 = new Campaign();
        cplvl1.Name = 'Level 1';
        cplvl1.Year__c = '2020';
        cplvl1.Business_Line__c = 'WEG';
        cplvl1.IsActive = true;
        cplvl1.ECID_Fragment__c = 'lv1';
        insert cplvl1;

        Campaign cplvl12 = new Campaign();
        cplvl12.Name = 'Level 12';
        cplvl12.Year__c = '2020';
        cplvl12.Business_Line__c = 'WEG';
        cplvl12.IsActive = true;
        cplvl12.ECID_Fragment__c = 'lv1';
        insert cplvl12;

        Campaign cplvl2 = new Campaign();
        cplvl2.Name = 'Level 2';
        cplvl2.Objective__c = 'Awareness';
        cplvl2.ParentId = cplvl1.Id;
        cplvl2.IsActive = true;
        cplvl2.ECID_Fragment__c = 'lv2';
        insert cplvl2;

        Campaign cplvl22 = new Campaign();
        cplvl22.Name = 'Level 22';
        cplvl22.Objective__c = 'Awareness';
        cplvl22.ParentId = cplvl1.Id;
        cplvl22.IsActive = true;
        cplvl22.ECID_Fragment__c = 'lv2';
        insert cplvl22;

        test.stopTest();

        for (Campaign campaign : [SELECT Id, Name, ECID_Fragment__c, ECID__c, RecordTypeId FROM Campaign WHERE Id = :cplvl12.Id]) {
            System.assertNotEquals('lv1', campaign.ECID_Fragment__c);
        }

        for (Campaign campaign : [SELECT Id, Name, ECID_Fragment__c, ECID__c, RecordTypeId FROM Campaign WHERE Id = :cplvl12.Id]) {
            System.assertNotEquals('lv2', campaign.ECID_Fragment__c);
        }
    }

    private static testMethod void updateDuplicate() {
        test.startTest();

        Campaign cplvl1 = new Campaign();
        cplvl1.Name = 'Level 1';
        cplvl1.Year__c = '2020';
        cplvl1.Business_Line__c = 'WEG';
        cplvl1.IsActive = true;
        cplvl1.ECID_Fragment__c = 'lv1';
        insert cplvl1;

        Campaign cplvl12 = new Campaign();
        cplvl12.Name = 'Level 12';
        cplvl12.Year__c = '2020';
        cplvl12.Business_Line__c = 'WEG';
        cplvl12.IsActive = true;
        cplvl12.ECID_Fragment__c = 'ls1';
        insert cplvl12;

        Campaign cplvl2 = new Campaign();
        cplvl2.Name = 'Level 2';
        cplvl2.Objective__c = 'Awareness';
        cplvl2.ParentId = cplvl1.Id;
        cplvl2.IsActive = true;
        cplvl2.ECID_Fragment__c = 'lv2';
        insert cplvl2;

        Campaign cplvl22 = new Campaign();
        cplvl22.Name = 'Level 22';
        cplvl22.Objective__c = 'Awareness';
        cplvl22.ParentId = cplvl1.Id;
        cplvl22.IsActive = true;
        cplvl22.ECID_Fragment__c = 'ls2';
        insert cplvl22;

        cplvl12.ECID_Fragment__c = 'lv1';
        cplvl22.ECID_Fragment__c = 'lv2';

        update cplvl12;
        update cplvl22;

        test.stopTest();

        for (Campaign campaign : [SELECT Id, Name, ECID_Fragment__c, ECID__c, RecordTypeId FROM Campaign WHERE Id = :cplvl12.Id]) {
            System.assertNotEquals('lv1', campaign.ECID_Fragment__c);
        }

        for (Campaign campaign : [SELECT Id, Name, ECID_Fragment__c, ECID__c, RecordTypeId FROM Campaign WHERE Id = :cplvl12.Id]) {
            System.assertNotEquals('lv2', campaign.ECID_Fragment__c);
        }
    }

    private static testMethod void batchTest() {
        test.startTest();

        Campaign cplvl1 = new Campaign();
        cplvl1.Name = 'Level 1';
        cplvl1.Year__c = '2020';
        cplvl1.Business_Line__c = 'WEG';
        cplvl1.IsActive = true;
        cplvl1.ECID_Fragment__c = 'lv1';
        insert cplvl1;

        Campaign cplvl2 = new Campaign();
        cplvl2.Name = 'Level 2';
        cplvl2.Objective__c = 'Awareness';
        cplvl2.ParentId = cplvl1.Id;
        cplvl2.IsActive = true;
        cplvl2.ECID_Fragment__c = 'lv2';
        insert cplvl2;

        Campaign cplvl3 = new Campaign();
        cplvl3.Name = 'Level 3';
        cplvl3.Sub_Channel__c = 'Traditional Media';
        cplvl3.ParentId = cplvl2.Id;
        cplvl3.IsActive = true;
        cplvl3.ECID_Fragment__c = 'lv3';
        insert cplvl3;

        Campaign cplvl4 = new Campaign();
        cplvl4.Name = 'Level 4';
        cplvl4.Sub_Channel__c = 'Traditional Media';
        cplvl4.Tactic__c = 'Brochure';
        cplvl4.ParentId = cplvl3.Id;
        cplvl4.IsActive = true;
        cplvl4.ECID_Fragment__c = 'lv4';
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
        insert cplvl5;

        cplvl1.ECID_Fragment__c = 'ls1';
        update cplvl1;

        test.stopTest();

        for (Campaign campaign : [SELECT ID, ECID__c FROM Campaign]) {
            System.assertEquals('ls1', campaign.ECID__c.subString(0, 3));
        }
    }
}