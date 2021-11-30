({
    doInit : function(component, event, helper) {
        var signerType = component.get('v.receipientDetails.Signer_Type__c');
        if(signerType.indexOf('Primary') > -1) {
            component.set('v.iconDisplay', false);
        } else {
            component.set('v.iconDisplay', true);
        }
    },
    
    removeRow : function(component, event, helper){
        var order = component.get("v.receipientDetails.Order__c");
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex"),"formName" : component.get("v.formName") }).fire();
    }
   
})