({
    init : function(component, event, helper) {
		var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
        	helper.init(component, event);    
        }
    }
})