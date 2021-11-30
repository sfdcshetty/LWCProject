trigger CampaignInfluenceMasterTrigger on CampaignInfluence(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete
) {
    TriggerFactory.createHandler(CampaignInfluence.sObjectType);
}