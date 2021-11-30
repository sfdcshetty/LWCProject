@isTest(seeAllData=true)
private class WEG_CampaignTriggerTest {
    
    private static testMethod void testTrigger(){
        
        test.startTest();
        
        // list to hold all created campaigns
        List<Campaign> testCampaigns = new List<Campaign>();
        
        // create test campaigns
        
        // invited type
        Campaign caTest = new Campaign(Name = 'CA Test', Type = 'Client Appreciation');
        testCampaigns.add(caTest);
        
        // email type
        Campaign emailTest = new Campaign(Name = 'Email Test', Type = 'Email Campaigns (Paid)');
        testCampaigns.add(emailTest);
        
        // responded type
        Campaign respTest = new Campaign(Name = 'Responded Test', Type = 'Brochure');
        testCampaigns.add(respTest);
        
        insert testCampaigns;
        
        List<CampaignMemberStatus> defaultMemberStatuses = [SELECT Id, CampaignId, Label FROM CampaignMemberStatus WHERE CampaignId = :respTest.Id];
        System.assertEquals(1, defaultMemberStatuses.size());
        
        test.stopTest();
    }
}