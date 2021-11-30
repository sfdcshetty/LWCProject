({
	init : function(component, event, helper) {
        //component.set("v.Spinner", true);
        
        var action = component.get("c.disableCustomerUser");
        action.setParams({
            "accountId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Status", response.getReturnValue());
                //$A.get("e.force:closeQuickAction").fire();
                //component.set("v.Spinner", false);
            }else{
                component.set("v.Status", 'Error Occurred while disabling customer user. Please contact your System Administrator.');
            }
        });
        $A.enqueueAction(action);
	},
    closePopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})