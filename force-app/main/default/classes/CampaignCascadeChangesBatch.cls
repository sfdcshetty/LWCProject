/**
 * This is the CampaignECIDUpdateBatch class. This class is a batch
 * that will go through all the children campaigns to update the ECID
 * if a parent has been updated.  It calls the next layer of children in the finish.
 *
 * @author Matthew Lennington -- (PERFICIENT)
 * @date 09/2020
 *
 */
global class CampaignCascadeChangesBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Set<Id> parentIds = new Set<Id>();
    global Set<Id> campaignIds = new Set<Id>();

    global CampaignCascadeChangesBatch(Set<Id> parentIds) {
        this.parentIds = parentIds;
    }

    global Database.QueryLocator start(Database.BatchableContext info) {
        return DataBase.getQueryLocator(
            [
                SELECT
                    Id,
                    ECID__c,
                    ECID_Fragment__c,
                    ParentId,
                    Parent.ECID__c,
                    Business_Line__c,
                    RecordTypeId,
                    Objective__c,
                    Sub_Channel__c,
                    Tactic__c,
                    Media_Souce__c,
                    Placement__c,
                    Persona__c,
                    Topic__c,
                    Year__c,
                    Initiative__c,
                    Content_Title__c,
                    WEGP1_Region__c,
                    State__c,
                    Program__c,
                    Regional_Vice_President__c,
                    Name
                FROM Campaign
                WHERE ParentId = :parentIds AND ECID_Fragment__c != NULL AND Parent.ECID__c != NULL
            ]
        );
    }

    public void execute(Database.BatchableContext info, List<Campaign> campaigns) {
        TriggerFactory.RUN_TRIGGER_LOGIC = false;
        List<Campaign> updateList = new List<Campaign>();

        for (Campaign c : campaigns) {
            c.ECID__c = c.Parent.ECID__c + c.ECID_Fragment__c;
            campaignIds.add(c.Id);
            updateList.add(c);
        }

        //set names
        CampaignTriggerHandler.setCampaignName(updateList);
        CampaignTriggerHandler.updateChildrenFields(updateList);

        if (updateList.size() > 0) {
            Database.update(updateList);
        }
        TriggerFactory.RUN_TRIGGER_LOGIC = true;
    }

    public void finish(Database.BatchableContext BC) {
        if (campaignIds.size() > 0) {
            Database.executeBatch(new CampaignCascadeChangesBatch(campaignIds));
        }
    }
}