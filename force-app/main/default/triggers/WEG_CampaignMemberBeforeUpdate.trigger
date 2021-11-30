trigger WEG_CampaignMemberBeforeUpdate on CampaignMember (before update) {
    WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
    handler.beforeUpdate();
}