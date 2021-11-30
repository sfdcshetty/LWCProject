({
	showToast : function(component, event, helper, type, message) {
        if (type == 'error') {
            component.set ('v.notificationTheme', 'slds-theme_error');
        }
        if (type == 'success') {
            component.set ('v.notificationTheme', 'slds-theme_success');
        }
        var notification = component.find ('notification');
        $A.util.toggleClass (notification, 'slds-hide');
        component.set ('v.message', message);
        
    },
    showSpinner : function (component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})