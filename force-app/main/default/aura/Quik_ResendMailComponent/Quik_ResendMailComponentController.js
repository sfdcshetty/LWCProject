({
	doInit : function(component, event, helper) {
        var action = component.get('c.resendEnvelope');
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if(state === 'SUCCESS') {
                var title = '';
                var type = '';
                var message = '';
                if(returnValue == 'Sent') {
                    type = 'success';
                    message = 'Document was resent successfully for signing.';
                } else if(returnValue == 'Completed') {
                    type = 'warning';
                    message = 'Signing was already completed by this Recipient.';
                } else if(returnValue == 'Created') {
                    type = 'warning';
                    message = 'Previous Signer havent signed the document yet.';
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": title,
                    "type": type,
                    "message": message
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})