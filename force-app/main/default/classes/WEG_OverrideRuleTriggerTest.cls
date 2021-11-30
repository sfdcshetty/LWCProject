@isTest
private class WEG_OverrideRuleTriggerTest {
    
    private static testMethod void testTrigger(){
        
        test.startTest();
        
        WEG_PayPeriod__c payPeriod = new WEG_PayPeriod__c(
            Name = '201812',
            WEG_PeriodStartDate__c = Date.newInstance(2018, 6, 16),
            WEG_PeriodEndDate__c = Date.newInstance(2018, 6, 30),
            WEG_PeriodPayDate__c = Date.newInstance(2018, 7, 7)
        );
        insert payPeriod;
        
        WEG_Comp_OverrideRule__c rule = new WEG_Comp_OverrideRule__c(
            Name = 'Test Rule',
            WEG_EffectiveAsOf__c = payPeriod.Id
        );
        insert rule;
        
        // create a test product
        string testProductName = 'Test Product';
        Product2 testProduct = new Product2(Name = testProductName);
        insert testProduct;
        
        // set up the rule condition
        WEG_Comp_OverrideRuleCondition__c cond = new WEG_Comp_OverrideRuleCondition__c(
            WEG_OverrideRule__c = rule.Id,
            WEG_Field__c = 'Product__c',
            WEG_Operator__c = 'Equals',
            WEG_Value__c = 'Bad Value'
        );
        
        // a failure is expected regarding the field value
        try {
        	insert cond;
            System.assertEquals(true, false);
        }
        catch (Exception ex) {
            System.assertEquals(true, true);
        }
        
        // fix the bad field value
        cond.WEG_Value__c = testProductName;
        
        // success is now expected
        insert cond;
        
        // create a test action
        WEG_Comp_OverrideRuleAction__c action = new WEG_Comp_OverrideRuleAction__c(
            WEG_OverrideRule__c = rule.Id,
            WEG_Field__c = 'Product__c',
            WEG_Operator__c = 'Equals',
            WEG_Value__c = 'Bad Value'
        );
        
        // a failure is expected regarding the field value
        try {
        	insert action;
            System.assertEquals(true, false);
        }
        catch (Exception ex) {
            System.assertEquals(true, true);
        }
        
        // fix the bad field value
        action.WEG_Value__c = testProductName;
        
        // success is now expected
        insert action;
        
        // create a second test action
        WEG_Comp_OverrideRuleAction__c action2 = new WEG_Comp_OverrideRuleAction__c(
            WEG_OverrideRule__c = rule.Id,
            WEG_Field__c = 'GL_Product_Line__c',
            WEG_Operator__c = 'Equals',
            WEG_Value__c = '10'
        );
        insert action2;
        
        delete cond;
        delete action;
        delete action2;
        
        test.stopTest();
  }
}