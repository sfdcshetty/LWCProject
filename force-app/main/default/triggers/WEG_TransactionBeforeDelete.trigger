trigger WEG_TransactionBeforeDelete on WEG_Transaction__c (before delete) {
    WEG_TransactionTriggerHandler handler = new WEG_TransactionTriggerHandler();
    handler.beforeDelete();
}