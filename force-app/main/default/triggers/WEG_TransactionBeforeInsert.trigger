trigger WEG_TransactionBeforeInsert on WEG_Transaction__c (before insert) {
    WEG_TransactionTriggerHandler handler = new WEG_TransactionTriggerHandler();
    handler.beforeInsert();
}