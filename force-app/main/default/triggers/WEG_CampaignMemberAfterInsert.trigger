trigger WEG_CampaignMemberAfterInsert on CampaignMember (after insert) {
    WEG_CampaignMemberTriggerHandler handler = new WEG_CampaignMemberTriggerHandler();
    handler.afterInsert();
}