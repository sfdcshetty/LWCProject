trigger WEG_AccountAfterUpdate on Account (after update) {
    WEG_AccountTriggerHandler handler = new WEG_AccountTriggerHandler();
    handler.afterUpdate();
}