({
	getClonedRecord : function(component) {
		var action = component.get("c.getClonedRecord");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.SecureMessage", response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action);
	},
    saveSMRecord : function(component) {
        var action = component.get("c.saveSMRecord");
        action.setParams({
            "SMRecord" : JSON.stringify(component.get("v.SecureMessage"))
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
			if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
    closeReplyModal : function(component) {
        $A.get("e.force:closeQuickAction").fire()
    }
})