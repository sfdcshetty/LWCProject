({
    init : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var accRecord = component.get('v.accountRecord');
            console.log (accRecord);
            console.log (typeof accRecord);
            
            var recordTypeName = accRecord['RecordType']['Name'];
            var recordId = accRecord['Id'];
            component.set('v.recordtypename',recordTypeName);
            
            console.log (recordTypeName, recordId);            
            if(!component.get('v.accReloaded')){
                var action  = component.get("c.getFieldsToQuery");
                action.setParams({
                    "recType":accRecord.RecordType.Name
                });
                action.setCallback(this, function(a) {
                    var fieldsToQuery = a.getReturnValue();
                    console.log (fieldsToQuery);
                    var fieldsToQueryArr = ['RecordType.Name'];
                    console.log (fieldsToQueryArr);
                    var fieldAPINameLable = new Map();
                    
                    for (i = 0; i < fieldsToQuery.length; i++){
                        fieldsToQueryArr.push(fieldsToQuery[i].fieldLabel);
                        fieldAPINameLable.set(fieldsToQuery[i].fieldLabel,fieldsToQuery[i].fieldValue);
                    }
                    console.log('fieldAPINameLable:>>'+JSON.stringify(fieldAPINameLable));
                    component.set('v.accReloaded',true);
                    component.set('v.fieldsToQueryArr',fieldsToQueryArr);
                    component.set('v.fieldAPINameLable',fieldAPINameLable);
                    component.set('v.fieldsToQuery',fieldsToQueryArr);
                    component.find("recordLoader").reloadRecord();
                });
                $A.enqueueAction(action);
            } else {
                component.set("v.iconPath","/resource/WEG_ICONS/"+accRecord.RecordType.Name.toLowerCase()+".png");
                var fieldWrapList = [];
                var fieldsToQueryArr = component.get('v.fieldsToQueryArr');
                var fieldAPINameLable = component.get('v.fieldAPINameLable');
                var  priInd = '';
                var  secInd = '';
                
                
                for (var i=0; i< fieldsToQueryArr.length; i++) {
                    if(fieldsToQueryArr[i] === 'RecordType.Name'){
                        fieldWrapList.push({
                            "fieldLabel" : 'Account Type',
                            "fieldValue"  : accRecord['RecordType']['Name']
                        });
                    }else if(fieldsToQueryArr[i] === 'WEGP1_Primary_Individual__r.Name'){
                        if(accRecord['WEGP1_Primary_Individual__r']){
                            priInd = accRecord['WEGP1_Primary_Individual__r']['Name'];
                        }
                        fieldWrapList.push({
                            "fieldLabel" : fieldAPINameLable.get(fieldsToQueryArr[i]),
                            "fieldValue"  : priInd
                        });
                    }else if(fieldsToQueryArr[i] === 'WEGP1_Secondary_Individual__r.Name'){
                        if(accRecord['WEGP1_Secondary_Individual__r']){
                            secInd = accRecord['WEGP1_Secondary_Individual__r']['Name'];
                        }
                        fieldWrapList.push({
                            "fieldLabel" : fieldAPINameLable.get(fieldsToQueryArr[i]),
                            "fieldValue"  : secInd
                        });
                    }else if(fieldsToQueryArr[i] === 'FinServ__AUM__c'){
                        fieldWrapList.push({
                            "fieldLabel" : fieldAPINameLable.get(fieldsToQueryArr[i]),
                            "fieldValue"  : Math.round(accRecord[fieldsToQueryArr[i]])
                        });
                    }else if(fieldsToQueryArr[i] === 'WEGP1_Primary_Individual__c' ){
                        component.set('v.primaryIndId', accRecord[fieldsToQueryArr[i]]);
                    }else if(fieldsToQueryArr[i] === 'WEGP1_Secondary_Individual__c'){
                        component.set('v.secondaryIndId', accRecord[fieldsToQueryArr[i]]);
                    }else{
                        fieldWrapList.push({
                            "fieldLabel" : fieldAPINameLable.get(fieldsToQueryArr[i]),
                            "fieldValue"  : accRecord[fieldsToQueryArr[i]]
                        });
                    }
                }
                console.log('fieldWrapList:>>'+JSON.stringify(fieldWrapList));
                component.set("v.fieldWrapList",fieldWrapList);
            }
            var actionUser = component.get ('c.PortalUserDetails');
            actionUser.setParams ({
                'primaryInd' : component.get ('v.primaryIndId'),
                'secondaryInd' : component.get ('v.secondaryIndId'),
            });
            actionUser.setCallback (this, function (response) {
                var state = response.getState ();
                
                if (state === "SUCCESS") {
                    var result = response.getReturnValue ();
                    //console.log ('second ind', component.get ('v.secondaryIndId'));
                    //console.log ('result init', result);
                    
                    component.set ('v.primaryIndIdUser', result.primaryIndividualUser);
                    component.set ('v.primaryIndIdUserContact', result.primaryIndividualContact);
                    component.set ('v.secondaryIndIdUserContact', result.secondaryIndividualContact);
                    
                    component.set ('v.secondaryIndIdUser', result.secondaryIndividualUser);
                    component.set ('v.primaryIndIdUserAccId', result.primaryIndividualAccountId);
                    component.set ('v.secondaryIndIdUserAccId', result.secondaryIndividualAccountId);
                }
            });
            $A.enqueueAction (actionUser);
            var action = component.get ('c.getIndividualRecordsDetails');
            action.setParams ({
                'recordId' : recordId,
                'recType' : recordTypeName
            });
            action.setCallback (this, function (response) {
                var state = response.getState ();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue ();
                    console.log (result);
                    component.set ('v.accountIndividualRecord', result);
                }
                
                if (state === "ERROR") {
                    var error = response.getError ()[0].message;
                    console.log (error);
                }
            });
            $A.enqueueAction (action);
        }
    },
    navigate : function (component, event, helper) {
        var val = event.getSource().get("v.value");
        console.log (val);
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": val
        });
        urlEvent.fire();
        
    },
    handlePrimarySelect : function(component, event, helper) {
        var primaryId = component.get('v.primaryIndId');
        var selectedValue = event.getParam("value");
        var primaryIndividualUser = component.get ('v.primaryIndIdUser');
        if (!$A.util.isEmpty (primaryIndividualUser) && !$A.util.isUndefined (primaryIndividualUser)) {}
        else {
            primaryIndividualUser = '';
        }
        var primaryIndAccId = component.get ('v.primaryIndIdUserAccId');
        if (!$A.util.isEmpty (primaryIndAccId) && !$A.util.isUndefined (primaryIndAccId)) {}
        else {
            primaryIndAccId = '';
        }
        var primaryIndConId = component.get ('v.primaryIndIdUserContact');
        if (!$A.util.isEmpty (primaryIndConId) && !$A.util.isUndefined (primaryIndConId)) {}
        else {
            primaryIndConId = '';
        }
        helper.handleSelect(component, event, primaryId, selectedValue, primaryIndividualUser, primaryIndAccId, primaryIndConId);
    },
    
    handleSecondarySelect : function(component, event, helper) {        
        var secondaryId = component.get('v.secondaryIndId');
        var selectedValue = event.getParam("value");
        var secondaryIndividualUser = component.get ('v.secondaryIndIdUser');
        if (!$A.util.isEmpty (secondaryIndividualUser) && !$A.util.isUndefined (secondaryIndividualUser)) {}
        else {
            secondaryIndividualUser = '';
        }
        var secondaryIndAccId = component.get ('v.secondaryIndIdUserAccId');
        if (!$A.util.isEmpty (secondaryIndAccId) && !$A.util.isUndefined (secondaryIndAccId)) {}
        else {
            secondaryIndAccId = '';
        }
        var secondaryIndConId = component.get ('v.secondaryIndIdUserContact');
        if (!$A.util.isEmpty (secondaryIndConId) && !$A.util.isUndefined (secondaryIndConId)) {}
        else {
            secondaryIndConId = '';
            console.log('secondary', 'no secondary contact ID');
        }
        helper.handleSelect(component, event, secondaryId, selectedValue, secondaryIndividualUser, secondaryIndAccId, secondaryIndConId);
    }
})