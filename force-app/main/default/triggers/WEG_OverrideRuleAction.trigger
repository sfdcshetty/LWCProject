trigger WEG_OverrideRuleAction on WEG_Comp_OverrideRuleAction__c (before insert, before update, after insert, after update, after delete) {
    WEG_OverrideRuleTriggerHandler handler = new WEG_OverrideRuleTriggerHandler();
    
    if (Trigger.isBefore)
        handler.beforeActionInsertUpdate();
    else if (Trigger.isDelete)
        handler.afterActionDelete();
    else
        handler.afterActionInsertUpdate();
}