({
    selectAll : function(component, event, helper) {
        //event.getSource().select(); 
        //var auraID = event.getSource().getLocalId();
        //console.log(auraID);
        //alert(component.find(auraID));
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
    doInit : function(component, event, helper) {
        component.set("v.pageSize", component.get("v.pageSizeLimit"));
        var adjustmentCreated = event.getParam("investmentAdjustmentCreated");
        window.addEventListener("click", function(e){
            if(e.target){
                var ele = e.target;
            }
        }, true);
        if(adjustmentCreated === undefined || adjustmentCreated === true){
            var modalDiv = component.find("modal");
            $A.util.removeClass(modalDiv, "slds-show");
            $A.util.addClass(modalDiv, "slds-hide");
            component.set("v.showSpinner", true);
            helper.fetchData(component, event, helper);
        }
        if(adjustmentCreated === false){
            var modalDiv = component.find("modal");
            $A.util.removeClass(modalDiv, "slds-show");
            $A.util.addClass(modalDiv, "slds-hide");
        }
        component.set("v.showEdit", false);
    },
   
    save : function(component, event, helper){
        component.set("v.showSpinner", true);        
        var financialAccountsData = component.get("v.financialAccountData");
        console.log('financialAccountsData 1:>>'+JSON.stringify(financialAccountsData));
        var i, j, k;
        for(i=0; i < financialAccountsData.categoryWrapperList.length; i++){
            for(j=0; j < financialAccountsData.categoryWrapperList[i].recordFieldValuesList.length; j++){
                for(k=0; k < financialAccountsData.categoryWrapperList[i].recordFieldValuesList[j].length; k++){
                    var data = financialAccountsData.categoryWrapperList[i].recordFieldValuesList[j][k];
                    if(data.fieldType === 'PERCENT'){
                        data.fieldValue = data.fieldValue*100;
                    }
                    if(data.fieldType === 'CURRENCY'){
                        if(data.fieldValue === null){
                            data.fieldValue = 0;    
                        }
                    }
                }
            }
        }
        console.log('financialAccountsData 2:>>'+JSON.stringify(financialAccountsData));
        
        var saveAction = component.get("c.saveChanges");
        saveAction.setParams({
            'gridWrapperStr': JSON.stringify(financialAccountsData)
        });
        saveAction.setCallback(this, function(response){
            var state = response.getState();
            console.log("State:>>" + state);
            if(state === "SUCCESS"){
                var updateResultList = response.getReturnValue();
                var ind = 0;
                var errorToastMessageList = [];
                for(; ind < updateResultList.length; ind++){
                    var result = updateResultList[ind];
                    if(!result.isSuccess){
                        errorToastMessageList.push(result.record.Name + ': ' + result.errorMessage);
                    }
                }
                console.log(':>>'+updateResultList.length +'::'+ errorToastMessageList.length);
                
                if(updateResultList.length > errorToastMessageList.length){
                    helper.fetchData(component, event);
                }else{
                    component.set("v.readOnlyMode", true);
                    component.set("v.showSpinner", false);     
                }
                
                if(errorToastMessageList.length > 0){
                    component.find('toast').showNotice({
                        "variant": "warning",
                        "header": "Update failed!",
                        "message": "Following error(s) has occurred while updating \n" + errorToastMessageList.join("\n"),
                        closeCallback: function() {
                            //helper.fetchData(component, event);    
                        }
                    });
                }
            }
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            
        });
        $A.enqueueAction(saveAction);
    },
    
    cancel : function(component, event, helper){
        component.set("v.showSpinner", true);
        helper.fetchData(component, event);
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },
    
    expandGrid : function(component, event, helper) {
        component.set("v.pageSize", component.get("v.finAccGridWrap.listSize"));
        component.set("v.listSize", component.get("v.finAccGridWrap.listSize"));
        component.set("v.isCollapsed", false);
    },
    
    collapseGrid : function(component, event, helper) {
        component.set("v.pageSize", component.get("v.pageSizeLimit"));
        var finAccGridWrap = component.get("v.finAccGridWrap");
        var pageSizeLimit = component.get("v.pageSizeLimit");
        if(finAccGridWrap.listSize > pageSizeLimit){
            component.set("v.listSize", pageSizeLimit+"+");
        }else{
            component.set("v.listSize", finAccGridWrap.listSize);    
        }
        component.set("v.isCollapsed", true);
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },
    
    hideActionMenu : function(component, event, helper){
        helper.hideRecordActionList_H(component, event);
    },
    
    createRecord : function(component, event, helper){
        component.set("v.showSpinner", true);
        var object = component.get("v.objectName");
        var recordTypeIds = component.get("v.recordTypes");
        
        var retrieveRecordTypes = component.get("c.getRecordTypes");
        retrieveRecordTypes.setParams({
            "objectName": object,
            "recordTypeIds": recordTypeIds
        });
        retrieveRecordTypes.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.recordTypeOptions", response.getReturnValue());
                var recordTypes = response.getReturnValue();
                // if input record type is only one then do not show record type selection modal.
                // Directly open create new record modal
                if(recordTypes.length == 1){
                    var windowHash = window.location.hash;
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": object,
                        "recordTypeId": recordTypes[0].value,
                        "defaultFieldValues": {
                            'FinServ__PrimaryOwner__c' : component.get("v.finAccGridWrap.primaryOwnerId")
                        },
                        "panelOnDestroyCallback": function(event) {
                            window.location.hash = windowHash;
                        }
                    });
                    createRecordEvent.fire();
                }else{
                    component.set("v.showNewRecordModal", false);
                    component.set("v.showNewRecordModal", true);   
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(retrieveRecordTypes);
    },
    
    onSelectChange : function(component, event, helper) {
        var selectedValue = event.target.name;
        var selectedAction = selectedValue.split(":")[0];
        var recordId = selectedValue.split(":")[1];
        if(selectedAction && recordId) {
            if(selectedAction == "Edit") {
                component.set('v.selectedRecordId',recordId);
                component.set('v.showEdit',false);
                component.set('v.showEdit',true);
                
                //helper.editRecord(component, event, recordId);
            }else if(selectedAction == 'Adjust Contributions/Withdrawals'){
                $A.createComponent(
                    "c:wv6_CreateInvestmentAdjustment",
                    {
                        "financialAccountId": recordId
                    },
                    function(investAdjustCmp){
                        if (component.isValid()) {
                            var investAdjustModal  = component.find("investAdjustModal"); 
                            var body = investAdjustModal.get("v.body");
                            body.push(investAdjustCmp);
                            investAdjustModal.set("v.body", body);
                        }                        
                    });
                var modalDiv = component.find('modal');
                $A.util.addClass(modalDiv, "slds-show");
                $A.util.removeClass(modalDiv, "slds-hide");
            }
                else if(selectedAction == 'View Adjustments'){
                    var redirectUrl = window.location.origin + "/one/one.app?source=alohaHeader#/sObject/" + recordId + "/rlName/Investment_Adjustment__r/view";
                    window.open(redirectUrl, '_blank');
                }
                    else {
                        component.set("v.showSpinner", true);
                        helper.removeRecordFromGrid(component, event, recordId, selectedAction);
                        
                    }
        }
        helper.hideRecordActionList_H(component, event);
    },
    
    refreshView : function(component, event, helper) {
        if(component.get("v.isForceSaveFired")){
            //$A.get('e.force:refreshView').fire();
            helper.fetchData(component, event);
            
            component.set("v.isForceSaveFired", false);
        }
        
    },
    
    showRecordActionList : function(component, event, helper) {
        if(component.get("v.currentElementId")) {
            helper.hideRecordActionList_H(component, event);
        } else {
            helper.showRecordActionList_H(component, event);
        }
    },
    
    hideRecordActionList : function(component, event, helper) {
        helper.hideRecordActionList_H(component, event);
    },
    
    editGrid : function(component, event, helper){
        component.set("v.showSpinner", true);
        helper.editGridRecords(component, event);
    }
})