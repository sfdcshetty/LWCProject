trigger WEG_EventAfterInsert on Event (after insert) {
    WEG_EventTriggerHandler handler = new WEG_EventTriggerHandler();
    handler.afterInsert();
}