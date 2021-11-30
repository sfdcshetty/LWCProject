({
	getResponseError : function(response) {
        
        var errors = response.getError();
        
        if (errors && errors[0] && errors[0].message) {
            return errors[0].message;
            
        } else {
            if (errors && errors[0] && errors[0].pageErrors && errors[0].pageErrors[0])
                return errors[0].pageErrors[0];
        }
    },
    
    showErrorToast : function(message, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: 'error',
            title: title,
            message: message
        });
        toastEvent.fire();
    }
})