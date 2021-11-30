trigger InteractionChangeEventTrigger on Interaction__ChangeEvent(after insert) {
    TriggerFactory.createHandler(Interaction__ChangeEvent.SObjectType);
    // List<Interaction__c> newInteractions = new List<Interaction__c>();
    // Id inboundRecordTypeId = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
    // Id milestoneRecordTypeId = Schema.SObjectType.Interaction__c.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
    // Set<Id> leadIds = new Set<Id>();
    // for (Interaction__ChangeEvent event : Trigger.new) {
    //     EventBus.ChangeEventHeader header = event.ChangeEventHeader;
    //     if (header.changetype == 'CREATE' && event.recordtypeId == inboundRecordTypeId && event.Lead__c != null) {
    //         leadIds.add(event.lead__c);
    //     }
    // }

    // //find all leads where there is already a leadCreatedMilestone
    // if (leadIds.size() > 0) {
    //     for (Interaction__c interaction : [
    //         SELECT Lead__c
    //         FROM Interaction__c
    //         WHERE Lead__c IN :leadIds AND RecordType.Name = 'Milestone' AND Name = 'Lead Created'
    //     ]) {
    //         leadIds.remove(interaction.Lead__c);
    //     }
    // }

    // //create Milestones
    // for (Id leadId : leadIds) {
    //     Interaction__c interaction = new Interaction__c();
    //     interaction.RecordTypeId = milestoneRecordTypeId;
    //     interaction.Name = 'Lead Created';
    //     interaction.Lead__c = leadId;
    //     newInteractions.add(interaction);
    // }

    // if (newInteractions.size() > 0) {
    //     Database.insert(newInteractions);
    // }
}