trigger WEG_UserAfterInsertOrUpdate on User (after insert, after update) {
    WEG_UserTriggerHandler handler = new WEG_UserTriggerHandler();
    handler.afterInsertOrUpdate();
}