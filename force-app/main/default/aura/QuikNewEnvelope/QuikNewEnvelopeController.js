({
    doInit : function(component, event, helper) {
        component.set("v.spinnerForOpenEnv", true);
        component.set("v.selectedStep", "step1");
        component.set("v.StepName", 'Confirm Signers');
        helper.GetSignerDetail(component, event, helper);
    },
    
    saveRecipients : function(component, event, helper) {
        helper.getStep3(component, event, helper);
    },
    
    saveAndCloseStep3 : function(component, event, helper) {
        var compEvent = component.getEvent("eventForCloseModal");
        compEvent.fire();
    },
    
    cancel : function(component, event, helper) {
        var compEvent = component.getEvent("eventForCloseModal");
        compEvent.fire();
    },
    
    getFormView : function(component, event, helper) {
        component.set("v.spinnerForOpenEnv", true);
        component.set("v.StepName", 'Review Documents');
        component.set("v.selectedStep", "step3");
        var docOrderMap = component.get('v.docOrder');
        if(docOrderMap.length > 0) {
            component.set("v.CurrentPreview", 1);
            component.set("v.docPreviewListSize", 0);
            component.set("v.spinnerForOpenEnv", true);
            var urlList =[];
            var url = location.href;  
            var baseURL = url.substring(0, url.indexOf('/', 14));
            component.set("v.baseURL", baseURL);
            var orderList = [];
            var quikGroupId = [];
            for(var i = 0; i < docOrderMap.length; i++) {
                if(docOrderMap[i].orderWrap != 0){
                    orderList.push(docOrderMap[i].orderWrap);
                }
            }
            var numArray = new Float64Array(orderList);
            var numArray2 = numArray.sort();
            var docOrderSignersMap = [];
            for(var j = 0; j < numArray2.length; j++) {
                for(var i = 0; i < docOrderMap.length; i++) {
                    if(docOrderMap[i].orderWrap == numArray2[j]) {
                        docOrderSignersMap.push({
                            orderWrap : docOrderMap[i].orderWrap,
                            custodianValue : docOrderMap[i].custodianValue,
                            nameWrap : docOrderMap[i].nameWrap,
                            formId :docOrderMap[i].formId,
                            formNumber : docOrderMap[i].formNumber,
                            recipients : docOrderMap[i].recipients,
                            deliverTo : docOrderMap[i].deliverTo, 
                            createdDate : docOrderMap[i].createdDate
                        }); 
                        quikGroupId.push(docOrderMap[i].nameWrap.Id);
                        var name = '';
                        if(docOrderMap[i].nameWrap.FAS_List__c != undefined) {
                            name = docOrderMap[i].nameWrap.FAS_List__c;
                            if(name.indexOf(',') > -1) {
                                var nameList = name.split(',');
                                name = '';
                                for(var ino = 0; ino < nameList.length; ino++) {
                                    name += nameList[ino] + ' - ';
                                }
                                name = name.substring(0, name.length-3);
                            }
                        }
                        urlList.push({
                            Name : name,
                            URL : baseURL + '/apex/QuikHTMLView?showAttach=false&type=Sign&id=' + docOrderMap[i].formId,
                            PageNo: (i + 1),
                            asQFId: docOrderMap[i].formId
                        });
                    }
                }
            }
            component.set("v.formGroupId", quikGroupId);
            component.set('v.docSignersOrder', docOrderSignersMap);
            if(urlList.length > 0) {
                component.set("v.documnentHasValue", true);
            } else {
                component.set("v.documnentHasValue", false);
            }
            component.set("v.StepName", 'Review Document');
            component.set("v.selectedStep", "step3");
            component.set("v.docPreviewListSize", urlList.length);
            component.set("v.AsQuikformList", urlList);
            setTimeout(function() {
                component.set("v.spinnerForOpenEnv",false);
            }, 13000);
        }
    },
    
    confirmAndSend : function(component, event, helper) {
        component.set("v.spinnerForOpenEnv", true);
        var qfIds = '';
        var asQFList = component.get("v.AsQuikformList");
        for(var i = 0; i < asQFList.length; i++) {
            qfIds += asQFList[i].asQFId + ',';
        }
        var action = component.get('c.checkEnvelopeStatus');
        action.setParams({
            "asQfId" : qfIds.substring(0, qfIds.length-1)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result == 'success') {
                    component.set("v.StepName", 'Confirm And Send');
                    component.set("v.selectedStep", "step4");
                    component.set("v.spinnerForOpenEnv", false);
                } else if(result == 'fail') {
                    helper.displayToaster(component, event, helper, 'Please click on Draft button for all forms selected.', 'Error');
                    component.set("v.StepName", 'Review Document');
                    component.set("v.selectedStep", "step3");
                    component.set("v.spinnerForOpenEnv", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    nextUrl : function(component, event, helper) {
        var CurrentPage = component.get("v.CurrentPreview");
        component.set("v.spinnerForOpenEnv", true);
        var asQFList = component.get('v.AsQuikformList');
        var action = component.get('c.checkDocusignId');
        action.setParams({
            "qfId" : asQFList[(CurrentPage - 1)].asQFId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == 'SUCCESS') {
                if(result == 'success') {
                    component.set("v.CurrentPreview", parseInt(CurrentPage) + 1);
                    setTimeout(function() {
                        component.set("v.spinnerForOpenEnv", false);
                    }, 6000);
                } else if(result == 'fail') {
                    helper.displayToaster(component, event, helper, 'Please click on Draft button.', 'Warning');
                    component.set("v.spinnerForOpenEnv", false);
                }
            } else {
                var errorMsg = action.getError()[0].message;
                helper.displayToaster(component, event, helper, errorMsg, 'Error'); 
                component.set("v.spinnerForOpenEnv", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    previousUrl : function(component, event, helper) {
        component.set("v.spinnerForOpenEnv", true);
        var CurrentPage = component.get("v.CurrentPreview");
        component.set("v.CurrentPreview", parseInt(CurrentPage) - 1);
        setTimeout(function() {
            component.set("v.spinnerForOpenEnv",false);
        }, 6000);
    },
    
    sendAllForms : function(component, event, helper) {
        component.set("v.spinnerForOpenEnv", true);
        var action = component.get("c.sendMailToSigners");
        var signerList = component.get("v.signerList");
        action.setParams({
            detailsInOrder : JSON.stringify(component.get("v.docSignersOrder")), 
            signersList : signerList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == 'SUCCESS') {
                var action1 = component.get("c.callDS");
                action1.setParams({
                    qfGroupIdList : result
                });
                action1.setCallback(this, function(response1) {
                    var state = response1.getState();
                    if(state == 'SUCCESS') {
                        helper.displayToaster(component, event, helper, 'Mail sent for signing', 'success'); 
                        component.set("v.spinnerForOpenEnv", false);
                        var compEvent = component.getEvent("eventForCloseModal");
                        compEvent.fire();
                    } else {
                        var errorMsg = action.getError()[0].message;
                        helper.displayToaster(component, event, helper, errorMsg, 'Error'); 
                        component.set("v.spinnerForOpenEnv", false);
                    }
                });
                $A.enqueueAction(action1);
            } else {
                var errorMsg = action.getError()[0].message;
                helper.displayToaster(component, event, helper, errorMsg, 'Error'); 
                component.set("v.spinnerForOpenEnv", false);
            }
        });
        $A.enqueueAction(action);
    }
})