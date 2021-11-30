({	
  
    save : function(component, event) {
        // Save the record
        component.set("v.showSpinner", true);
        component.set("v.isErrorOnSave", true);
        component.find("edit").get("e.recordSave").fire();
        
    },
    
    handleSaveSuccess : function(component, event,helper) {
        var refresh = component.getEvent("refreshView");
        refresh.setParams({
            "refreshView" : true
        });
        refresh.fire();
        component.set("v.showSpinner", false);
        component.set("v.isErrorOnSave", false);
    },
    
    cancel : function(component, event, helper){
        component.destroy();
    },
    
    handleDoneWaiting : function(component, event) { 
        // if there were errors during save, the handleSaveSuccess doesn’t get fired 
        if(component.get("v.isErrorOnSave") === true) { // show the error div 
        	component.set("v.showSpinner", false);
        } 
    
    }
})