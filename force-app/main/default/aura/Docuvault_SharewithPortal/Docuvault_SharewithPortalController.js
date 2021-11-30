({
    doInit: function(component, event, helper) {
        component.set("v.Spinner", true);
        setTimeout(function(){ 
            var appEvent = $A.get("e.TVA_CFB:Docuvault_DynamicModalAction");
            appEvent.setParams(
                { 
                    "isRecordAction" : true,
                    "enableClose" : true,
                    "closeModal" : false,
                    "refreshParent" : false
                }
            );
            appEvent.fire();
            helper.activeUser(component,event,helper);
        }, 3000);
      
    },
    
    
    handleRecordUpdated: function(component, event, helper) {
        var isRecordShared = component.get ('v.isRecordShared');
        if (!$A.util.isUndefined (isRecordShared) 
            && 
            !$A.util.isEmpty (isRecordShared) 
            && 
            isRecordShared == false) {
            var eventParams = event.getParams();
            if(eventParams.changeType === "CHANGED") {
                var changedFields = eventParams.changedFields;
                console.log('Fields that are changed: ' + JSON.stringify(changedFields));
                var appEvent = $A.get("e.TVA_CFB:Docuvault_DynamicModalAction");
                appEvent.setParams(
                    { 
                        "isRecordAction" : true,
                        "enableClose" : false,
                        "closeModal" : true,
                        "refreshParent" : true
                    }
                );
                appEvent.fire();
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved",
                    "mode" : "dismissible",
                    "type" : "success",
                    "message": "File has been shared with portal."
                });
                resultsToast.fire();
            }
        } 
    }
})