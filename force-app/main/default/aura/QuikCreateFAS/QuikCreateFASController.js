({
    doInit : function(component, event, helper) {
        var action = component.get('c.getRelatedHouseholdRecords');
        action.setParams({"asRecId":component.get('v.recordId')});
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result=='success') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "FAS record has been created successfully."
                });
                toastEvent.fire();                
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "type": "error",
                    "message": result
                });
                toastEvent.fire();                
            }
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    }
})