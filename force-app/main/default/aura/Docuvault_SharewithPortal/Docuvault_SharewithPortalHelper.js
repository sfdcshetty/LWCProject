({
    handleSaveRecord: function(component, event, helper) {
        var record = component.get("v.simpleRecord");
        record.Share_On_Portal__c = true;
        record.Portal_Folder__c = 'Documents';
        component.set ('v.isRecordShared', false);
        component.set("v.simpleRecord",record);
        console.log(component.get("v.simpleRecord"));
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
        component.set("v.Spinner", false); 
    },
    activeUser: function(component, event, helper) {
        console.log(component.get('v.CloudFileId'));
    	var action1 = component.get('c.checkPortalUser'); 
        action1.setParams({
            "recId" : component.get('v.CloudFileId') 
        });
        action1.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var returnVal = a.getReturnValue();
                component.set('v.activePortalUser', returnVal);                
                var shareOnPortal = component.get('v.simpleRecord.Share_On_Portal__c');
                if(shareOnPortal == '' || shareOnPortal == null) {
                    shareOnPortal = false;
                }
                var recShared = component.get('v.isRecordShared');
                if(( recShared== true && shareOnPortal == false && returnVal== true)) {
                    helper.handleSaveRecord(component,event,helper);
                    component.set("v.Spinner", true);                     
                }
            }
        });
        $A.enqueueAction(action1);
     }
})