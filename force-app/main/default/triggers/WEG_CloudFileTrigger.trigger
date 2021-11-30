trigger WEG_CloudFileTrigger on TVA_CFB__Cloud_Files__c (before insert, before update, after insert, after update) {
    WEG_CloudFileTriggerHandler handler = new WEG_CloudFileTriggerHandler();
    if (Trigger.isBefore && Trigger.isInsert)
        handler.beforeInsert(Trigger.new);
    else if (Trigger.isBefore)
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    else if (Trigger.isInsert)
        handler.afterInsert(Trigger.new);
    else
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
}