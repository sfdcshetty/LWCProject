trigger CampaignMemberMasterTrigger on CampaignMember (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerFactory.createHandler(CampaignMember.sObjectType);
}