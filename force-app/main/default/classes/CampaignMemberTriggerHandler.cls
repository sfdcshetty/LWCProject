public with sharing class CampaignMemberTriggerHandler implements TriggerInterface {
    private static CampaignMemberTriggerHandler instance;
    public static CampaignMemberTriggerHandler getInstance() {
        if (instance == null) {
            instance = new CampaignMemberTriggerHandler();
        }
        return instance;
    }

    public void beforeInsert() {
        //moved from inside a deleted trigger
        // WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
        // handler.beforeInsert();
        //END MOVED
        findFirstTouch((List<CampaignMember>) Trigger.new);
    }

    public void beforeUpdate() {
        //moved from inside a deleted trigger
        // WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
        // handler.beforeUpdate();
        //END MOVED
        findFirstTouch((List<CampaignMember>) Trigger.new);
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
        //MOVED from inside a deleted trigger
        // WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
        // handler.afterInsert();
        //END MOVED
        findPreviousLastTouch((Map<Id, CampaignMember>) Trigger.newMap);
    }

    public void afterUpdate() {
        //moved from inside a deleted trigger
        // WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
        // handler.afterUpdate();
        //END MOVED
        findPreviousLastTouch((Map<Id, CampaignMember>) Trigger.newMap);
    }

    public void afterDelete() {
        //moved from inside a deleted trigger
        // WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
        // handler.afterDelete();
        //END MOVED
    }

    public void finish() {
    }

    private static void findFirstTouch(List<CampaignMember> newCampaignMembers) {
        Set<Id> alreadyHasFirstTouch = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        for (CampaignMember cm : newCampaignMembers) {
            if (cm.ContactId != null && cm.Engagement_Order_First_Touch__c) {
                contactIds.add(cm.ContactId);
            }
            if (cm.LeadId != null && cm.Engagement_Order_First_Touch__c) {
                leadIds.add(cm.LeadId);
            }
        }

        for (CampaignMember cm : [
            SELECT Id, LeadId, ContactId
            FROM CampaignMember
            WHERE (ContactId IN :contactIds OR LeadId IN :leadIds) AND Engagement_Order_First_Touch__c = TRUE
        ]) {
            if (cm.ContactId != null) {
                alreadyHasFirstTouch.add(cm.ContactId);
            }
            if (cm.LeadId != null) {
                alreadyHasFirstTouch.add(cm.LeadId);
            }
        }

        for (CampaignMember cm : newCampaignMembers) {
            if (cm.ContactId != null && cm.Engagement_Order_First_Touch__c && alreadyHasFirstTouch.contains(cm.ContactId)) {
                cm.Engagement_Order_First_Touch__c = false;
            }
            if (cm.LeadId != null && cm.Engagement_Order_First_Touch__c && alreadyHasFirstTouch.contains(cm.LeadId)) {
                cm.Engagement_Order_First_Touch__c = false;
            }
        }
    }

    private static void findPreviousLastTouch(Map<Id, CampaignMember> newCampaignMembersMap) {
        List<CampaignMember> updateOtherCompaigns = new List<CampaignMember>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        for (CampaignMember cm : newCampaignMembersMap.values()) {
            if (cm.ContactId != null && cm.Engagement_Order_Last_Touch__c) {
                contactIds.add(cm.ContactId);
            }
            if (cm.LeadId != null && cm.Engagement_Order_Last_Touch__c) {
                leadIds.add(cm.LeadId);
            }
        }
        for (CampaignMember cm : [
            SELECT Id
            FROM CampaignMember
            WHERE (ContactId IN :contactIds OR LeadId IN :leadIds) AND Engagement_Order_Last_Touch__c = TRUE AND Id NOT IN :newCampaignMembersMap.keySet()
        ]) {
            cm.Engagement_Order_Last_Touch__c = false;
            updateOtherCompaigns.add(cm);
        }

        Database.update(updateOtherCompaigns);
    }
}