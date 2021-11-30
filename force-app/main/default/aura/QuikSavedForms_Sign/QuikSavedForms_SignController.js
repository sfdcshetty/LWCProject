({
    doInit : function(component, event, helper) {
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    },
    
    closeModal : function(component, event, helper) {
        component.set('v.showModal', false);
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    },
    
    closeViewFormModal : function(component, event, helper) {
        component.set('v.viewFormModal', false);
    },
    
    openFormsModal : function(component, event, helper) {
        component.set("v.spinnerForOpenEnv",true);
        component.set('v.showFormsModal', true);
    },
    
    cancel : function(component, event, helper) {
        component.set('v.showFormsModal', false);
        component.set('v.viewFormModal', false);
    },
    
    refreshForms: function(component, event, helper) {
        component.set('v.displaySpinner', true);
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    },
    
    closeSignsModal : function(component, event, helper) {
        component.set('v.showFormsModal', false);
        component.set('v.showSignModal', false);
        var accServRecId = component.get('v.recordId');
        helper.getASQuikFormRecords(component, event, helper, accServRecId);
    }
})