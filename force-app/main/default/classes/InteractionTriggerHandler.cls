public with sharing class InteractionTriggerHandler implements TriggerInterface {
    private static Map<Id, String> recordtypeMap;
    private static InteractionTriggerHandler instance;
    public static InteractionTriggerHandler getInstance() {
        if (instance == null) {
            instance = new InteractionTriggerHandler();
            recordtypeMap = new Map<Id, String>();
            for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :'Interaction__c']) {
                recordtypeMap.put(rt.Id, rt.DeveloperName);
            }
        }
        return instance;
    }
    public void beforeInsert() {
        setFirstLastCampaign((List<Interaction__c>) Trigger.new);
        flow_touchpoint((List<Interaction__c>) Trigger.new);
        flow_scoring((List<Interaction__c>) Trigger.new);
        flow_interaction_field_mapping((List<Interaction__c>) Trigger.new);
        setAccountFromContact((List<Interaction__c>) Trigger.new);
        setRelatedInteractions((List<Interaction__c>) Trigger.new);
        setType((List<Interaction__c>) Trigger.new);
    }
    public void beforeUpdate() {
        rescore((List<Interaction__c>) Trigger.new);
        flow_import((Map<Id, Interaction__c>) Trigger.newMap, (Map<Id, Interaction__c>) Trigger.oldMap);
        setRelatedInteractions((List<Interaction__c>) Trigger.new);
        setAccountFromContact((Map<Id, Interaction__c>) Trigger.newMap, (Map<Id, Interaction__c>) Trigger.oldMap);
        taskComplete((Map<Id, Interaction__c>) Trigger.newMap, (Map<Id, Interaction__c>) Trigger.oldMap);
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        if (!skip((List<Interaction__c>) Trigger.new)) {
            createCampaignMembers((Map<Id, Interaction__c>) Trigger.newMap);
            calculateScores((List<Interaction__c>) Trigger.new);
            setInactiveOnReset((List<Interaction__c>) Trigger.new);
        } else {
            import((List<Interaction__c>) Trigger.new);
        }
    }
    public void afterUpdate() {
        if (!skip((List<Interaction__c>) Trigger.new)) {
            createCampaignMembers((Map<Id, Interaction__c>) Trigger.newMap, (Map<Id, Interaction__c>) Trigger.oldMap);
            updateScores((Map<Id, Interaction__c>) Trigger.newMap, (Map<Id, Interaction__c>) Trigger.oldMap);
            setInactiveOnReset((List<Interaction__c>) Trigger.new);
        }
    }
    public void afterDelete() {
        if (!skip((List<Interaction__c>) Trigger.old)) {
            calculateScores((List<Interaction__c>) Trigger.old);
        }
    }
    public void finish() {
    }
    private static void setFirstLastCampaign(List<Interaction__c> newInteractions) {
        Map<string, Campaign> campaignMap = new Map<string, Campaign>();
        Set<String> campaignECIDSet = new Set<String>();
        Set<Id> campaignIdSet = new Set<Id>();

        for (Interaction__c newInteraction : newInteractions) {
            if (newInteraction.ECID_String__c != null) {
                for (String cs : newInteraction.ECID_String__c.split('_')) {
                    campaignECIDSet.add(cs.split('\\.')[0]);
                }
            }
            if (newInteraction.First_Responded_Campaign__c != null) {
                campaignIdSet.add(newInteraction.First_Responded_Campaign__c);
            }
        }

        for (Campaign c : [
            SELECT Id, ECID__c, Tactic__c, WEGP1_Type__c, WEGP1_SubType__c, Channel_2__c, Sub_Channel__c, Type__c, Type
            FROM Campaign
            WHERE ECID__c IN :campaignECIDSet OR ID IN :campaignIdSet
        ]) {
            campaignMap.put(c.ECID__c, c);
            campaignMap.put(c.Id, c);
        }

        for (Interaction__c newInteraction : newInteractions) {
            if (newInteraction.ECID_String__c != null) {
                String firstERCID = null;
                String lastERCID = null;
                if (newInteraction.ECID_String__c.IndexOf('_') != -1) {
                    firstERCID = newInteraction.ECID_String__c.subString(0, newInteraction.ECID_String__c.IndexOf('_')).split('\\.')[0];
                    lastERCID = newInteraction.ECID_String__c.subString(newInteraction.ECID_String__c.lastIndexOf('_') + 1).split('\\.')[0];
                } else if (campaignMap.containsKey(newInteraction.ECID_String__c.split('\\.')[0])) {
                    firstERCID = newInteraction.ECID_String__c.split('\\.')[0];
                    lastERCID = newInteraction.ECID_String__c.split('\\.')[0];
                }
                if (firstERCID != null && campaignMap.containsKey(firstERCID)) {
                    newInteraction.First_Responded_Campaign__c = campaignMap.get(firstERCID).Id;
                    newInteraction.WEGP1_Type__c = campaignMap.get(firstERCID).Channel_2__c;
                    newInteraction.WEGP1_SubType__c = campaignMap.get(firstERCID).Sub_Channel__c;
                    newInteraction.WEGP1_TypeDetail__c = campaignMap.get(firstERCID).Type__c;
                }
                if (lastERCID != null && campaignMap.containsKey(lastERCID)) {
                    newInteraction.Last_Responded_Campaign__c = campaignMap.get(lastERCID).Id;
                    newInteraction.Last_Response_Campaign_Tactic__c = campaignMap.get(lastERCID).Tactic__c;
                } else if (firstERCID != null && campaignMap.containsKey(firstERCID)) {
                    newInteraction.Last_Responded_Campaign__c = campaignMap.get(firstERCID).Id;
                    newInteraction.Last_Response_Campaign_Tactic__c = campaignMap.get(firstERCID).Tactic__c;
                }
            } else if (newInteraction.First_Responded_Campaign__c != null && campaignMap.containsKey(newInteraction.First_Responded_Campaign__c)) {
                newInteraction.WEGP1_Type__c = campaignMap.get(newInteraction.First_Responded_Campaign__c).Channel_2__c;
                newInteraction.WEGP1_SubType__c = campaignMap.get(newInteraction.First_Responded_Campaign__c).Sub_Channel__c;
                newInteraction.WEGP1_TypeDetail__c = campaignMap.get(newInteraction.First_Responded_Campaign__c).Type__c;
            }
        }
    }
    private static void createCampaignMembers(Map<Id, Interaction__c> newInteractionMap) {
        List<CampaignMember> newCampaignMembers = new List<CampaignMember>();
        Map<string, Id> campaignMap = new Map<string, Id>();
        Set<String> campaignECIDSet = new Set<String>();
        for (Id key : newInteractionMap.keySet()) {
            //example n20abc123abc123.2020-8-21_abc.2020-8-21_n20orgdrcdrcdrc.2020-9-2_n20abc123abc123.2020-8-21_abc.2020-8-21_n20orgdrcdrcdrc.2020-9-2
            if (
                newInteractionMap.get(key).ECID_String__c != null &&
                (newInteractionMap.get(key).Contact__c != null ||
                newInteractionMap.get(key).Lead__c != null)
            ) {
                //split it on _
                for (String cs : newInteractionMap.get(key).ECID_String__c.split('_')) {
                    //example n20abc123abc123.2020-8-21
                    campaignECIDSet.add(cs.split('\\.')[0]);
                }
            }
        }

        for (Campaign c : [SELECT Id, ECID__c FROM Campaign WHERE ECID__c IN :campaignECIDSet AND IsActive = :true]) {
            campaignMap.put(c.ECID__c, c.Id);
        }

        //create campaign members
        for (Id key : newInteractionMap.keySet()) {
            if (
                newInteractionMap.get(key).ECID_String__c != null &&
                (newInteractionMap.get(key).Contact__c != null ||
                newInteractionMap.get(key).Lead__c != null)
            ) {
                List<String> ecids = newInteractionMap.get(key).ECID_String__c.split('_');
                for (Integer index = 0; index < ecids.size(); index++) {
                    Date dt = Date.today();
                    if (ecids[index].split('\\.').size() == 2) {
                        String dtstring = ecids[index].split('\\.')[1];
                        dt = date.newInstance(
                            integer.valueOf(dtstring.split('-')[0]),
                            integer.valueOf(dtstring.split('-')[1]),
                            integer.valueOf(dtstring.split('-')[2])
                        );
                    }
                    newCampaignMembers.add(
                        createCampaignMember(campaignMap.get(ecids[index].split('\\.')[0]), dt, index, (ecids.size() - 1), newInteractionMap.get(key))
                    );
                }
            }
        }
        Database.insert(newCampaignMembers, false);
    }
    private static void createCampaignMembers(Map<Id, Interaction__c> newInteractionMap, Map<Id, Interaction__c> oldInteractionMap) {
        Map<Id, Interaction__c> updateInteractionMap = new Map<Id, Interaction__c>();
        for (Id key : newInteractionMap.keySet()) {
            if (newInteractionMap.get(key).Contact__c != oldInteractionMap.get(key).Contact__c) {
                updateInteractionMap.put(key, newInteractionMap.get(key));
            }

            if (newInteractionMap.get(key).Lead__c != oldInteractionMap.get(key).Lead__c) {
                updateInteractionMap.put(key, newInteractionMap.get(key));
            }
        }
        createCampaignMembers(updateInteractionMap);
    }
    private static CampaignMember createCampaignMember(Id campaignId, Date dt, Integer index, Integer leng, Interaction__c interaction) {
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        if (interaction.Contact__c != null) {
            cm.ContactId = interaction.Contact__c;
        }
        if (interaction.Lead__c != null) {
            cm.LeadId = interaction.Lead__c;
        }
        cm.Engagement_Date__c = dt;
        cm.Engagement_Order__c = index + 1;
        if (index == leng) {
            cm.Engagement_Order_Last_Touch__c = true;
        }

        if (index == 0) {
            cm.Engagement_Order_First_Touch__c = true;
        }
        if (interaction.Lead_Source__c == 'Web Form') {
            cm.Status = 'Responded';
        }

        return cm;
    }
    private static void setAccountFromContact(List<Interaction__c> newInteractions) {
        Set<Id> contactSet = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Interaction__c interaction : newInteractions) {
            if (interaction.Contact__c != null) {
                contactSet.add(interaction.Contact__c);
            }
        }

        for (Contact c : [SELECT Id, AccountId, Account.WEGP1_Primary_Household__c FROM Contact WHERE Id IN :contactSet]) {
            contactMap.put(c.Id, c);
        }

        for (Interaction__c interaction : newInteractions) {
            if (interaction.Contact__c != null && contactMap.containsKey(interaction.Contact__c)) {
                interaction.Account__c = contactMap.get(interaction.Contact__c).AccountId;
                interaction.WEGP1_Primary_Household__c = contactMap.get(interaction.Contact__c).Account.WEGP1_Primary_Household__c;
            }
        }
    }
    private static void setAccountFromContact(Map<Id, Interaction__c> newInteractions, Map<Id, Interaction__c> oldInteractions) {
        List<Interaction__c> updateInteractions = new List<Interaction__c>();
        for (Id key : newInteractions.keySet()) {
            if (
                newInteractions.get(key).Contact__c != oldInteractions.get(key).Contact__c ||
                (newInteractions.get(key).Contact__c != null &&
                newInteractions.get(key).Account__c == null)
            ) {
                updateInteractions.add(newInteractions.get(key));
            }
        }
        setAccountFromContact(updateInteractions);
    }
    private static void calculateScores(List<Interaction__c> newInteractions) {
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();

        List<Contact> updateContacts = new List<Contact>();
        List<Lead> updateLeads = new List<Lead>();

        for (Interaction__c i : newInteractions) {
            if (i.contact__c != null && (i.Behavior_Score__c != 0 || i.Demographic_Score__c != 0)) {
                contactIdSet.add(i.contact__c);
            }
            if (i.Lead__c != null && (i.Behavior_Score__c != 0 || i.Demographic_Score__c != 0)) {
                leadIdSet.add(i.Lead__c);
            }
        }

        for (AggregateResult res : [
            SELECT SUM(Behavior_Score__c), SUM(Demographic_Score__c), contact__c
            FROM Interaction__c
            WHERE contact__c IN :contactIdSet AND Inactive__c = :false
            GROUP BY Contact__c
        ]) {
            Contact c = new Contact();
            c.Id = (Id) res.get('Contact__c');
            c.Behavior_Score__c = (decimal) res.get('expr0');
            c.Demographic_Score__c = (decimal) res.get('expr1');
            updateContacts.add(c);
        }

        for (AggregateResult res : [
            SELECT SUM(Behavior_Score__c), SUM(Demographic_Score__c), Lead__c
            FROM Interaction__c
            WHERE Lead__c IN :leadIdSet AND Inactive__c = :false
            GROUP BY Lead__c
        ]) {
            Lead c = new Lead();
            c.Id = (Id) res.get('Lead__c');
            c.Behavior_Score__c = (decimal) res.get('expr0');
            c.Demographic_Score__c = (decimal) res.get('expr1');
            updateLeads.add(c);
        }

        WithoutSharingHelper.updateRecords(updateContacts);
        WithoutSharingHelper.updateRecords(updateLeads);
    }
    private static void updateScores(Map<Id, Interaction__c> newMap, Map<Id, Interaction__c> oldMap) {
        List<Interaction__c> cs = new List<Interaction__c>();

        for (Id key : newMap.keySet()) {
            if (
                newMap.get(key).Behavior_Score__c != oldMap.get(key).Behavior_Score__c ||
                newMap.get(key).Demographic_Score__c != oldMap.get(key).Demographic_Score__c ||
                newMap.get(key).Lead__c != oldMap.get(key).Lead__c ||
                newMap.get(key).Contact__c != oldMap.get(key).Contact__c ||
                newMap.get(key).Inactive__c != oldMap.get(key).Inactive__c
            ) {
                cs.add(newMap.get(key));
            }
        }
        if (cs.size() > 0) {
            calculateScores(cs);
        }
    }
    private static void rescore(List<Interaction__c> newList) {
        List<Interaction__c> scoreInteractions = new List<Interaction__c>();
        for (Interaction__c i : newList) {
            if (i.rescore__c == true) {
                scoreInteractions.add(i);
                i.rescore__c = false;
            }
        }
        if (scoreInteractions.size() > 0) {
            flow_scoring(scoreInteractions);
        }
    }

    private static void setInactiveOnReset(List<Interaction__c> newInteractions) {
        Set<Id> contactSet = new Set<Id>();
        Set<Id> leadSet = new Set<Id>();
        Set<Id> excludedSet = new Set<Id>();
        for (Interaction__c interaction : newInteractions) {
            excludedSet.add(interaction.Id);
            if (interaction.reset__c && !interaction.inactive__c) {
                if (interaction.contact__c != null) {
                    contactSet.add(interaction.contact__c);
                } else if (interaction.Lead__c != null) {
                    leadSet.add(interaction.lead__c);
                }
            }
        }

        if (contactSet.size() > 0 && !System.isBatch()) {
            Database.executeBatch(new InteractionInactivationBatch(contactSet, Contact.sObjectType, excludedSet));
        }
        if (leadSet.size() > 0 && !System.isBatch()) {
            Database.executeBatch(new InteractionInactivationBatch(leadSet, Lead.sObjectType, excludedSet));
        }
    }
    private static void setRelatedInteractions(List<Interaction__c> newInteractions) {
        for (Interaction__c interaction : newInteractions) {
            if (interaction.Contact__c != null) {
                if (recordtypeMap.get(interaction.recordtypeId) == 'Inbound') {
                    interaction.Touchpoint_Contact__c = interaction.Contact__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Outbound') {
                    interaction.Touchpoint_Contact__c = interaction.Contact__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Event') {
                    interaction.TaskContact__c = interaction.Contact__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Milestone') {
                    interaction.Milestone_Contact__c = interaction.Contact__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Task') {
                    interaction.TaskContact__c = interaction.Contact__c;
                }
            }

            if (interaction.Lead__c != null) {
                if (recordtypeMap.get(interaction.recordtypeId) == 'Inbound') {
                    interaction.Touchpoint_Lead__c = interaction.Lead__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Outbound') {
                    interaction.Touchpoint_Lead__c = interaction.Lead__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Event') {
                    interaction.Task_Lead__c = interaction.Lead__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Milestone') {
                    interaction.Milestone_Lead__c = interaction.Lead__c;
                }
                if (recordtypeMap.get(interaction.recordtypeId) == 'Task') {
                    interaction.Task_Lead__c = interaction.Lead__c;
                }
            }
        }
    }
    private static void taskComplete(Map<Id, Interaction__c> newMap, Map<Id, Interaction__c> oldMap) {
        for (Id key : newMap.keySet()) {
            if (newMap.get(key).Status__c != oldMap.get(key).Status__c && newMap.get(key).Status__c == 'Complete') {
                newMap.get(key).Completed_By__c = UserInfo.getUserId();
                newMap.get(key).Completed_Date__c = Date.today();
            }
        }
    }
    private static void flow_touchpoint(List<Interaction__c> newInteractions) {
        List<Interaction__c> flowInteractions = new List<Interaction__c>();
        for (Interaction__c interaction : newInteractions) {
            if (
                recordtypeMap.get(interaction.recordtypeId) == 'Inbound' ||
                recordtypeMap.get(interaction.recordtypeId) == 'Outbound' ||
                recordtypeMap.get(interaction.recordtypeId) == 'Event' ||
                recordtypeMap.get(interaction.recordtypeId) == 'Task'
            ) {
                flowInteractions.add(interaction);
            }
        }

        for (Interaction__c interaction : flowInteractions) {
            try {
                Flow.Interview flow = new Flow.Interview.Interaction_Inbound_Touchpoint(new Map<String, Object>{ 'Interaction' => interaction });
                flow.start();
                //interaction = (Interaction__c) flow.getVariableValue('Interaction');
                interaction = interactionCompare((Interaction__c) flow.getVariableValue('Interaction'), interaction);
            } catch (Exception ex) {
                throw new applicationException('Unable to create leads with dml options');
            }
        }
    }
    private static void flow_scoring(List<Interaction__c> newInteractions) {
        List<Interaction__c> flowInteractions = new List<Interaction__c>();
        for (Interaction__c interaction : newInteractions) {
            if (
                recordtypeMap.get(interaction.recordtypeId) == 'Inbound' ||
                recordtypeMap.get(interaction.recordtypeId) == 'Outbound' ||
                recordtypeMap.get(interaction.recordtypeId) == 'Task' ||
                recordtypeMap.get(interaction.recordtypeId) == 'Event'
            ) {
                flowInteractions.add(interaction);
            }
        }

        Flow.Interview flow = new Flow.Interview.Interaction_Scoring(new Map<String, Object>{ 'Interactions' => flowInteractions });
        flow.start();

        List<Interaction__c> updatedInteraction = (List<Interaction__c>) flow.getVariableValue('Output');

        for (Integer i = 0; i < flowInteractions.size(); i++) {
            flowInteractions.get(i).Behavior_Score__c = updatedInteraction.get(i).Behavior_Score__c;
            flowInteractions.get(i).Demographic_Score__c = updatedInteraction.get(i).Demographic_Score__c;
        }
    }
    private static void flow_interaction_field_mapping(List<Interaction__c> newInteractions) {
        for (Interaction__c interaction : newInteractions) {
            Flow.Interview flow = new Flow.Interview.Interaction_Interaction_Mapping(new Map<String, Object>{ 'Interaction' => interaction });
            flow.start();
            interaction = interactionCompare((Interaction__c) flow.getVariableValue('Interaction'), interaction);
        }
    }
    private static void flow_import(Map<Id, Interaction__c> newInteractions, Map<Id, Interaction__c> oldInteractions) {
        List<Interaction__c> flowInteractions = new List<Interaction__c>();
        for (Id key : newInteractions.keySet()) {
            if (
                newInteractions.get(key).recordtypeId != oldInteractions.get(key).recordtypeId &&
                recordtypeMap.get(newInteractions.get(key).recordtypeId) != 'Import' &&
                recordtypeMap.get(newInteractions.get(key).recordtypeId) != 'Milestone'
            ) {
                flowInteractions.add(newInteractions.get(key));
            }
        }

        if (flowInteractions.size() > 0) {
            flow_touchpoint(flowInteractions);
            flow_scoring(flowInteractions);
        }
    }
    private static Interaction__c interactionCompare(Interaction__c newInteraction, Interaction__c oldInteraction) {
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Interaction__c.fields.getMap();
        for (String fieldName : schemaFieldMap.keySet()) {
            if (newInteraction.get(fieldName) != oldInteraction.get(fieldName)) {
                oldInteraction.put(fieldName, newInteraction.get(fieldName));
            }
        }
        return oldInteraction;
    }
    private static void import(List<Interaction__c> interactions) {
        Set<Id> idSet = new Set<Id>();
        try {
            for (Interaction__c i : interactions) {
                idSet.add(i.Id);
            }
            //flows were built in a way that does not appear to support bulkification
            Database.executeBatch(new InteractionImportBatch(idSet), 1);
        } catch (Exception ex) {
            //do nothing
        }
    }
    private static Boolean skip(List<Interaction__c> newInteractions) {
        //if there is any import records we want to skip triggers
        Boolean skip = false;
        for (Interaction__c i : newInteractions) {
            if (recordtypeMap.get(i.RecordTypeId) == 'Import') {
                skip = true;
                break;
            }
        }

        return skip;
    }

    private static void setType(List<Interaction__c> newInteractions) {
        Set<Id> campaignId = new Set<Id>();
        for (Interaction__c interaction : newInteractions) {
            if (
                interaction.First_Responded_Campaign__c != null &&
                (interaction.WEGP1_Type__c == null ||
                interaction.WEGP1_SubType__c == null ||
                interaction.WEGP1_TypeDetail__c == null)
            ) {
                campaignId.add(interaction.First_Responded_Campaign__c);
            }
        }

        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        if (campaignId.size() > 0) {
            for (Campaign c : [SELECT Id, WEGP1_Type__c, Type__c, Sub_Channel__c, Channel_2__c FROM Campaign WHERE Id IN :campaignId]) {
                campaignMap.put(c.Id, c);
            }
        }

        for (Interaction__c interaction : newInteractions) {
            if (
                interaction.First_Responded_Campaign__c != null &&
                (interaction.WEGP1_Type__c == null ||
                interaction.WEGP1_SubType__c == null ||
                interaction.WEGP1_TypeDetail__c == null)
            ) {
                interaction.WEGP1_Type__c = campaignMap.get(interaction.First_Responded_Campaign__c).Channel_2__c;
                interaction.WEGP1_SubType__c = campaignMap.get(interaction.First_Responded_Campaign__c).Sub_Channel__c;
                interaction.WEGP1_TypeDetail__c = campaignMap.get(interaction.First_Responded_Campaign__c).Type__c;
            }
        }
    }

    public class applicationException extends Exception {
    }
}