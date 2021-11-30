({
	IncreamentMessageCount : function(component) {
		var action = component.get("c.incrementSMReadCount");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){   
        });
        $A.enqueueAction(action);	
	}
})