trigger WEG_FinAccountServicingTrigger on Financial_Account_Servicing__c (after insert, after update) {
    WEG_FinAccountServicingTriggerHandler handler = new WEG_FinAccountServicingTriggerHandler();
    
    if (Trigger.isInsert)
        handler.afterInsert(Trigger.new);
    else
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
}