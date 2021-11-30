public class WEG_OverrideRuleTriggerHandler {
    // master record Ids
    private Set<Id> overrideRuleIds = new Set<Id>();
    
    public void beforeConditionInsertUpdate() {
        // get the transaction schema
        Map<String, Schema.SObjectField> transSchema = Schema.SObjectType.WEG_Transaction__c.fields.getMap();
        
        for (WEG_Comp_OverrideRuleCondition__c ruleCondition : (List<WEG_Comp_OverrideRuleCondition__c>)Trigger.new) {
            string result = getFieldReferenceId(transSchema, ruleCondition.WEG_Field__c, ruleCondition.WEG_Value__c);
            if (result.startsWith('ERROR'))
                ruleCondition.addError(result);
            else
                ruleCondition.WEG_Reference_ID__c = result;
        }
    }
    
    public void afterConditionInsertUpdate() {
        // iterate the updated conditions
        // gather the master record Ids (Override Rules)
        for (WEG_Comp_OverrideRuleCondition__c ruleCondition : (List<WEG_Comp_OverrideRuleCondition__c>)Trigger.new) {
            overrideRuleIds.add(ruleCondition.WEG_OverrideRule__c);
        }
        
        updateOverrideRules();
    }
    
    public void afterConditionDelete() {
        // iterate the updated conditions
        // gather the master record Ids (Override Rules)
        for (WEG_Comp_OverrideRuleCondition__c ruleCondition : (List<WEG_Comp_OverrideRuleCondition__c>)Trigger.old) {
            overrideRuleIds.add(ruleCondition.WEG_OverrideRule__c);
        }
        
        updateOverrideRules();
    }
    
    public void beforeActionInsertUpdate() {
        // get the transaction schema
        Map<String, Schema.SObjectField> transSchema = Schema.SObjectType.WEG_Transaction__c.fields.getMap();
        
        for (WEG_Comp_OverrideRuleAction__c ruleAction : (List<WEG_Comp_OverrideRuleAction__c>)Trigger.new) {
            string result = getFieldReferenceId(transSchema, ruleAction.WEG_Field__c, ruleAction.WEG_Value__c);
            if (result.startsWith('ERROR'))
                ruleAction.addError(result);
            else
                ruleAction.WEG_Reference_ID__c = result;
        }
    }
    
    public void afterActionInsertUpdate() {
        // iterate the updated actions
        // gather the master record Ids (Override Rules)
        for (WEG_Comp_OverrideRuleAction__c ruleAction : (List<WEG_Comp_OverrideRuleAction__c >)Trigger.new) {
            overrideRuleIds.add(ruleAction.WEG_OverrideRule__c);
        }
        
        updateOverrideRules();
    }
    
    public void afterActionDelete() {
        // iterate the updated actions
        // gather the master record Ids (Override Rules)
        for (WEG_Comp_OverrideRuleAction__c ruleAction : (List<WEG_Comp_OverrideRuleAction__c >)Trigger.old) {
            overrideRuleIds.add(ruleAction.WEG_OverrideRule__c);
        }
        
        updateOverrideRules();
    }
    
    private String generateSql(String field, String operator, String value, Schema.DisplayType fieldType, boolean isAction) {
        string sql = '';
        
        // 
        if (operator == 'Equals') {
            if (fieldType == Schema.DisplayType.BOOLEAN)
                sql = value == 'True' ? '#s# ' + field + ' = 1' : '#s# ' + field + ' = 0';
            else if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE
                     || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.LONG)
                sql = '#s# ' + field + ' = ' + value;
            else
                sql =  '#s# ' + field + ' = \'' + value + '\'';
        }
        else if (operator == 'Does Not Equal') {
            if (fieldType == Schema.DisplayType.BOOLEAN)
                sql = value == 'True' ? '#s# ' + field + ' <> 1' : '#s# ' + field + ' <> 0';
            else if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE
                     || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.LONG)
                sql = '#s# ' + field + ' <> ' + value;
            else
                sql = '#s# ' + field + ' <> \'' + value + '\'';
        }
        else if (operator == 'Contains')
            sql = '#s# ' + field + ' LIKE \'%' + value + '%\'';
        else if (operator == 'Does Not Contain')
            sql = '#s# ' + field + ' NOT LIKE \'%' + value + '%\'';
        else if (operator == 'Starts With')
            sql = '#s# ' + field + ' LIKE \'' + value + '%\'';
        else if (operator == 'Ends With')
            sql = '#s# ' + field + ' NOT LIKE \'%' + value + '\'';
        else if (operator == 'Greater Than') {
            if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE
                     || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.LONG)
                sql = '#s# ' + field + ' > ' + value;
            else
                sql = '#s# ' + field + ' > \'' + value + '\'';
        }
        else if (operator == 'Less Than') {
            if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE
                     || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.LONG)
                sql = '#s# ' + field + ' < ' + value;
            else
                sql = '#s# ' + field + ' < \'' + value + '\'';
        }
        else if (operator == 'Greater Than or Equal To') {
            if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE
                     || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.LONG)
                sql = '#s# ' + field + ' >= ' + value;
            else
                sql = '#s# ' + field + ' >= \'' + value + '\'';
        }
        else if (operator == 'Less Than or Equal To') {
            if (fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE
                     || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.LONG)
                sql = '#s# ' + field + ' <= ' + value;
            else
                sql = '#s# ' + field + ' <= \'' + value + '\'';
        }
        else
            sql = 'ERROR';
        
        if (isAction)
            return sql.replace('#s#', ',');
        else
            return sql.replace('#s#', ' AND');
    }
    
    private void updateOverrideRules() {
        // get the transaction schema
        Map<String, Schema.SObjectField> transSchema = Schema.SObjectType.WEG_Transaction__c.fields.getMap();
        
        // get the override rules to be updated
        List<WEG_Comp_OverrideRule__c> overrideRules = [SELECT Id, Name, WEG_HasCriteriaAndActions__c, WEG_SqlUpdateCommand__c
                                                        , (SELECT Id, WEG_Field__c, WEG_Operator__c, WEG_Value__c, WEG_Reference_ID__c FROM WEG_OverrideRuleConditions__r)
                                                        , (SELECT Id, WEG_Field__c, WEG_Operator__c, WEG_Value__c, WEG_Reference_ID__c FROM WEG_OverrideRuleActions__r)
                                                        FROM WEG_Comp_OverrideRule__c WHERE Id IN :overrideRuleIds];
        
        // iterate each of the rules
        for (WEG_Comp_OverrideRule__c overrideRule : overrideRules) {
            System.debug('>>>>>>>> Iterating Override >> Name: ' + overrideRule.Name);
            System.debug('>>>>>>>> Iterating Override >> Conditions: ' + overrideRule.WEG_OverrideRuleConditions__r);
            
            // check that both criteria and actions exist
            if (overrideRule.WEG_OverrideRuleConditions__r.size() > 0 && overrideRule.WEG_OverrideRuleActions__r.size() > 0) {                
                // initially populate the command field
                overrideRule.WEG_SqlUpdateCommand__c = 'UPDATE WEG_Transaction__c SET WEG_Overridden__c = 1';
                overrideRule.WEG_Description__c = 'Update';
                
                // iterate the actions
                for(WEG_Comp_OverrideRuleAction__c action : overrideRule.WEG_OverrideRuleActions__r) {
                    // get the Transaction field type
                    // use the reference id if it's a reference field
                    Schema.DisplayType transactionFieldType = transSchema.get(action.WEG_Field__c).getDescribe().getType();
                    if (transactionFieldType == Schema.DisplayType.REFERENCE)
                        action.WEG_Value__c = action.WEG_Reference_ID__c;
                    
                    // append the generated SQL based on the action
                    overrideRule.WEG_SqlUpdateCommand__c += generateSql(action.WEG_Field__c, action.WEG_Operator__c, action.WEG_Value__c, transactionFieldType, true);
                    overrideRule.WEG_Description__c += ' AND ' + action.WEG_Field__c;
                    
                    System.debug('>>>>>>>> Action Field: ' + action.WEG_Field__c);
                    System.debug('>>>>>>>> Action Field Type: ' + transactionFieldType);
                }
                
                // 
                overrideRule.WEG_SqlUpdateCommand__c += ' WHERE';
                overrideRule.WEG_Description__c += ' Based On';
                
                // iterate the conditions
                for(WEG_Comp_OverrideRuleCondition__c condition : overrideRule.WEG_OverrideRuleConditions__r) {
                    // get the Transaction field type
                    // use the reference id if it's a reference field
                    Schema.DisplayType transactionFieldType = transSchema.get(condition.WEG_Field__c).getDescribe().getType();
                    if (transactionFieldType == Schema.DisplayType.REFERENCE)
                        condition.WEG_Value__c = condition.WEG_Reference_ID__c;
                    
                    // append the generated SQL based on the condition
                    overrideRule.WEG_SqlUpdateCommand__c += generateSql(condition.WEG_Field__c, condition.WEG_Operator__c, condition.WEG_Value__c, transactionFieldType, false);
                    overrideRule.WEG_Description__c += ' AND ' + condition.WEG_Field__c;
                    
                    System.debug('>>>>>>>> Condition Field: ' + condition.WEG_Field__c);
                    System.debug('>>>>>>>> Condition Field Type: ' + transactionFieldType);
                }
                
                // replace the initial 'AND's
                overrideRule.WEG_SqlUpdateCommand__c = overrideRule.WEG_SqlUpdateCommand__c.replace('SET AND', 'SET');
                overrideRule.WEG_SqlUpdateCommand__c = overrideRule.WEG_SqlUpdateCommand__c.replace('WHERE AND', 'WHERE');
                overrideRule.WEG_Description__c = overrideRule.WEG_Description__c.replace('Update AND', 'Update');
                overrideRule.WEG_Description__c = overrideRule.WEG_Description__c.replace('Based On AND', 'Based On');
                
                // set the HasCriteriaAndActions flag
                overrideRule.WEG_HasCriteriaAndActions__c = true;
            }
            // reset fields where the check fails
            else {
                // set the HasCriteriaAndActions flag to false if not
                overrideRule.WEG_HasCriteriaAndActions__c = false;
                
                // reset the command and description fields
                overrideRule.WEG_SqlUpdateCommand__c = '';
                overrideRule.WEG_Description__c = '';
            }
        }
        
        // 
        try { update overrideRules; } catch (Exception ex) {  }
    }
    
    private string getFieldReferenceId(Map<String, Schema.SObjectField> transSchema, string transFieldName, string transFieldValue) {
        // get the Transaction field
        // Product__c (example)
        Schema.SObjectField transactionField = transSchema.get(transFieldName);
        if (transactionField == null) { return 'ERROR :: Field ' + transFieldName + ' not found on Transaction.'; }
        
        // get the Transaction field type
        // REFERENCE (example)
        Schema.DisplayType transactionFieldType = transactionField.getDescribe().getType();
        
        // continue if it's a reference field
        if (transactionFieldType == Schema.DisplayType.REFERENCE) {
            // prep the dynamic soql
            string soqlQuery;
            
            // get the object that the reference is to
            Schema.DescribeFieldResult f = transactionField.getDescribe();
            for(Schema.SObjectType reference : f.getReferenceTo()) {                
                // build the dynamic soql
                soqlQuery = 'SELECT Id FROM ' + reference.getDescribe().getName() + ' WHERE Name = :transFieldValue';
                
                System.debug('>>>>>>>> Lookup reference object name: ' + reference.getDescribe().getName());
                System.debug('>>>>>>>> Dynamic SOQL: ' + soqlQuery);
            }
            
            // run the query - ensure expected results
            List<sObject> sobjList = Database.query(soqlQuery);
            if (sobjList.size() != 1) {
                System.debug('>>>>>>>> Dynamic SOQL Results: ' + sobjList);
                return 'ERROR :: Field value "' + transFieldValue + '" not found on related object.';
            }
            
            return sobjList[0].Id;
        }
        else
            return '';
    }
}