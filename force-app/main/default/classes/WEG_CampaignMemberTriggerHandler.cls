public class WEG_CampaignMemberTriggerHandler
{    
    public void beforeInsert() {
        // iterate the inserted campaign members
        for (CampaignMember cMember : (List<CampaignMember>)Trigger.new) {
            // initially populate the status date
            //cMember.WEGP1_DateCurrentStatus__c = Date.today();
            cMember.WEGP1_DateCurrentStatus__c = DateTime.now();
        }
    }
    
    public void beforeUpdate() {
        // iterate the updated campaign members
        for (CampaignMember cMember : (List<CampaignMember>)Trigger.new) {
            // only update the status date when the status has changed
            if (cMember.Status != ((CampaignMember)Trigger.oldMap.get(cMember.Id)).Status) {
                cMember.WEGP1_DateCurrentStatus__c = DateTime.now();
            }
        }
    }
    
    Set<Id> leadIdsToUpdate = new Set<Id>();
    
    public void afterInsert() {
        // iterate the inserted campaign members
        for (CampaignMember cm : (List<CampaignMember>)Trigger.new) {
			// grab the lead id for 'Lead' campaign members
			// only for leads
			// only for responded campaign members
            if (cm.ContactId == null && cm.LeadId != null && cm.HasResponded)
                leadIdsToUpdate.add(cm.LeadId);
        }
        
        // process the leads if applicable
        if (!leadIdsToUpdate.isEmpty())
            updateLeadMemberData();
    }
    
    public void afterUpdate() {
        // iterate the updated campaign members
        System.debug('>>>>>>>> In CampaignMember AfterUpdate');
        for (CampaignMember cm : (List<CampaignMember>)Trigger.new) {
            System.debug('>>>>>>>> CampaignMember ' + cm.Id + '. ContactId ' + cm.ContactId + '. LeadId ' + cm.LeadId + '. HasResponded ' + cm.HasResponded);
            // grab the lead id for 'Lead' campaign members
			// only for leads
			// only for responded campaign members
            if (cm.ContactId == null && cm.LeadId != null && cm.HasResponded) {
                System.debug('>>>>>>>> CampaignMember added');
                leadIdsToUpdate.add(cm.LeadId);
            }
        }
        
        // process the leads if applicable
        if (!leadIdsToUpdate.isEmpty())
            updateLeadMemberData();
    }
    
    public void afterDelete() {
        // iterate the updated campaign members
        for (CampaignMember cm : (List<CampaignMember>)Trigger.old) {
			// grab the lead id for 'Lead' campaign members
			// only for leads
			// only for responded campaign members
            if (cm.ContactId == null && cm.LeadId != null && cm.HasResponded)
                leadIdsToUpdate.add(cm.LeadId);
        }
        
        // process the leads if applicable
        if (!leadIdsToUpdate.isEmpty())
            updateLeadMemberData();
    }
    
    private void updateLeadMemberData() {
        System.debug('>>>>>>>> Processing leads');
        // get the leads using the id's
        List<Lead> leads = [SELECT Id, WEG_FirstRespondedCampaign__c, WEG_FirstRespondedDate__c
                            , WEG_LastRespondedCampaign__c, WEG_LastRespondedDate__c, WEG_TotalCampaignResponses__c
                            , (SELECT Id, CampaignId, HasResponded, WEGP1_ResponseDate__c FROM CampaignMembers)
                            FROM Lead
                            WHERE Id IN :leadIdsToUpdate];
        
        // iterate the leads, making changes
        for (Lead lead : leads) {
            System.debug('>>>>>>>> Processing Lead ' + lead.Id);
            // working variables
            integer totalResponses = 0;
            CampaignMember firstMember = null;
            CampaignMember lastMember = null;
            
            // iterate the leads campaign members
            for (CampaignMember member : lead.CampaignMembers) {
                System.debug('>>>>>>>> Campaign Member ' + member.Id + ' with HasResponded ' + member.HasResponded);
                // check for response -- only responses affect lead data
                if (member.HasResponded) {
                    System.debug('>>>>>>>> Campaign Member has responded');
                    // increase the total
                    totalResponses++;
                    System.debug('>>>>>>>> Responses: ' + totalResponses);
                    
                    // set first and last member if criteria is met
                    if (firstMember == null || member.WEGP1_ResponseDate__c < firstMember.WEGP1_ResponseDate__c)
                        firstMember = member;
                    if (lastMember == null || member.WEGP1_ResponseDate__c > lastMember.WEGP1_ResponseDate__c)
                        lastMember = member;
                }
            }
            
            // at this time, the working variables are populated -- update lead
            lead.WEG_FirstRespondedCampaign__c = firstMember.CampaignId;
            lead.WEG_FirstRespondedDate__c = firstMember.WEGP1_ResponseDate__c;
            lead.WEG_LastRespondedCampaign__c = lastMember.CampaignId;
            lead.WEG_LastRespondedDate__c = lastMember.WEGP1_ResponseDate__c;
            lead.WEG_TotalCampaignResponses__c = totalResponses;
        }
        
        // update the leads
        try { update leads; } catch(Exception ex) { System.debug('>>>>>>>> Error updating leads :: ' + ex.getMessage()); }
    }
}