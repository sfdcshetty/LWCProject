trigger WEG_TransactionTrigger on WEG_Transaction__c (before insert, before delete, after insert, after update) {
    WEG_TransactionTriggerHandler handler = new WEG_TransactionTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isInsert)
            handler.beforeInsert();
        else
            handler.beforeDelete();
    }
    else {
        if (Trigger.isInsert)
            handler.afterInsert();
        else
            handler.afterUpdate();
    }
}