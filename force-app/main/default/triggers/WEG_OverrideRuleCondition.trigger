trigger WEG_OverrideRuleCondition on WEG_Comp_OverrideRuleCondition__c (before insert, before update, after insert, after update, after delete) {
    WEG_OverrideRuleTriggerHandler handler = new WEG_OverrideRuleTriggerHandler();
    
    if (Trigger.isBefore)
        handler.beforeConditionInsertUpdate();
    else if (Trigger.isDelete)
        handler.afterConditionDelete();
    else
        handler.afterConditionInsertUpdate();
}