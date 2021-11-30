({
	getMessageCount : function(component) {
		var action = component.get("c.getUnreadMessageCount");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.unreadMessageCount", response.getReturnValue())
            }
        });
        $A.enqueueAction(action);	
	}
})