trigger WEG_AssetsAndLiabilitiesTrigger on FinServ__AssetsAndLiabilities__c (before insert, before update) {
    WEG_AssetsAndLiabilitiesTriggerHandler handler = new WEG_AssetsAndLiabilitiesTriggerHandler();
    
    if (Trigger.isInsert)
        handler.beforeInsert(Trigger.new);
    else
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
}