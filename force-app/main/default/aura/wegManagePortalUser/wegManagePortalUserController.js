({
	init : function(component, event, helper) {
		helper.getPortalUser(component);
	},
    handleSave : function(component, event, helper) {
		var buttonClicked = event.getSource().get("v.label");
        
        helper.savePortalUser(component);
	},
    handleActiveChange : function(component, event, helper) {
        
        // get the active checkbox value
        var isActiveChecked = component.get("v.isActive");
        
        // toggle the user details
        helper.toggleUserDetails(component, isActiveChecked);
    }
})