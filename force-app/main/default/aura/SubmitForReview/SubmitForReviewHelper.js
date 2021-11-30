({
    reviewHelper : function(component, event, helper, recordId) {
        var action = component.get('c.checkFieldValues');
        action.setParams({
            "recId": recordId,
        });
        action.setCallback(this, function(response) {
            var values = response.getReturnValue();
            component.set('v.showSpinner', false);            
            if(!$A.util.isEmpty(values) && !$A.util.isUndefined(values)) {
                var message = "Please fill: "+values+" and try again.";
                component.set('v.message', message);
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Please Address Items Below",
                    "message": message
                });
            } else {
                component.set('v.succesMessage', true);
            }
            
            window.setTimeout(
                $A.getCallback(function() {
                    $A.get("e.force:closeQuickAction").fire();
                }), 3000
            );
            
        });
        $A.enqueueAction(action);
    },
})