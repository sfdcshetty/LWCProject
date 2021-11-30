trigger CampaignMasterTrigger on Campaign (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerFactory.createHandler(Campaign.sObjectType);
}