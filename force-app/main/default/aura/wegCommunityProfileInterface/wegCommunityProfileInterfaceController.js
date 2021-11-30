({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    handleClick : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue == 'My Profile') {
            var userInfo = component.get("v.userInfo");
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": "/profile/" + userInfo.Id });
            urlEvent.fire();
        } else if (selectedMenuItemValue == 'Secure Messaging') {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": "/secure-messaging" });
            urlEvent.fire();
        } else if (selectedMenuItemValue == 'To Do List') {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": "/to-dos" });
            urlEvent.fire();
        } else if (selectedMenuItemValue == 'Preferences') {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": "/communication-preferences" });
            urlEvent.fire();
        } else if (selectedMenuItemValue == 'Change Password') {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": "/changepassword" });
            urlEvent.fire();
        } else if (selectedMenuItemValue == 'Sign Out') {
            window.location.replace("/clientportal/secur/logout.jsp");
        }
    }
})