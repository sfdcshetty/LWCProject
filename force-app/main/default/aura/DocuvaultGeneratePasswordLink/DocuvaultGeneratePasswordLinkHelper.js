({
    showToast : function(component, event, type, mode, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type : type,
            mode: mode,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})