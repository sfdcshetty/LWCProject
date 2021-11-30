({
	getFinancialAccountInfo : function(component, event) {
		var action = component.get("c.getAccountTypeAndBalances");	
        /*action.setParams({});*/
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state == 'SUCCESS'){
            	var FinAccWrapList = response.getReturnValue();  
                if(FinAccWrapList){
                	component.set('v.FinancialAccountWrapList',FinAccWrapList);
                }else{
                    if(FinAccWrapList.length == 0){
                        component.set("v.msg","No Financial Accounts were found");    
                    }
                }
            }else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR:",
                    "message": "Error occurred while fetching Financial Account Balance by Type.Please contact your Administrator."
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
	}
})