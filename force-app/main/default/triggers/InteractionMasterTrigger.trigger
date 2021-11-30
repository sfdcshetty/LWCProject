trigger InteractionMasterTrigger on Interaction__c  (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerFactory.createHandler(Interaction__c.sObjectType);
}