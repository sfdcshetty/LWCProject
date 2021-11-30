({
	populateFAList : function(component, event, helper) {
        // 
        var action = component.get("c.getFinancialAccounts");
        var accountRecordId = component.get("v.accountRecordId");
        action.setParams ({
            "accountRecordId" : accountRecordId
        });
        action.setCallback(this, function(response) {
            // get the response
            var result = response.getReturnValue();
            // iterate the results, xxx
            console.log('>> result...');
            console.log(result);
            if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result)) {
                // 
                var checkBoxList = [];
                
                for (var i = 0; i < result.length; i++) {
                    var financialAccount = result[i];
                    var checkBoxOption = {};
                    
                    //if (record.Financial_Account__c)
                    //    record.Financial_Account__Name = record.Financial_Account__r.Name;
                    //if (record.Household__c)
                    //    record.Household__Name = record.Household__r.Name;                    
                    //record.LinkAddress = '/' + record.Id;
                    checkBoxOption.label = financialAccount.Name + ' - ' + financialAccount.FinServ__FinancialAccountNumber__c;
                    checkBoxOption.value = financialAccount.Id;
                    checkBoxList.push(checkBoxOption);
                }
                
                console.log('>> checkBoxList...');
                console.log(checkBoxList);
                component.set("v.financialAccounts", checkBoxList);
            }
            // add the transactions to the data grid
            //component.set("v.transactionRecords", result);
            // processing complete, hide spinner
            //component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    }
})