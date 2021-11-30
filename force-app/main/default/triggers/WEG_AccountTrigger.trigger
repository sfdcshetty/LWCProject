trigger WEG_AccountTrigger on Account (before insert, after insert, after update) {
    // instantiate the handler
    WEG_AccountTriggerHandler handler = new WEG_AccountTriggerHandler();
    
    if (Trigger.isBefore) {
        handler.beforeInsert();
    } else if (Trigger.isInsert) {
        handler.afterInsert();
    } else {
        handler.afterUpdate();
    }
}