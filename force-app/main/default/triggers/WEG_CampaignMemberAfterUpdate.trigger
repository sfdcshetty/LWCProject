trigger WEG_CampaignMemberAfterUpdate on CampaignMember (after update) {
    WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
    handler.afterUpdate();
}