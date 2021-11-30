public without sharing class CampaignInfluenceTriggerHandler implements TriggerInterface {
    private static CampaignInfluenceTriggerHandler instance;
    public static CampaignInfluenceTriggerHandler getInstance() {
        if (instance == null) {
            instance = new CampaignInfluenceTriggerHandler();
        }
        return instance;
    }

    public void beforeInsert() {
    }

    public void beforeUpdate() {
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
        CreateAdditionalCampaignInfluence((List<CampaignInfluence>) Trigger.new);
    }

    public void afterUpdate() {
    }

    public void afterDelete() {
    }

    public void finish() {
    }

    private static void CreateAdditionalCampaignInfluence(List<CampaignInfluence> newCampaignInfluence) {
        Set<Id> contactSet = new Set<Id>();
        Map<Id, Id> opportunityMap = new Map<Id, Id>();

        Map<String, Id> modelMap = new Map<String, Id>();
        for (CampaignInfluenceModel cim : [SELECT Id, DeveloperName FROM CampaignInfluenceModel WHERE isActive = :true]) {
            modelMap.put(cim.DeveloperName, cim.Id);
        }

        //only do this if inserting into primary model the correct record type
        for (CampaignInfluence ci : newCampaignInfluence) {
            if (ci.ModelId == modelMap.get('primaryModel') && ci.contactId != null) {
                contactSet.add(ci.contactId);
            }

            if (ci.ModelId == modelMap.get('primaryModel') && ci.opportunityId != null) {
                opportunityMap.put(ci.opportunityId, null);
            }
        }

        for (OpportunityContactRole c : [
            SELECT ContactId, OpportunityId
            FROM OpportunityContactRole
            WHERE OpportunityId IN :opportunityMap.keySet() AND IsPrimary = :true
        ]) {
            contactSet.add(c.ContactId);
            opportunityMap.put(c.OpportunityId, c.ContactId);
        }

        if (contactSet.size() > 0) {
            createFirstCampaignInfluence(newCampaignInfluence, contactSet, opportunityMap, modelMap);
            createLastCampaignInfluence(newCampaignInfluence, contactSet, opportunityMap, modelMap);
        }
    }

    private static void createFirstCampaignInfluence(
        List<CampaignInfluence> newCampaignInfluence,
        Set<Id> contactSet,
        Map<Id, Id> opportunityMap,
        Map<String, Id> modelMap
    ) {
        List<CampaignInfluence> newCI = new List<CampaignInfluence>();
        Map<Id, Id> contactToCampaignMap = new Map<Id, Id>();
        for (CampaignMember cm : [
            SELECT Id, CampaignId, ContactId
            FROM CampaignMember
            WHERE ContactId IN :contactSet AND Engagement_Order_First_Touch__c = :true
        ]) {
            contactToCampaignMap.put(cm.ContactId, cm.CampaignId);
        }

        for (CampaignInfluence ci : newCampaignInfluence) {
            if (ci.ModelId == modelMap.get('primaryModel')) {
                Id compaignId = null;
                if (ci.ContactId != null && contactToCampaignMap.containsKey(ci.ContactId)) {
                    compaignId = contactToCampaignMap.get(ci.ContactId);
                } else if (
                    ci.OpportunityId != null &&
                    opportunityMap.containsKey(ci.OpportunityId) &&
                    contactToCampaignMap.containsKey(opportunityMap.get(ci.OpportunityId))
                ) {
                    compaignId = contactToCampaignMap.get(opportunityMap.get(ci.OpportunityId));
                }
                if (compaignId == null) {
                    continue;
                }

                CampaignInfluence i = new CampaignInfluence();
                i.campaignId = compaignId;
                i.modelId = modelMap.get('First_Touch');
                i.Influence = 100;
                if (ci.ContactId != null) {
                    i.ContactId = ci.ContactId;
                }
                if (ci.opportunityId != null) {
                    i.opportunityId = ci.opportunityId;
                }
                newCI.add(i);
            }
        }

        Database.upsert(newCI, false);
    }

    private static void createLastCampaignInfluence(
        List<CampaignInfluence> newCampaignInfluence,
        Set<Id> contactSet,
        Map<Id, Id> opportunityMap,
        Map<String, Id> modelMap
    ) {
        List<CampaignInfluence> newCI = new List<CampaignInfluence>();
        Map<Id, Id> contactToCampaignMap = new Map<Id, Id>();
        for (CampaignMember cm : [
            SELECT Id, CampaignId, ContactId
            FROM CampaignMember
            WHERE ContactId IN :contactSet AND Engagement_Order_Last_Touch__c = :true
        ]) {
            contactToCampaignMap.put(cm.ContactId, cm.CampaignId);
        }

        for (CampaignInfluence ci : newCampaignInfluence) {
            if (ci.ModelId == modelMap.get('primaryModel')) {
                Id compaignId = null;
                if (ci.ContactId != null && contactToCampaignMap.containsKey(ci.ContactId)) {
                    compaignId = contactToCampaignMap.get(ci.ContactId);
                } else if (
                    ci.OpportunityId != null &&
                    opportunityMap.containsKey(ci.OpportunityId) &&
                    contactToCampaignMap.containsKey(opportunityMap.get(ci.OpportunityId))
                ) {
                    compaignId = contactToCampaignMap.get(opportunityMap.get(ci.OpportunityId));
                }
                if (compaignId == null) {
                    continue;
                }

                CampaignInfluence i = new CampaignInfluence();
                i.campaignId = compaignId;
                i.modelId = modelMap.get('Last_Touch');
                i.Influence = 100;
                if (ci.ContactId != null) {
                    i.ContactId = ci.ContactId;
                }
                if (ci.opportunityId != null) {
                    i.opportunityId = ci.opportunityId;
                }
                newCI.add(i);
            }
        }

        Database.upsert(newCI, false);
    }
}
//SELECT Id, opportunityId, contactId, contact.name, modelId, model.developername FROM CampaignInfluence
//SELECT Id, CampaignId, ContactId FROM CampaignMember WHERE Engagement_Order_First_Touch__c = true