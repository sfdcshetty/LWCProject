({
	cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
	},
    sendEmail : function(component, event, helper) {
        var emailaddress = component.get ("v.email");
        if (emailaddress != '') {
            var action = component.get("c.generateShareableLink");
			action.setParams({ recordId : component.get("v.recordId"),
                              emailAddress : component.get("v.email")
                             });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue() == 'Success') {
                        $A.get('e.force:refreshView').fire();
                        helper.showToast (component, event, 'success', 'dismissible', 'Success', 'Email Send Initiated.');
            			$A.get("e.force:closeQuickAction").fire();
                        
                    }
                    else {
                        helper.showToast (component, event, 'error', 'sticky', 'Error !', response.getReturnValue());
                    }
            	}
            });
            $A.enqueueAction(action);



            
        } else {
            helper.showToast (component, event, 'warning', 'sticky', 'Warning !', 'Email Address is required.');
        }
        
		
	}
})