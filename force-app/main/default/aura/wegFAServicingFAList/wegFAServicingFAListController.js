({
	init : function(component, event, helper) {
		// populate the list of financial accounts
		helper.populateFAList(component, event, helper);
	},
    handleCheckboxChange: function (component, event, helper) {
        //
        var changeValue = event.getParam("value");
        
        /*for (var i = 0; i < changeValue.length; i++) {
            var singleValue = changeValue[i];
            alert(singleValue);
        }*/
        
        var financialAccountList = {};
        financialAccountList.financialAccountIds = changeValue;
        financialAccountList.countFinancialAccounts = changeValue.length;
        component.set("v.financialAccountList", financialAccountList);
        
        //var financialAccountValues = component.get("v.financialAccountValues");
        //alert(financialAccountValues);
    }
})