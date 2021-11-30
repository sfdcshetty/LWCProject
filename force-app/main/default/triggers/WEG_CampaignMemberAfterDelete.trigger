trigger WEG_CampaignMemberAfterDelete on CampaignMember (after delete) {
    WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
    handler.afterDelete();
}