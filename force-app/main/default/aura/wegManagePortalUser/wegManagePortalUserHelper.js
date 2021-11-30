({
	getPortalUser : function(component) {
		//component.set("v.Spinner", true);
		
        // 
        var action = component.get("c.getPortalUser");
        action.setParams({
            "accountId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                // get the portal user
                var portalUser = response.getReturnValue();
                
                if (portalUser.ErrorMessage)
                    alert(portalUser.ErrorMessage);
                else {
                    component.set("v.contactId", portalUser.ContactId);
                    component.set("v.userId", portalUser.UserId);
                    component.set("v.email", portalUser.Email);
                    component.set("v.userEmail", portalUser.UserEmail);
                    component.set("v.mobilePhone", portalUser.MobilePhone);
                    component.set("v.userMobilePhone", portalUser.UserMobilePhone);
                    component.set("v.isActive", portalUser.IsActive);
                    component.set("v.userIsActive", portalUser.UserIsActive);
                    component.set("v.username", portalUser.Username);
                    
                    this.toggleUserDetails(component, portalUser.IsActive);
                }
                
                //component.set("v.Spinner", false);
            }else{
                component.set("v.Status", 'Error occurred while enabling customer user. Please contact your System Administrator.');
            }
        });
        
        $A.enqueueAction(action);
	},
    
    savePortalUser : function(component) {
		//component.set("v.Spinner", true);
		component.set("v.status", "Saving...");
        
        var portalUser = {};
        portalUser.AccountId = component.get("v.recordId");
        portalUser.ContactId = component.get("v.contactId");
        portalUser.UserId = component.get("v.userId");
        portalUser.Email = component.get("v.email");
        portalUser.UserEmail = component.get("v.userEmail");
        portalUser.MobilePhone = component.get("v.mobilePhone");
        portalUser.UserMobilePhone = component.get("v.userMobilePhone");
        portalUser.IsActive = component.get("v.isActive");
        portalUser.UserIsActive = component.get("v.userIsActive");
        
        // first, validate the input
        //this.validateInput(component, portalUser);
        this.executeControllerMethod(component, 'c.validateInput', portalUser);
	},
    
    getNextControllerMethod : function(controllerMethod, portalUser) {
        //component.set("v.status", "Validating input...");
        
        if (controllerMethod == 'c.validateInput') {
            if (!portalUser.IsActive && portalUser.UserIsActive)
                return 'c.deactivateUser';
            else {
                if (portalUser.MobilePhone != portalUser.UserMobilePhone)
                    return 'c.updateMobileOnContact';
                else if (portalUser.UserId)
                    return 'c.updateUser';
                else
                    return 'c.createUser';
            }
        
        } else if (controllerMethod == 'c.deactivateUser') {
            return 'c.updatePortalStatus';
        
        } else if (controllerMethod == 'c.updateMobileOnContact') {
            if (portalUser.UserId)
                return 'c.updateUser';
            else
                return 'c.createUser';
        
        } else if (controllerMethod == 'c.updateUser') {
            if (portalUser.IsActive && !portalUser.UserIsActive)
                return 'c.updatePortalStatus';
            
        } else if (controllerMethod == 'c.createUser') {
            return 'c.linkUserOnContact';
        
        } else if (controllerMethod == 'c.linkUserOnContact') {
            return 'c.updatePortalStatus';
        
        } else {
            return null;
        }
	},
    
    getControllerMethodStatus : function(controllerMethod) {
        // 
        if (controllerMethod == 'c.validateInput') {
            return 'Validating input...';
        } else if (controllerMethod == 'c.deactivateUser') {
            return 'Deactivating user...';
        } else if (controllerMethod == 'c.updateMobileOnContact') {
            return 'Updating mobile on contact...';
        } else if (controllerMethod == 'c.createUser') {
            return 'Creating user...';
        } else if (controllerMethod == 'c.linkUserOnContact') {
            return 'Linking contact to user...';
        } else if (controllerMethod == 'c.updateUser') {
            return 'Updating user...';
        } else if (controllerMethod == 'c.updatePortalStatus') {
            return 'Updating user portal status...';
        } else {
            return 'Unknown controllerMethod!';
        }
	},
    
    executeControllerMethod : function(component, controllerMethod, portalUser) {
        var controllerMethodStatus = this.getControllerMethodStatus(controllerMethod);
        component.set("v.status", controllerMethodStatus);
        
        // 
        var action = component.get(controllerMethod);
        action.setParams({
            "portalUser": portalUser
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // get the portal user
                var portalUser = response.getReturnValue();
                
                if (portalUser.ErrorMessage) {
                    this.showToast("error", portalUser.ErrorTitle, portalUser.ErrorMessage);
                	component.set("v.status", '');
                } else {
                    var nextControllerMethod = this.getNextControllerMethod(controllerMethod, portalUser);
                    if (nextControllerMethod)
                    	this.executeControllerMethod(component, nextControllerMethod, portalUser);
                    else {
                        this.showToast("success", null, "Portal user updated successfully");
                        $A.get("e.force:closeQuickAction").fire();
                        //component.set("v.Spinner", false);
                    }
                }
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message)
                        this.showToast("error", "Bad Response", errors[0].message);
                    else
                        this.showToast("error", "Bad Response", "Uncaught exception.");
                }
                
                component.set("v.status", '');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showToast : function(toastType, title, message) {
        
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "title": title,
            "type": toastType,
            "message": message
        });
        
        toastEvent.fire();
    },
    toggleUserDetails : function(component, isActiveChecked) {
        //
        var userDetails = component.find("userDetails");
        
        if (isActiveChecked)
        	$A.util.removeClass(userDetails, "toggle");
        else
            $A.util.addClass(userDetails, "toggle");
    }
})