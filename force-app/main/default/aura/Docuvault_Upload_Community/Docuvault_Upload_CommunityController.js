({
    doInit : function(component, event, helper) {
        var action = component.get ('c.getRelatedAccountID');		
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set ('v.parentId', result);
                console.log (result);
                if (result.length == 18 || result.length == 15) {
                    helper.createUpload (component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    loadUploadFiles : function (component, event, helper) {
        helper.createUpload (component, event, helper);
    }
})