({
    doInit : function(component, event, helper) {
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    },
    
    deleteRecord : function(component, event, helper) {
        var accServRecId = component.get('v.recordId');
        var asQuikFormId = event.getSource().get('v.name');
        var action = component.get('c.deleteASQuikForm');
        action.setParams({"asQuikFormId": asQuikFormId});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            if(result=='success'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The selected Form has been deleted successfully."
                });
                toastEvent.fire();
                helper.getASQuikFormRecords(component, event, helper, accServRecId);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Failure!",
                    "message": result
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    openModal : function(component, event, helper) {
        var asQuikFormId = event.getSource().get('v.name');
        component.set('v.formHTMLURL', asQuikFormId);
        component.set('v.showSpinner', true);
        component.set('v.showModal', true);
        setTimeout(function() {
            component.set('v.showSpinner', false);
        }, 5000);
    },
    
    closeModal : function(component, event, helper) {
        component.set('v.showModal', false);
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    },
    
    openFormsModal : function(component, event, helper) {
        var allowEsign = component.get('v.allowEsign');
        if(allowEsign == true) {
            component.set('v.showFormsModal', true);
        }else {
            component.set('v.showPrintModal', true);
        }
        
    },
    
    cancel : function(component, event, helper) {
        component.set('v.showFormsModal', false);
    },
    
    closeFormsModal : function(component, event, helper) {
        component.set('v.showFormsModal', false);
        component.set('v.showPrintModal', false);
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    }, 
    
    refreshForms: function(component, event, helper) {
        component.set('v.displaySpinner', true);
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    },
    
    print : function(component, event, helper) {
        component.set('v.showFormsModal', false);
        component.set('v.showPrintModal', true);
    },
    
    sign : function(component, event, helper) {
        component.set('v.showFormsModal', false);
        component.set('v.showSignModal', true);
    },
    
    closeSignsModal : function(component, event, helper) {
        component.set('v.showFormsModal', false);
        component.set('v.showSignModal', false);
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    }
})