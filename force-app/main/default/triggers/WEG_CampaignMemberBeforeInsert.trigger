trigger WEG_CampaignMemberBeforeInsert on CampaignMember (before insert) {
    WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
    handler.beforeInsert();
}