({
    GetSignerDetail :  function(component, event, helper) {
        var action = component.get('c.getSignerDetails');
        action.setParams({
            "accountServicingId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null) {
                    component.set('v.signerList', result);
                } else {
                    helper.displayToaster(component, event, helper, 'No record found to display', 'Info');  
                }
                component.set("v.spinnerForOpenEnv", false);
            } else {
                helper.displayToaster(component, event, helper, 'Something Went wrong', 'Error');
                component.set("v.spinnerForOpenEnv", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getStep3 : function(component, event, helper) {
        component.set("v.selectedStep", "step2");
        component.set("v.StepName", 'Set Order of Document');
        component.set("v.spinnerForOpenEnv", true);
        var action = component.get('c.getDocumentOrder');
        action.setParams({
            "formGroupId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result.length > 0) {
                    var docOrderMap = [];
                    var OrderValue;
                    for(var key in result) {
                        if(result[key].orderWrap != '') {
                            OrderValue  = result[key].orderWrap;
                        } else {
                            OrderValue  = parseInt(key) + 1;            
                        }
                        docOrderMap.push({
                            orderWrap : OrderValue,
                            custodianValue : result[key].custodianValue,
                            nameWrap : result[key].nameWrap,
                            formId :result[key].formId,
                            formNumber : result[key].formNumber,
                            recipients : result[key].recipients,
                            deliverTo : result[key].deliverTo, 
                            createdDate: result[key].createdDate
                        });
                    }
                    component.set('v.docOrder', docOrderMap);
                } else {
                    component.set('v.docOrder', []);
                    helper.displayToaster(component, event, helper, 'No record found to display', 'Info');   
                }
                component.set("v.spinnerForOpenEnv", false);
            } else {
                component.set("v.spinnerForOpenEnv", false);
                helper.displayToaster(component, event, helper, 'Something Went wrong', 'Error');
                component.set('v.docOrder', []);
            }
        });
        $A.enqueueAction(action);
    },
    
    displayToaster : function(component, event, helper, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : '',
            type: type,
            message: message
        });
        toastEvent.fire(); 
    }
})