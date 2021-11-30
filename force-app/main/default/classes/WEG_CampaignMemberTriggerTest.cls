@isTest
private class WEG_CampaignMemberTriggerTest {
    
    private static testMethod void testTrigger(){
        test.startTest();
        
        // insert a new campaign
        Campaign testC1 = new Campaign(Name = 'Campaign Test 1');
        insert testC1;
        
        Lead ld = new Lead();
        ld.FirstName = 'Test WEG';
        ld.LastName = 'Lead';
        ld.Phone = '1122334455';
        ld.Email = 'lead@weg.com';
        ld.Company = 'Test WEG Lead';
        ld.Status = 'New';
        insert ld;
        
        // insert a sent campaign member
        CampaignMember testMember1 = new CampaignMember(CampaignId = testC1.Id, LeadId = ld.Id, Status = 'Sent');
        insert testMember1;
        
        // update to responded
        testMember1.Status = 'Responded';
        update testMember1;
        
        // insert a second campaign
        Campaign testC2 = new Campaign(Name = 'Campaign Test 2');
        insert testC2;
        
        // insert a responded campaign member
        CampaignMember testMember2 = new CampaignMember(CampaignId = testC2.Id, LeadId = ld.Id, Status = 'Responded');
        insert testMember2;
        
        // delete the second member
        delete testMember2;
        
        test.stopTest();
    }
}