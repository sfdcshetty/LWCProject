({
    doInit: function(component, event, helper) {
         console.log ('Event Calling');
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
        console.log(appEvent);
        console.log ('Event fired.!');
        }, 3000);
        
    },
    handleSaveRecord: function(component, event, helper) {
        
        component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
           if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // handle component related logic in event handler
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
    },

    handleRecordUpdated: function(component, event, helper) {
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
                "refreshParent" : false
            }
        );
        appEvent.fire();
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Saved",
                "mode" : "dismissible",
                "type" : "success",
                "message": "Description has been updated successfully."
            });
            resultsToast.fire();

        } 
    }
})