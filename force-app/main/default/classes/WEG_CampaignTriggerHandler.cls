public class WEG_CampaignTriggerHandler
{
    private List<Campaign> insertedCampaigns = new List<Campaign>();
    private List<Id> insertedCampaignIds = new List<Id>();
    
    private List<CampaignMemberStatus> defaultMemberStatuses = new List<CampaignMemberStatus>();
    private List<CampaignMemberStatus> newMemberStatuses = new List<CampaignMemberStatus>();
    private List<CampaignMemberStatus> updateMemberStatuses = new List<CampaignMemberStatus>();
    private List<CampaignMemberStatus> deleteMemberStatuses = new List<CampaignMemberStatus>();
    
    public void afterInsert() {
        // iterate the inserted campaigns
        for (Campaign campaign : (List<Campaign>)Trigger.new) {
            insertedCampaignIds.add(campaign.Id);
            insertedCampaigns.add(campaign);
        }
        
        // update the member statuses for the inserted campaign(s)
        setMemberStatuses();
    }
    
    private void setMemberStatuses() {
        // get the campaign member statuses of the inserted campaigns
        defaultMemberStatuses = [SELECT Id, CampaignId, Label FROM CampaignMemberStatus WHERE CampaignId IN :insertedCampaignIds];
        
        // lists to track removal of default
        List<String> invitedTypes = new List<String> {'Client Appreciation','Client Education','Prospecting Event', 'Webinar'};
        List<String> emailTypes = new List<String> {'Email Campaigns (Paid)','Email Campaigns (Unpaid)','AD','SAN','WAS'};
        List<String> respondedTypes = new List<String> {'Affiliate Marketing','Brochure','General Website','Magazine (Ad)','Magazine (Publishing)'
            ,'Native Advertising','Newspaper (Ad)','Newspaper (Publishing)','Online Display','Other','Paid Search','Public Relations','Radio Ad'
            ,'Radio Show','Referral','Remarketing','Social Media','TV','TV Ad','TV Show','Yellow Pages'};
        
        // iterate the created campaigns, creating new members statuses
        for (Campaign campaign : insertedCampaigns) {
            System.debug('>>>>>>>>>>>>>>>> Campaign Type: ' + campaign.Type);
                        
            // Invited/Registered/Attended
            if (invitedTypes.contains(campaign.Type))
                SetInvitedMemberStatus(campaign.Id);
            
            // Email
            else if (emailTypes.contains(campaign.Type))
                SetEmailMemberStatus(campaign.Id);
            
            // Responded
            else if (respondedTypes.contains(campaign.Type))
                SetRespondedMemberStatus(campaign.Id);
            
            // Sent/Responded
            // do nothing
        }
        
        // insert any member statues
        if (newMemberStatuses.size() > 0) {
            try { insert newMemberStatuses; } catch (DmlException ex) { System.debug('An unexpected error has occurred: ' + ex.getMessage()); }
        }
        
        // update any member statues
        if (updateMemberStatuses.size() > 0) {
            try { update updateMemberStatuses; } catch (DmlException ex) { System.debug('An unexpected error has occurred: ' + ex.getMessage()); }
        }
        
        // delete any member statues
        if (deleteMemberStatuses.size() > 0) {
            try { delete deleteMemberStatuses; } catch (DmlException ex) { System.debug('An unexpected error has occurred: ' + ex.getMessage()); }
        }
    }
    
    // Responded
    private void SetRespondedMemberStatus(Id campaignId) {
        System.debug('>>>>>>>>>>>>>>>> Set Responded');
        
        // remove the sent member status
        // update the responded member status
        for (CampaignMemberStatus memberStatus : defaultMemberStatuses) {
            if (memberStatus.CampaignId == campaignId && memberStatus.Label == 'Sent')
                deleteMemberStatuses.add(memberStatus);
            else if (memberStatus.CampaignId == campaignId) {
                memberStatus.IsDefault = true;
                memberStatus.HasResponded = true;
                updateMemberStatuses.add(memberStatus);
            }
        }
    }
    
    // Invited / Registered / Attended
    private void SetInvitedMemberStatus(Id campaignId) {
        System.debug('>>>>>>>>>>>>>>>> Set Invited');
        
        // create the invited member status
        CampaignMemberStatus invitedMemberStatus = new CampaignMemberStatus();
        invitedMemberStatus.CampaignId = campaignId;
        invitedMemberStatus.Label = 'Invited';
        invitedMemberStatus.IsDefault = true;
        newMemberStatuses.add(invitedMemberStatus);
        
        // create the registered member status
        CampaignMemberStatus registeredMemberStatus = new CampaignMemberStatus();
        registeredMemberStatus.CampaignId = campaignId;
        registeredMemberStatus.Label = 'Registered';
        registeredMemberStatus.HasResponded = true;
        newMemberStatuses.add(registeredMemberStatus);
        
        // create the attended member status
        CampaignMemberStatus attendedMemberStatus = new CampaignMemberStatus();
        attendedMemberStatus.CampaignId = campaignId;
        attendedMemberStatus.Label = 'Attended';
        attendedMemberStatus.HasResponded = true;
        newMemberStatuses.add(attendedMemberStatus);
        
        // create the attended member status
        CampaignMemberStatus didNotAttendMemberStatus = new CampaignMemberStatus();
        didNotAttendMemberStatus.CampaignId = campaignId;
        didNotAttendMemberStatus.Label = 'Did Not Attend';
        didNotAttendMemberStatus.HasResponded = true;
        newMemberStatuses.add(didNotAttendMemberStatus);
        
        // remove all other member statuses
        for (CampaignMemberStatus memberStatus : defaultMemberStatuses) {
            if (memberStatus.CampaignId == campaignId)
                deleteMemberStatuses.add(memberStatus);
        }
    }
    
    // Sent / Delivered / Opened / Clicked / Bounced / Unsubscribed
    private void SetEmailMemberStatus(Id campaignId) {
        System.debug('>>>>>>>>>>>>>>>> Set Email');
        
        // create the delivered member status
        CampaignMemberStatus deliveredMemberStatus = new CampaignMemberStatus();
        deliveredMemberStatus.CampaignId = campaignId;
        deliveredMemberStatus.Label = 'Delivered';
        newMemberStatuses.add(deliveredMemberStatus);
        
        // create the opened member status
        CampaignMemberStatus openedMemberStatus = new CampaignMemberStatus();
        openedMemberStatus.CampaignId = campaignId;
        openedMemberStatus.Label = 'Opened';
        newMemberStatuses.add(openedMemberStatus);
        
        // create the clicked member status
        CampaignMemberStatus clickedMemberStatus = new CampaignMemberStatus();
        clickedMemberStatus.CampaignId = campaignId;
        clickedMemberStatus.Label = 'Clicked';
        clickedMemberStatus.HasResponded = true;
        newMemberStatuses.add(clickedMemberStatus);
        
        // create the bounced member status
        CampaignMemberStatus bouncedMemberStatus = new CampaignMemberStatus();
        bouncedMemberStatus.CampaignId = campaignId;
        bouncedMemberStatus.Label = 'Bounced';
        newMemberStatuses.add(bouncedMemberStatus);
        
        // create the unsubscribe member status
        CampaignMemberStatus unsubMemberStatus = new CampaignMemberStatus();
        unsubMemberStatus.CampaignId = campaignId;
        unsubMemberStatus.Label = 'Unsubscribed';
        newMemberStatuses.add(unsubMemberStatus);
        
        // remove the responded member status
        //for (CampaignMemberStatus memberStatus : defaultMemberStatuses) {
            //if (memberStatus.CampaignId == campaignId && memberStatus.Label == 'Responded')
                //deleteMemberStatuses.add(memberStatus);
        //}
    }
}