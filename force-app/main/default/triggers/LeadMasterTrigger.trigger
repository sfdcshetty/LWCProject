trigger LeadMasterTrigger on Lead(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete
) {
    TriggerFactory.createHandler(Lead.sObjectType);
}