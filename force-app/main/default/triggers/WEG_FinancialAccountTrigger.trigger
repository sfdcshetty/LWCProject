trigger WEG_FinancialAccountTrigger on FinServ__FinancialAccount__c (before insert, before update, after update) {
    WEG_FinancialAccountTriggerHandler handler = new WEG_FinancialAccountTriggerHandler();
    
    if (Trigger.isInsert)
        handler.beforeInsert(Trigger.new);
    else if (Trigger.isBefore)
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    else
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
}