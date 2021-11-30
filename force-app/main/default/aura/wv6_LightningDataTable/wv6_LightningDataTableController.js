({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        helper.getsObjectRecords(component);
	},
    navigate : function (component, event, helper) {
        var val = event.getSource().get("v.value");
        console.log (val);
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": val
        });
        urlEvent.fire();
        
    }
})