trigger WEG_CampaignAfterInsert on Campaign (after insert) {
    WEG_CampaignTriggerHandler handler = new WEG_CampaignTriggerHandler();
    handler.afterInsert();
}