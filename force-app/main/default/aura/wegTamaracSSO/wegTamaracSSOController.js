({
	init : function(component, event, helper) {
		
        // set up the action
        var action = component.get('c.userHasSignOnAccess');
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                var userHasSignOnAccess = response.getReturnValue();
                component.set('v.userHasSignOnAccess', userHasSignOnAccess);
                
            } else {
                console.error('>> wegTamaracSSO :: userHasSignOnAccess');
                var responseError = helper.getResponseError(response);
                console.error(responseError);
                helper.showErrorToast(responseError, 'Error validating Tamarac SSO access.');
            }
        });
        
        $A.enqueueAction(action);
	},
    
    handleClick : function(component, event, helper) {
		
        //
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'https://clientportal.wealthenhancement.com/clientportal/idp/login?app=0sp410000004CfO'
        });
        urlEvent.fire();
	}
})