({
	 closeMe : function(component, event, helper, refreshView){
        var refresh = component.getEvent("refreshView");
        refresh.setParams({
            "refreshView" : refreshView
        });
        refresh.fire();
        console.log("event fired@@@@@@@");
        component.destroy();
    }
})